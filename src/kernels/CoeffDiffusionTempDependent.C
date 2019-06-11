#include "CoeffDiffusionTempDependent.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", CoeffDiffusionTempDependent);

template <>
InputParameters
validParams<CoeffDiffusionTempDependent>()
{
  InputParameters params = validParams<Diffusion>();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addCoupledVar("neutral_gas", "Name of the neutrial gas");
  params.addCoupledVar("potential", "The electric potential");
  return params;
}

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

CoeffDiffusionTempDependent::CoeffDiffusionTempDependent(const InputParameters & parameters)
  : Diffusion(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _charge(getMaterialProperty<Real>("sgn" + _var.name())),
    _massNeutral(getMaterialProperty<Real>("mass" + (*getVar("neutral_gas",0)).name())),
    _mass(getMaterialProperty<Real>("mass" + _var.name())),
    _kb(getMaterialProperty<Real>("k_boltz")),
    _T(getMaterialProperty<Real>("T" + _var.name())),
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _diffusivity(0),
    _temp(0),
    _d_temp_d_potential(0),
    _d_diffusivity_d_potential(0)
{
}

CoeffDiffusionTempDependent::~CoeffDiffusionTempDependent() {}

Real
CoeffDiffusionTempDependent::computeQpResidual()
{
  _temp = _T[_qp] + (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                           (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_potential[_qp] * _r_units).norm()),2) / _kb[_qp]);

  _diffusivity = _mu[_qp] * _kb[_qp] * _temp / (_charge[_qp] * 1.6022e-19);

  return -_diffusivity * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * -_grad_test[_i][_qp] * _r_units;
}

Real
CoeffDiffusionTempDependent::computeQpJacobian()
{
  _temp = _T[_qp] + (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                           (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_potential[_qp] * _r_units).norm()),2) / _kb[_qp]);

  _diffusivity = _mu[_qp] * _kb[_qp] * _temp / (_charge[_qp] * 1.6022e-19);

  return -_diffusivity * (std::exp(_u[_qp]) * _grad_phi[_j][_qp] * _r_units +
                               std::exp(_u[_qp]) * _phi[_j][_qp] * _grad_u[_qp] * _r_units) *
         -_grad_test[_i][_qp] * _r_units;
}

Real
CoeffDiffusionTempDependent::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _potential_id)
  {
    _d_temp_d_potential = (_mass[_qp] + _massNeutral[_qp]) / (5.0*_mass[_qp] + 3.0*_massNeutral[_qp]) *
                             (_massNeutral[_qp] * std::pow((_mu[_qp] * (_grad_phi[_j][_qp] * _r_units).norm()),2) / _kb[_qp]);

    _d_diffusivity_d_potential = _mu[_qp] * _kb[_qp] * _d_temp_d_potential / (_charge[_qp] * 1.6022e-19);

    return -_d_diffusivity_d_potential * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * -_grad_test[_i][_qp] * _r_units;
  }

  else
    return 0.;
}
