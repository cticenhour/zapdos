//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "SurfaceChargeBC.h"

registerMooseObject("ZapdosApp", SurfaceChargeBC);

template <>
InputParameters
validParams<SurfaceChargeBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<std::string>("species", "The name of species inducing the current.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  return params;
}

SurfaceChargeBC::SurfaceChargeBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _surface_charge(getMaterialProperty<Real>("surface_charge"+getParam<std::string>("species"))),
    _potential_units(getParam<std::string>("potential_units"))
{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000;
}

Real
SurfaceChargeBC::computeQpResidual()
{
  return _test[_i][_qp]  * _r_units * _surface_charge[_qp] / (8.8542e-12 * _voltage_scaling);
}
