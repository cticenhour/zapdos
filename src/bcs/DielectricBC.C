//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DielectricBC.h"

registerMooseObject("ZapdosApp", DielectricBC);

template <>
InputParameters
validParams<DielectricBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("dielectric_constant", "The dielectric constant of the material.");
  params.addRequiredParam<Real>("thickness", "The thickness of the material.");
  params.addRequiredCoupledVar("surface_charge", "The surface charge.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  return params;
}

DielectricBC::DielectricBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _r_units(1. / getParam<Real>("position_units")),
    _epsilon_d(getParam<Real>("dielectric_constant")),
    _thickness(getParam<Real>("thickness")),
    _sigma(coupledValue("surface_charge")),
    _sigma_id(coupled("surface_charge"))
{
}

Real
DielectricBC::computeQpResidual()
{
  return _test[_i][_qp]  * _r_units * ( (_epsilon_d/_thickness)*_u[_qp] -  _sigma[_qp] ) / 8.8542e-12;
}

Real
DielectricBC::computeQpJacobian()
{
  return _test[_i][_qp]  * _r_units * ( (_epsilon_d/_thickness)*_phi[_j][_qp] ) / 8.8542e-12;
}

Real
DielectricBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _sigma_id)
  {
    return _test[_i][_qp]  * _r_units * ( -_phi[_j][_qp] ) / 8.8542e-12;
  }

  else
    return 0.0;
}
