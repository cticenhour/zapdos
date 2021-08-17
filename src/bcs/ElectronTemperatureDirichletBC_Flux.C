//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectronTemperatureDirichletBC_Flux.h"

registerMooseObject("ZapdosApp", ElectronTemperatureDirichletBC_Flux);

InputParameters
ElectronTemperatureDirichletBC_Flux::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addParam<Real>("penalty_value", 1.0, "The penalty value for the Dirichlet BC.");
  params.addClassDescription("Electron temperature boundary condition");
  return params;
}

ElectronTemperatureDirichletBC_Flux::ElectronTemperatureDirichletBC_Flux(const InputParameters & parameters)
  : ADIntegratedBC(parameters),

    _em(adCoupledValue("em")),
    _value(getParam<Real>("value")),
    _penalty_value(getParam<Real>("penalty_value"))
{
}

ADReal
ElectronTemperatureDirichletBC_Flux::computeQpResidual()
{
  return _test[_i][_qp] * _penalty_value *
         (2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) - _value);
}
