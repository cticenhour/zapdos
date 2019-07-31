//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ScaledReaction.h"

registerMooseObject("ZapdosApp", ScaledReaction);

template <>
InputParameters
validParams<ScaledReaction>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<Real>("collision_freq", "The ion-neutral collision frequency.");
  return params;
}

ScaledReaction::ScaledReaction(const InputParameters & parameters)
  : Kernel(parameters),

  _nu(getParam<Real>("collision_freq"))

{
}

Real
ScaledReaction::computeQpResidual()
{
  return _test[_i][_qp] * _nu * _u[_qp];
}

Real
ScaledReaction::computeQpJacobian()
{
  return _test[_i][_qp] * _nu * _phi[_j][_qp];
}
