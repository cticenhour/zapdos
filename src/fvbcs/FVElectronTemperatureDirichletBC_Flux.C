//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVElectronTemperatureDirichletBC_Flux.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVElectronTemperatureDirichletBC_Flux);

InputParameters
FVElectronTemperatureDirichletBC_Flux::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addClassDescription("Electron temperature boundary condition");
  return params;
}

FVElectronTemperatureDirichletBC_Flux::FVElectronTemperatureDirichletBC_Flux(const InputParameters & parameters)
  : FVFluxBC(parameters),

  _em(adCoupledValue("em")),
  _em_neighbor(adCoupledValue("em")),
  _value(getParam<Real>("value"))
{
}

ADReal
FVElectronTemperatureDirichletBC_Flux::computeQpResidual()
{

  using namespace Moose::FV;

  ADReal u_face;
  interpolate(InterpMethod::Average,
              u_face,
              std::exp(_u[_qp]),
              std::exp(_u_neighbor[_qp]),
              *_face_info,
              true);

  ADReal em_face;
  interpolate(InterpMethod::Average,
              em_face,
              std::exp(_em[_qp]),
              std::exp(_em_neighbor[_qp]),
              *_face_info,
              true);

  return 2.0 / 3 * (u_face / em_face) - _value;
}
