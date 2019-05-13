/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "AddDriftDiffusionAction.h"
#include "Parser.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseEnum.h"
#include "AddVariableAction.h"
#include "Conversion.h"
#include "DirichletBC.h"
#include "ActionFactory.h"
#include "MooseObjectAction.h"
#include "MooseApp.h"

#include "libmesh/vector_value.h"

#include <sstream>
#include <stdexcept>

// libMesh includes
#include "libmesh/libmesh.h"
#include "libmesh/exodusII_io.h"
#include "libmesh/equation_systems.h"
#include "libmesh/nonlinear_implicit_system.h"
#include "libmesh/explicit_system.h"
#include "libmesh/string_to_enum.h"
#include "libmesh/fe.h"

registerMooseAction("ZapdosApp", AddDriftDiffusionAction, "add_variable");
registerMooseAction("ZapdosApp", AddDriftDiffusionAction, "add_kernel");
registerMooseAction("ZapdosApp", AddDriftDiffusionAction, "add_aux_kernel");
registerMooseAction("ZapdosApp", AddDriftDiffusionAction, "add_bc");

template <>
InputParameters
validParams<AddDriftDiffusionAction>()
{
  MooseEnum families(AddVariableAction::getNonlinearVariableFamilies());
  MooseEnum orders(AddVariableAction::getNonlinearVariableOrders());

  InputParameters params = validParams<AddVariableAction>();
  //  params.addRequiredParam<unsigned int>("number", "The number of variables to add");
  params.addRequiredParam<std::vector<NonlinearVariableName>>(
      "Ions", "The names of the ions that should be added");
      /*
  params.addParam<std::vector<NonlinearVariableName>>(
      "em", "em", "The gives the electrons a variable name");
  params.addParam<std::vector<NonlinearVariableName>>(
      "potential", "potential", "The gives the potential a variable name");
  params.addParam<std::vector<NonlinearVariableName>>(
      "mean_en", "mean_en", "The gives the mean energy a variable name");
      */
  params.addParam<std::vector<NonlinearVariableName>>(
      "Neutrals", "The names of the neutrals that should be added");
  params.addRequiredParam<bool>("CRANE_Coupled",
      "Is CRANE being used for the chemisty?.");
  params.addParam<std::vector<SubdomainName>>("block",
      "The subdomain that this action applies to.");
  params.addParam<Real>("position_units", 1,
      "Units of position");
  params.addParam<bool>("using_offset",false,"Is the LogStabilizationMoles Kernel being used");
  params.addParam<Real>("offset", 20,
      "The offset parameter that goes into the exponential function");
  params.addRequiredParam<std::string>("potential_units",
      "Units of potential");
  params.addRequiredParam<bool>("use_moles",
      "Whether to convert from units of moles to #.");
  params.addParam<std::vector<std::string>>("Additional_Outputs",
      "Current list of available ouputs options in this action: Current, EField, ElectronTemperature");
  params.addParam<int>("component",
      "The component of the electric field to access. Accepts an integer");

  return params;
}

AddDriftDiffusionAction::AddDriftDiffusionAction(InputParameters params) : AddVariableAction(params) {}

void
AddDriftDiffusionAction::act()
{
  MooseSharedPointer<Action> action;
  MooseSharedPointer<MooseObjectAction> moose_object_action;

  std::vector<NonlinearVariableName> Ions =
      getParam<std::vector<NonlinearVariableName>>("Ions");
  std::vector<NonlinearVariableName> Neutrals =
      getParam<std::vector<NonlinearVariableName>>("Neutrals");
  std::vector<std::string> Outputs =
      getParam<std::vector<std::string>>("Additional_Outputs");

  bool CRANE_Coupled =
      getParam<bool>("CRANE_Coupled");

  bool Using_offset =
      getParam<bool>("using_offset");

  unsigned int number_ions = Ions.size();
  unsigned int number_neutrals = Neutrals.size();
  unsigned int number_outputs = Outputs.size();

  FEType fe_type(CONSTANT, MONOMIAL);

  if (_current_task == "add_variable")
  {
    for (unsigned int cur_num = 0; cur_num < number_ions; cur_num++)
    {
      //      std::string var_name = getShortName() + Moose::stringify(cur_num);
      std::string ion_name = Ions[cur_num];
      addVariable(ion_name);

      _problem->addAuxVariable(ion_name+"_density", fe_type);
    }

    for (unsigned int cur_num = 0; cur_num < number_neutrals; cur_num++)
    {
      //      std::string var_name = getShortName() + Moose::stringify(cur_num);
      std::string neutrals_name = Neutrals[cur_num];
      addVariable(neutrals_name);

      _problem->addAuxVariable(neutrals_name+"_density", fe_type);
    }

    addVariable("em");
    addVariable("mean_en");
    addVariable("potential");


    _problem->addAuxVariable("em_density", fe_type);
    _problem->addAuxVariable("position", fe_type);

    for (unsigned int cur_num = 0; cur_num < number_outputs; cur_num++)
    {
      std::string output_name = Outputs[cur_num];

      //AuxVariable for current
      if (output_name == "Current")
      {
        _problem->addAuxVariable("em_current", fe_type);
        for (unsigned int cur_num = 0; cur_num < number_ions; cur_num++)
        {
          //      std::string var_name = getShortName() + Moose::stringify(cur_num);
          std::string ion_name = Ions[cur_num];
          _problem->addAuxVariable(ion_name+"_current", fe_type);
        }
      }

      else if (output_name == "EField")
      {
        _problem->addAuxVariable("Efield", fe_type);
      }

      else if (output_name == "ElectronTemperature")
      {
        _problem->addAuxVariable("e_temp", fe_type);
      }

      else if (output_name != "Current" || output_name != "EField" || output_name != "ElectronTemperature")
      {
        mooseError("Currently this action does not have one of the desired outputs or spelling is incorrect. Please input the AuxKernel manually or check spelling.");
      }
    }
  }

  else if (_current_task == "add_kernel")
    {
      //Adding Kernels for the electrons
      InputParameters params = _factory.getValidParams("ElectronTimeDerivative");
      params.set<NonlinearVariableName>("variable") = "em";
      params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("ElectronTimeDerivative", "em_time_deriv", params);

      InputParameters params1 = _factory.getValidParams("EFieldAdvectionElectrons");
      params1.set<NonlinearVariableName>("variable") = "em";
      params1.set<std::vector<VariableName>>("potential") = {"potential"};
      params1.set<std::vector<VariableName>>("mean_en") = {"mean_en"};
      params1.set<Real>("position_units") = getParam<Real>("position_units");
      params1.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("EFieldAdvectionElectrons", "em_advection", params1);

      InputParameters params2 = _factory.getValidParams("CoeffDiffusionElectrons");
      params2.set<NonlinearVariableName>("variable") = "em";
      params2.set<std::vector<VariableName>>("mean_en") = {"mean_en"};
      params2.set<Real>("position_units") = getParam<Real>("position_units");
      params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("CoeffDiffusionElectrons", "em_diffusion", params2);

      if (Using_offset)
      {
        InputParameters params3 = _factory.getValidParams("LogStabilizationMoles");
        params3.set<NonlinearVariableName>("variable") = "em";
        params3.set<Real>("offset") = getParam<Real>("offset");
        params3.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("LogStabilizationMoles", "em_log_stabilization", params3);
      }

      if (CRANE_Coupled == false) //fix
      {
        InputParameters params = _factory.getValidParams("ElectronsFromIonization");
        params.set<NonlinearVariableName>("variable") = "em";
        params.set<std::vector<VariableName>>("potential") = {"potential"};
        params.set<std::vector<VariableName>>("mean_en") = {"mean_en"};
        params.set<std::vector<VariableName>>("em") = {"em"};
        params.set<Real>("position_units") = getParam<Real>("position_units");
        params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("ElectronsFromIonization", "em_ionization", params);
      }

      //Adding the diffusion Kernel for the potential
      InputParameters params4 = _factory.getValidParams("CoeffDiffusionLin");
      params4.set<NonlinearVariableName>("variable") = "potential";
      params4.set<Real>("position_units") = getParam<Real>("position_units");
      params4.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("CoeffDiffusionLin", "potential_diffusion", params4);

      InputParameters params10 = _factory.getValidParams("ChargeSourceMoles_KV");
      params10.set<NonlinearVariableName>("variable") = "potential";
      params10.set<std::vector<VariableName>>("charged") = {"em"};
      params10.set<std::string>("potential_units") =  getParam<std::string>("potential_units");
      params10.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("ChargeSourceMoles_KV", "em_charge_source", params10);

      //Adding Kernels for the electron mean energy
      InputParameters params5 = _factory.getValidParams("ElectronTimeDerivative");
      params5.set<NonlinearVariableName>("variable") = "mean_en";
      params5.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("ElectronTimeDerivative", "mean_en_time_deriv", params5);

      InputParameters params6 = _factory.getValidParams("EFieldAdvectionEnergy");
      params6.set<NonlinearVariableName>("variable") = "mean_en";
      params6.set<std::vector<VariableName>>("potential") = {"potential"};
      params6.set<std::vector<VariableName>>("em") = {"em"};
      params6.set<Real>("position_units") = getParam<Real>("position_units");
      params6.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("EFieldAdvectionEnergy", "mean_en_advection", params6);

      InputParameters params7 = _factory.getValidParams("CoeffDiffusionEnergy");
      params7.set<NonlinearVariableName>("variable") = "mean_en";
      params7.set<std::vector<VariableName>>("em") = {"em"};
      params7.set<Real>("position_units") = getParam<Real>("position_units");
      params7.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("CoeffDiffusionEnergy", "mean_en_diffusion", params7);

      InputParameters params8 = _factory.getValidParams("JouleHeating");
      params8.set<NonlinearVariableName>("variable") = "mean_en";
      params8.set<std::vector<VariableName>>("potential") = {"potential"};
      params8.set<std::vector<VariableName>>("em") = {"em"};
      params8.set<std::string>("potential_units") =  getParam<std::string>("potential_units");
      params8.set<Real>("position_units") = getParam<Real>("position_units");
      params8.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addKernel("JouleHeating", "mean_en_joule_heating", params8);

      if (Using_offset)
      {
        InputParameters params9 = _factory.getValidParams("LogStabilizationMoles");
        params9.set<NonlinearVariableName>("variable") = "mean_en";
        //params9.set<Real>("offset") = (getParam<Real>("offset") - 5);
        params9.set<Real>("offset") = (getParam<Real>("offset") );
        params9.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("LogStabilizationMoles", "mean_en_log_stabilization", params9);
      }

      if (CRANE_Coupled == false)
      {
        InputParameters params = _factory.getValidParams("ElectronEnergyLossFromIonization");
        params.set<NonlinearVariableName>("variable") = "mean_en";
        params.set<std::vector<VariableName>>("potential") = {"potential"};
        params.set<std::vector<VariableName>>("em") = {"em"};
        params.set<Real>("position_units") = getParam<Real>("position_units");
        params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("ElectronEnergyLossFromIonization", "mean_en_ionization", params);

        InputParameters params1 = _factory.getValidParams("ElectronEnergyLossFromElastic");
        params1.set<NonlinearVariableName>("variable") = "mean_en";
        params1.set<std::vector<VariableName>>("potential") = {"potential"};
        params1.set<std::vector<VariableName>>("em") = {"em"};
        params1.set<Real>("position_units") = getParam<Real>("position_units");
        params1.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("ElectronEnergyLossFromElastic", "mean_en_elastic", params1);

        InputParameters params2 = _factory.getValidParams("ElectronEnergyLossFromExcitation");
        params2.set<NonlinearVariableName>("variable") = "mean_en";
        params2.set<std::vector<VariableName>>("potential") = {"potential"};
        params2.set<std::vector<VariableName>>("em") = {"em"};
        params2.set<Real>("position_units") = getParam<Real>("position_units");
        params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
        _problem->addKernel("ElectronEnergyLossFromExcitation", "mean_en_excitation", params2);
      }

      //AuxKernels for electrons density and position
      InputParameters params11 = _factory.getValidParams("DensityMoles");
      params11.set<AuxVariableName>("variable") = "em_density";
      params11.set<std::vector<VariableName>>("density_log") = {"em"};
      params11.set<bool>("use_moles") = getParam<bool>("use_moles");
      params11.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
      _problem->addAuxKernel("DensityMoles", "em_density", params11);

      InputParameters params12 = _factory.getValidParams("Position");
      params12.set<AuxVariableName>("variable") = {"position"};
      params12.set<Real>("position_units") = getParam<Real>("position_units");
      _problem->addAuxKernel("Position", "position", params12);

      //Adding Kernels for the ions
      for (unsigned int cur_num = 0; cur_num < number_ions; cur_num++)
        {
          std::string ion_name = Ions[cur_num];

          InputParameters params = _factory.getValidParams("ElectronTimeDerivative");
          params.set<NonlinearVariableName>("variable") = ion_name;
          params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addKernel("ElectronTimeDerivative", ion_name+"_time_deriv", params);

          InputParameters params1 = _factory.getValidParams("EFieldAdvection");
          params1.set<NonlinearVariableName>("variable") = ion_name;
          params1.set<std::vector<VariableName>>("potential") = {"potential"};
          params1.set<Real>("position_units") = getParam<Real>("position_units");
          params1.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addKernel("EFieldAdvection", ion_name+"_advection", params1);

          InputParameters params2 = _factory.getValidParams("CoeffDiffusion");
          params2.set<NonlinearVariableName>("variable") = ion_name;
          params2.set<Real>("position_units") = getParam<Real>("position_units");
          params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addKernel("CoeffDiffusion", ion_name+"_diffusion", params2);

          if (Using_offset)
          {
            InputParameters params3 = _factory.getValidParams("LogStabilizationMoles");
            params3.set<NonlinearVariableName>("variable") = ion_name;
            params3.set<Real>("offset") = getParam<Real>("offset");
            params3.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
            _problem->addKernel("LogStabilizationMoles", ion_name+"_log_stabilization", params3);
          }

          InputParameters params4 = _factory.getValidParams("ChargeSourceMoles_KV");
          params4.set<NonlinearVariableName>("variable") = "potential";
          params4.set<std::vector<VariableName>>("charged") = {ion_name};
          params4.set<std::string>("potential_units") =  getParam<std::string>("potential_units");
          params4.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addKernel("ChargeSourceMoles_KV", ion_name+"_charge_source", params4);

            if (CRANE_Coupled == false)
            {
              InputParameters params = _factory.getValidParams("IonsFromIonization");
              params.set<NonlinearVariableName>("variable") = ion_name;
              params.set<std::vector<VariableName>>("potential") = {"potential"};
              params.set<std::vector<VariableName>>("mean_en") = {"mean_en"};
              params.set<std::vector<VariableName>>("em") = {"em"};
              params.set<Real>("position_units") = getParam<Real>("position_units");
              params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
              _problem->addKernel("IonsFromIonization", ion_name+"_ionization", params);
            }

            //AuxKernels for ion density
            InputParameters params11 = _factory.getValidParams("DensityMoles");
            params11.set<AuxVariableName>("variable") = ion_name+"_density";
            params11.set<std::vector<VariableName>>("density_log") = {ion_name};
            params11.set<bool>("use_moles") = getParam<bool>("use_moles");
            params11.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
            _problem->addAuxKernel("DensityMoles", ion_name+"_density", params11);
        }

        //Adding Kernels for the neutrals
        for (unsigned int cur_num = 0; cur_num < number_ions; cur_num++)
          {
            std::string neutral_name = Neutrals[cur_num];

            InputParameters params = _factory.getValidParams("ElectronTimeDerivative");
            params.set<NonlinearVariableName>("variable") = neutral_name;
            params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
            _problem->addKernel("ElectronTimeDerivative", neutral_name+"_time_deriv", params);

            InputParameters params1 = _factory.getValidParams("CoeffDiffusion");
            params1.set<NonlinearVariableName>("variable") = neutral_name;
            params1.set<Real>("position_units") = getParam<Real>("position_units");
            params1.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
            _problem->addKernel("CoeffDiffusion", neutral_name+"_diffusion", params1);

            if (Using_offset)
            {
              InputParameters params2 = _factory.getValidParams("LogStabilizationMoles");
              params2.set<NonlinearVariableName>("variable") = neutral_name;
              //params2.set<Real>("offset") = (getParam<Real>("offset") + 10);
              params2.set<Real>("offset") = (getParam<Real>("offset"));
              params2.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
              _problem->addKernel("LogStabilizationMoles", neutral_name+"_log_stabilization", params2);
            }

            //AuxKernels for neutrals density
            InputParameters params11 = _factory.getValidParams("DensityMoles");
            params11.set<AuxVariableName>("variable") = neutral_name+"_density";
            params11.set<std::vector<VariableName>>("density_log") = {neutral_name};
            params11.set<bool>("use_moles") = getParam<bool>("use_moles");
            params11.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
            _problem->addAuxKernel("DensityMoles", neutral_name+"_density", params11);
          }
    }

  else if (_current_task == "add_aux_kernel")
    {
      for (unsigned int cur_num = 0; cur_num < number_outputs; cur_num++)
      {
        std::string output_name = Outputs[cur_num];

        //AuxKernels for current
        if (output_name == "Current")
        {
          InputParameters params = _factory.getValidParams("Current");
          params.set<AuxVariableName>("variable") = "em_current";
          params.set<std::vector<VariableName>>("potential") = {"potential"};
          params.set<std::vector<VariableName>>("density_log") = {"em"};
          params.set<Real>("position_units") = getParam<Real>("position_units");
          params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addAuxKernel("Current", "em_current", params);

          for (unsigned int cur_num = 0; cur_num < number_ions; cur_num++)
            {
              std::string ion_name = Ions[cur_num];

              InputParameters params = _factory.getValidParams("Current");
              params.set<AuxVariableName>("variable") = ion_name+"_current";
              params.set<std::vector<VariableName>>("potential") = {"potential"};
              params.set<std::vector<VariableName>>("density_log") = {ion_name};
              params.set<Real>("position_units") = getParam<Real>("position_units");
              params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
              _problem->addAuxKernel("Current", ion_name+"_current", params);
            }
        }

        else if (output_name == "EField")
        {
          InputParameters params = _factory.getValidParams("Efield");
          params.set<AuxVariableName>("variable") = "Efield";
          params.set<std::vector<VariableName>>("potential") = {"potential"};
          params.set<Real>("position_units") = getParam<Real>("position_units");
          params.set<int>("component") = getParam<int>("component");
          params.set<std::string>("potential_units") =  getParam<std::string>("potential_units");
          params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addAuxKernel("Efield", "Efield", params);
        }

        else if (output_name == "ElectronTemperature")
        {
          InputParameters params = _factory.getValidParams("ElectronTemperature");
          params.set<AuxVariableName>("variable") = "e_temp";
          params.set<std::vector<VariableName>>("electron_density") = {"em"};
          params.set<std::vector<VariableName>>("mean_en") = {"mean_en"};
          params.set<std::vector<SubdomainName>>("block") = getParam<std::vector<SubdomainName>>("block");
          _problem->addAuxKernel("ElectronTemperature", "e_temp", params);
        }


      }

    }

  /*
  else if (_current_task == "add_bc")
    {
      for (unsigned int cur_num = 0; cur_num < number; cur_num++)
        {
          std::string var_name = variables[cur_num];

          InputParameters params = _factory.getValidParams("DirichletBC");
          params.set<NonlinearVariableName>("variable") = var_name;
          params.set<std::vector<BoundaryName> >("boundary").push_back("left");
          params.set<Real>("value") = 0;

          _problem->addBoundaryCondition("DirichletBC", var_name + "_left", params);

          params.set<std::vector<BoundaryName> >("boundary")[0] = "right";
          params.set<Real>("value") = 1;

          _problem->addBoundaryCondition("DirichletBC", var_name + "_right", params);
        }
        } */
}
