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

#include "CustomPosition.h"

registerMooseObject("ZapdosApp", CustomPosition);

template <>
InputParameters
validParams<CustomPosition>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addRequiredParam<Real>("CustomPosition_units", "Units of CustomPosition.");
  params.addRequiredParam<int>("component",
                               "The component of the CustomPosition direction. Accepts an integer");

  return params;
}

CustomPosition::CustomPosition(const InputParameters & parameters)
  : AuxKernel(parameters),
    _r_units(1. / getParam<Real>("CustomPosition_units")),
    _component(getParam<int>("component"))
{
}

Real
CustomPosition::computeValue()
{
  if (isNodal())
    return (*_current_node)(_component) / _r_units;
  else
    return _q_point[_qp](_component) / _r_units;
}
