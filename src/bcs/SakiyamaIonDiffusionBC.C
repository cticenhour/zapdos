#include "SakiyamaIonDiffusionBC.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", SakiyamaIonDiffusionBC);

template <>
InputParameters
validParams<SakiyamaIonDiffusionBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  //params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addParam<Real>(
      "user_velocity", -1., "Optional parameter if user wants to specify the thermal velocity");

 params.addParam<bool>("variable_temp", false,
      "Does the temperature of the species change based on Wannier's formulation");
 params.addCoupledVar("neutral_gas", "Name of the neutrial gas");
 params.addCoupledVar("potential", "The electric potential");

  return params;
}

SakiyamaIonDiffusionBC::SakiyamaIonDiffusionBC(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    //_r(getParam<Real>("r")),

    _kb(getMaterialProperty<Real>("k_boltz")),
    _T(getMaterialProperty<Real>("T" + _var.name())),
    _mass(getMaterialProperty<Real>("mass" + _var.name())),
    _v_thermal(0),
    _user_velocity(getParam<Real>("user_velocity")),

    _massNeutral(getMaterialProperty<Real>("mass" + (*getVar("neutral_gas",0)).name())),
    _variable_temp(getParam<bool>("variable_temp")),
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _temp(0),
    _d_temp_d_potential(0),
    _d_v_thermal_d_potential(0)
{
}

Real
SakiyamaIonDiffusionBC::computeQpResidual()
{

  if (_variable_temp)
  {
    _temp = _T[_qp] + (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                             (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_potential[_qp] * _r_units).norm()),2) / _kb[_qp]);
  }
  else
  {
    _temp = _T[_qp];  // Needs to be changed.
  }

  if (_user_velocity > 0.)
    _v_thermal = _user_velocity;
  else
    _v_thermal = std::sqrt(8 * _kb[_qp] * _temp / (M_PI * _mass[_qp]));

  return _test[_i][_qp] * _r_units * 0.25 * _v_thermal * std::exp(_u[_qp]);
}

Real
SakiyamaIonDiffusionBC::computeQpJacobian()
{

  if (_variable_temp)
  {
    _temp = _T[_qp] + (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                             (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_potential[_qp] * _r_units).norm()),2) / _kb[_qp]);
  }
  else
  {
    _temp = _T[_qp];  // Needs to be changed.
  }

  if (_user_velocity > 0.)
    _v_thermal = _user_velocity;
  else
    _v_thermal = std::sqrt(8 * _kb[_qp] * _temp / (M_PI * _mass[_qp]));

  return _test[_i][_qp] * _r_units * 0.25 * _v_thermal * std::exp(_u[_qp]) *
         _phi[_j][_qp];
}

Real
SakiyamaIonDiffusionBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _potential_id)
  {
    if (_variable_temp)
    {
      _d_temp_d_potential = (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                               (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_phi[_j][_qp] * _r_units).norm()),2) / _kb[_qp]);

      _d_v_thermal_d_potential = std::sqrt(8 * _kb[_qp] * _d_temp_d_potential / (M_PI * _mass[_qp]));

      return _test[_i][_qp] * _r_units * 0.25 * _d_v_thermal_d_potential * std::exp(_u[_qp]);
    }
    else
    {
      return 0.0;
    }

  }

  else
    return 0.0;
}
