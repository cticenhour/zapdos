//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVLymberopoulosIonBC.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVLymberopoulosIonBC);

InputParameters
FVLymberopoulosIonBC::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Simpified kinetic ion boundary condition"
                             "(Based on DOI: https://doi.org/10.1063/1.352926)");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVLymberopoulosIonBC::FVLymberopoulosIonBC(const InputParameters & parameters)
  : FVFluxBC(parameters),

  _r_units(1. / getParam<Real>("position_units")),
  _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
  _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name()))
{
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
FVLymberopoulosIonBC::computeQpResidual()
{

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info);
  using namespace Moose::FV;

  ADReal mobility;
  interpolate(InterpMethod::Average,
              mobility,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  ADReal u_interface;
  interpolate(
      _advected_interp_method,
      u_interface,
      std::exp(_u[_qp]),
      std::exp(_u_neighbor[_qp]),
      grad_potential,
      *_face_info,
      true);

  return  _r_units * mobility * -grad_potential * _r_units *
         u_interface * _normal;
}
