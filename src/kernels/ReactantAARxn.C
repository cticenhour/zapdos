//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ReactantAARxn.h"

registerMooseObject("ZapdosApp", ReactantAARxn);

InputParameters
ReactantAARxn::validParams()
{
  InputParameters params = ADKernel::validParams();
  params.addClassDescription("Generic second order reaction sink term for u in which two"
                             "molecules of u are consumed"
                             "(Densities must be in logarithmic form)");
  return params;
}

ReactantAARxn::ReactantAARxn(const InputParameters & parameters)
  : ADKernel(parameters),

    _reaction_coeff(getADMaterialProperty<Real>("k" + _var.name() + _var.name()))
{
}

ADReal
ReactantAARxn::computeQpResidual()
{
  return -_test[_i][_qp] * (-2.) * _reaction_coeff[_qp] * std::exp(_u[_qp]) * std::exp(_u[_qp]);
}
