//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVLymberopoulosElectronBCNonLog.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVLymberopoulosElectronBCNonLog);

InputParameters
FVLymberopoulosElectronBCNonLog::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("ks", "The recombination coefficient");
  params.addRequiredParam<Real>("gamma", "The secondary electron coefficient");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredCoupledVar("ion", "The ion density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Simpified kinetic electron boundary condition"
                             "(Based on DOI: https://doi.org/10.1063/1.352926)");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVLymberopoulosElectronBCNonLog::FVLymberopoulosElectronBCNonLog(const InputParameters & parameters)
  : FVFluxBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _ks(getParam<Real>("ks")),
    _gamma(getParam<Real>("gamma")),

    _sign(1)
{

  _num_ions = coupledComponents("ion");

  // Resize the vectors to store _num_ions values:
  _ion_elem.resize(_num_ions);
  _ion_neighbor.resize(_num_ions);
  _muion_elem.resize(_num_ions);
  _muion_neighbor.resize(_num_ions);
  _sgnion.resize(_num_ions);

  // Retrieve the values for each ion and store in the relevant vectors.
  // Note that these need to be dereferenced to get the values inside the
  // main body of the code.
  // e.g. instead of "_ip[_qp]" it would be "(*_ip[i])[_qp]", where "i"
  // refers to a single ion species.
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    _ion_elem[i] = &adCoupledValue("ion", i);
    _ion_neighbor[i] = &adCoupledNeighborValue("ion", i);
    //_muion_elem[i] = &getADMaterialProperty<Real>("mu" + (*getVar("ion", i)).name());
    //_muion_neighbor[i] = &getNeighborADMaterialProperty<Real>("mu" + (*getVar("ion", i)).name());
    //_sgnion[i] = &getMaterialProperty<Real>("sgn" + (*getVar("ion", i)).name());
    _muion_elem[i] = &getADMaterialProperty<Real>("mu" + (*getFieldVar("ion", i)).name());
    _muion_neighbor[i] = &getNeighborADMaterialProperty<Real>("mu" + (*getFieldVar("ion", i)).name());
    _sgnion[i] = &getMaterialProperty<Real>("sgn" + (*getFieldVar("ion", i)).name());
  }

  using namespace Moose::FV;

  const auto & advected_interp_method = getParam<MooseEnum>("advected_interp_method");
  if (advected_interp_method == "average")
    _advected_interp_method = InterpMethod::Average;
  else if (advected_interp_method == "upwind")
    _advected_interp_method = InterpMethod::Upwind;
  else
    mooseError("Unrecognized interpolation type ",
               static_cast<std::string>(advected_interp_method));
}

ADReal
FVLymberopoulosElectronBCNonLog::computeQpResidual()
{
  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info);
  using namespace Moose::FV;

  _ion_flux.zero();
  for (unsigned int i = 0; i < _num_ions; ++i)
  {
    ADReal muion;
    interpolate(InterpMethod::Average,
                muion,
                (*_muion_elem[i])[_qp],
                (*_muion_neighbor[i])[_qp],
                *_face_info,
                true);

    ADReal ion_face;
    interpolate(
        _advected_interp_method,
        ion_face,
        (*_ion_elem[i])[_qp],
        (*_ion_neighbor[i])[_qp],
        grad_potential,
        *_face_info,
        true);

    _ion_flux += (*_sgnion[i])[_qp] * muion * -grad_potential * _r_units *
                 ion_face;
  }

  ADReal u_interface;
  interpolate(InterpMethod::Average,
              u_interface,
              _u[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  return _r_units *
         (_sign * _ks * u_interface -
          _gamma * _ion_flux * _normal);
}
