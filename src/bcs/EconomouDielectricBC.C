//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EconomouDielectricBC.h"

registerMooseObject("ZapdosApp", EconomouDielectricBC);

template <>
InputParameters
validParams<EconomouDielectricBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("dielectric_constant", "The dielectric constant of the material.");
  params.addRequiredParam<Real>("thickness", "The thickness of the material.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("mean_en", "The mean energy.");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addRequiredCoupledVar("Efield", "The EField.");
  params.addParam<Real>("users_gamma", "A secondary electron emission coeff. only used for this BC.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  //params.addRequiredCoupledVar("surface_charge", "The surface charge on the boundary.");
  return params;
}

EconomouDielectricBC::EconomouDielectricBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _r_units(1. / getParam<Real>("position_units")),

    _mean_en(coupledValue("mean_en")),
    _mean_en_id(coupled("mean_en")),
    _em(coupledValue("em")),
    _em_id(coupled("em")),
    _ip(coupledValue("ip")),
    _ip_var(*getVar("ip", 0)),
    _ip_id(coupled("ip")),
    _E_dot(coupledDot("Efield")),
    _dE_dot(coupledDotDu("Efield")),
    _u_dot(_var.uDot()),
    _du_dot_du(_var.duDotDu()),

    _e(getMaterialProperty<Real>("e")),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name())),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _massem(getMaterialProperty<Real>("massem")),
    _user_se_coeff(getParam<Real>("users_gamma")),

    _epsilon_d(getParam<Real>("dielectric_constant")),
    _thickness(getParam<Real>("thickness")),
    _a(0.5),
    _ion_flux(0),
    _v_thermal(0),
    _em_flux(0),
    _d_ion_flux_du(0),
    _d_v_thermal_d_mean_en(0),
    _d_em_flux_d_mean_en(0),
    _d_v_thermal_d_em(0),
    _d_em_flux_d_em(0),
    _d_ion_flux_d_ip(0),
    _d_em_flux_d_ip(0),
    _potential_units(getParam<std::string>("potential_units"))

{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000;
}

Real
EconomouDielectricBC::computeQpResidual()
{
  if (_normals[_qp] * _sgnip[_qp] * -_grad_u[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  _ion_flux = (_a * _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * _r_units *
              std::exp(_ip[_qp]));

  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

  _em_flux = (0.25 * _v_thermal * std::exp(_em[_qp]) * _normals[_qp]) - (_user_se_coeff * _ion_flux);

  return _test[_i][_qp]  * _r_units * ((_e[_qp] * _ion_flux - _e[_qp] * _em_flux) * _normals[_qp] / _voltage_scaling
          + 8.8542e-12 * _E_dot[_qp] - ((_epsilon_d/_thickness) * _u_dot[_qp]));
}

Real
EconomouDielectricBC::computeQpJacobian()
{
  if (_normals[_qp] * _sgnip[_qp] * -_grad_u[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  _d_ion_flux_du = (_a * _sgnip[_qp] * _muip[_qp] * -_grad_phi[_j][_qp] * _r_units *
              std::exp(_ip[_qp]));

  return _test[_i][_qp]  * _r_units * ((_e[_qp] * _d_ion_flux_du) * _normals[_qp] / _voltage_scaling
          + 8.8542e-12 * _dE_dot[_qp] - ((_epsilon_d/_thickness) * _du_dot_du[_qp])); //Need to fix
}

Real
EconomouDielectricBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _mean_en_id)
  {
    _v_thermal = std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) /
                           (M_PI * _massem[_qp]));
    _d_v_thermal_d_mean_en = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 *
                             std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]) *
                             _phi[_j][_qp];

    _d_em_flux_d_mean_en = (0.25 * _d_v_thermal_d_mean_en * std::exp(_em[_qp]) * _normals[_qp]);

    return _test[_i][_qp]  * _r_units * ( -_e[_qp] * _d_em_flux_d_mean_en) * _normals[_qp] / _voltage_scaling;

  }

  else if (jvar == _em_id)
  {
    _v_thermal =
        std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));
    _d_v_thermal_d_em = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 * std::exp(_mean_en[_qp] - _em[_qp]) /
                       (M_PI * _massem[_qp]) * -_phi[_j][_qp];

    _d_em_flux_d_em = ((0.25 * _d_v_thermal_d_em * std::exp(_em[_qp])
                      + 0.25 * _v_thermal * std::exp(_em[_qp]) * _phi[_j][_qp]) * _normals[_qp]);

    return _test[_i][_qp]  * _r_units * ( -_e[_qp] * _d_em_flux_d_em) * _normals[_qp] / _voltage_scaling;

  }

  else if (jvar == _ip_id)
  {
    if (_normals[_qp] * _sgnip[_qp] * -_grad_u[_qp] > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _d_ion_flux_d_ip = (_a * _sgnip[_qp] * _muip[_qp] * -_grad_u[_qp] * _r_units *
                        std::exp(_ip[_qp]) * _phi[_j][_qp]);

    _d_em_flux_d_ip =  -_user_se_coeff * _d_ion_flux_d_ip;

    return _test[_i][_qp]  * _r_units *
          (_e[_qp] * _d_ion_flux_d_ip - _e[_qp] * _d_em_flux_d_ip) * _normals[_qp] / _voltage_scaling;
  }


  else
    return 0.0;
}
