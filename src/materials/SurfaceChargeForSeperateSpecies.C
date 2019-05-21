
#include "SurfaceChargeForSeperateSpecies.h"
#include "MooseUtils.h"

registerMooseObject("ZapdosApp", SurfaceChargeForSeperateSpecies);

template <>
InputParameters
validParams<SurfaceChargeForSeperateSpecies>()
{
  InputParameters params = validParams<Material>();

  params.addRequiredParam<std::string>("species", "The name of species inducing the current.");
  params.addRequiredParam<bool>("species_em",
                      "Is the species inducing the surface charge electrons?");

  params.addCoupledVar("potential", "The potential for calculating the electron velocity");
  params.addCoupledVar("em", "Species concentration needed to calculate the poisson source");
  params.addCoupledVar("mean_en", "The electron mean energy in log form.");
  params.addCoupledVar("ip", "The ion density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");

  return params;
}

SurfaceChargeForSeperateSpecies::SurfaceChargeForSeperateSpecies(const InputParameters & parameters)
  : Material(parameters),


    _e(getMaterialProperty<Real>("e")),
    _r_units(1. / getParam<Real>("position_units")),
    _species_em(getParam<bool>("species_em")),

    _surface_charge(declareProperty<Real>("surface_charge"+getParam<std::string>("species"))),
    _surface_charge_old(getMaterialPropertyOld<Real>("surface_charge"+getParam<std::string>("species"))),

    _current(declareProperty<Real>("current"+getParam<std::string>("species"))),
    _current_old(getMaterialPropertyOld<Real>("current"+getParam<std::string>("species"))),

    //_d_current_d_potential(declareProperty<Real>("d_current"+getParam<std::string>("species")+"d_potential")),
    //_d_current_old_d_potential(getMaterialPropertyOld<Real>("d_current"+getParam<std::string>("species")+"d_potential")),
    //_d_current_d_em(declareProperty<Real>("d_current"+getParam<std::string>("species")+"d_em")),
    //_d_current_old_d_em(getMaterialPropertyOld<Real>("d_current"+getParam<std::string>("species")+"d_em")),
    //_d_current_d_ip(declareProperty<Real>("d_current"+getParam<std::string>("species")+"d_ip")),
    //_d_current_old_d_ip(getMaterialPropertyOld<Real>("d_current"+getParam<std::string>("species")+"d_ip")),
    //_d_current_d_mean_en(declareProperty<Real>("d_current"+getParam<std::string>("species")+"d_mean_en")),
    //_d_current_old_d_mean_en(getMaterialPropertyOld<Real>("d_current"+getParam<std::string>("species")+"d_mean_en")),

    _grad_potential(isCoupled("potential") ? coupledGradient("potential") : _grad_zero),
    _em(isCoupled("em") ? coupledValue("em") : _zero),
    _ip(isCoupled("ip") ? coupledValue("ip") : _zero),
    _ip_var(*getVar("ip", 0)),
    _grad_em(isCoupled("em") ? coupledGradient("em") : _grad_zero),
    _grad_ip(isCoupled("ip") ? coupledGradient("ip") : _grad_zero),
    _mean_en(isCoupled("mean_en") ? coupledValue("mean_en") : _zero),

    _muem(getMaterialProperty<Real>("muem")),
    _diffem(getMaterialProperty<Real>("diffem")),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _diffip(getMaterialProperty<Real>("diff" + _ip_var.name())),

    _sgnem(getMaterialProperty<Real>("sgnem")),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name()))


{
}

void
SurfaceChargeForSeperateSpecies::initQpStatefulProperties()
{
  _surface_charge[_qp] = 0.0;
  _current[_qp] = 0.0;
}

void
SurfaceChargeForSeperateSpecies::computeQpProperties()
{

  Real integral = getIntegralValue();

  _surface_charge[_qp] = _surface_charge_old[_qp] + integral;

}

Real
SurfaceChargeForSeperateSpecies::getIntegralValue()
{
  Real integral_value = 0.0;

  if (_species_em)
  {
  _current[_qp] = _e[_qp] * (_sgnem[_qp] * _muem[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_em[_qp]) -
              _diffem[_qp] * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units) * _normals[_qp];
  }
  else
  {
    _current[_qp] = _e[_qp] * (_sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_ip[_qp]) -
                _diffip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp] * _r_units) * _normals[_qp];
  }

  //integrating based on trapezoidal rule
    integral_value += 0.5 * _current[_qp] * _dt;
    integral_value += 0.5 * _current_old[_qp] * _dt;


  return integral_value;
}

/*
Real
SurfaceChargeForSeperateSpecies::getIntegralPotentialDerivativeValue()
{
  Real integral_value = 0.0;

  if (isCoupled("em"))
  {
    _d_current_d_potential[_qp] = _e[_qp] * (_sgnem[_qp] * _muem[_qp] * -_grad_phi[_j][_qp] * _r_units * std::exp(_em[_qp]));
  }
  else
  {
    _d_current_d_potential[_qp] = _e[_qp] * (_sgnip[_qp] * _muip[_qp] * -_grad_phi[_j][_qp] * _r_units * std::exp(_ip[_qp]));
  }

  //integrating based on trapezoidal rule
    integral_value += 0.5 * _d_current_d_potential[_qp] * _dt;
    integral_value += 0.5 * _d_current_old_d_potential[_qp] * _dt;


  return integral_value;
}

Real
SurfaceChargeForSeperateSpecies::getIntegralElectronDerivativeValue()
{
  Real integral_value = 0.0;

  if (isCoupled("em"))
  {
    _d_actual_mean_en_d_u = std::exp(_mean_en[_qp] - _u[_qp]) * -_phi[_j][_qp];
    _d_muem_d_u = _d_muem_d_actual_mean_en[_qp] * _d_actual_mean_en_d_u;

    _d_diffem_d_u =
        _d_diffem_d_actual_mean_en[_qp] * std::exp(_mean_en[_qp] - _u[_qp]) * -_phi[_j][_qp];

    _d_current_d_em[_qp] = _e[_qp] * (_d_muem_d_u * _sigem[_qp] * std::exp(_em[_qp]) * -_grad_potential[_qp] * _r_units +
                        _muem[_qp] * _sigem[_qp] * std::exp(_em[_qp]) * _phi[_j][_qp] * -_grad_potential[_qp] * _r_units -
  }
  else
  {
    _d_current_d_em[_qp] = 0;
  }

  //integrating based on trapezoidal rule
    integral_value += 0.5 * _d_current_d_em[_qp] * _dt;
    integral_value += 0.5 * _d_current_old_d_em[_qp] * _dt;


  return integral_value;
}
*/
