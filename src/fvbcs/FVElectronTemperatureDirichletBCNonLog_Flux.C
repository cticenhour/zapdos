//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVElectronTemperatureDirichletBCNonLog_Flux.h"
#include "Function.h"

registerMooseObject("ZapdosApp", FVElectronTemperatureDirichletBCNonLog_Flux);

InputParameters
FVElectronTemperatureDirichletBCNonLog_Flux::validParams()
{
  InputParameters params = FVFluxBC::validParams();

  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addClassDescription("Electron temperature boundary condition");
  return params;
}

FVElectronTemperatureDirichletBCNonLog_Flux::FVElectronTemperatureDirichletBCNonLog_Flux(const InputParameters & parameters)
  : FVFluxBC(parameters),

  _em(adCoupledValue("em")),
  _em_neighbor(adCoupledValue("em")),
  _value(getParam<Real>("value"))
{
}

ADReal
FVElectronTemperatureDirichletBCNonLog_Flux::computeQpResidual()
{

  using namespace Moose::FV;

  ADReal u_face;
  interpolate(InterpMethod::Average,
              u_face,
              _u[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  ADReal em_face;
  interpolate(InterpMethod::Average,
              em_face,
              _em[_qp],
              _em_neighbor[_qp],
              *_face_info,
              true);

  return 2.0 / 3 * (u_face / em_face) - _value;
}
