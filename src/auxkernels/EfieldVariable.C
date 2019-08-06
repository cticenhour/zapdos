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

#include "EfieldVariable.h"

registerMooseObject("ZapdosApp", EfieldVariable);

template <>
InputParameters
validParams<EfieldVariable>()
{
  InputParameters params = validParams<AuxKernel>();

  params.addRequiredCoupledVar("potential", "The potential");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<int>("component",
                               "The component of the electric field to access. Accepts an integer");

  return params;
}

EfieldVariable::EfieldVariable(const InputParameters & parameters)
  : AuxKernel(parameters),

    _component(getParam<int>("component")),
    _r_units(1. / getParam<Real>("position_units")),
    _grad_potential(coupledGradient("potential"))
{
}

Real
EfieldVariable::computeValue()
{
  return -_grad_potential[_qp](_component) * _r_units;
}
