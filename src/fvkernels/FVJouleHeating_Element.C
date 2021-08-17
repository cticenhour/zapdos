
#include "FVJouleHeating_Element.h"

registerMooseObject("ZapdosApp", FVJouleHeating_Element);

InputParameters
FVJouleHeating_Element::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("potential", "The electron density.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription(
      "Joule heating term for electrons (densities must be in log form), where the Jacobian is "
      "computed using forward automatic differentiation.");

  return params;
}

FVJouleHeating_Element::FVJouleHeating_Element(const InputParameters & parameters)
  : FVElementalKernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),
    _potential_units(getParam<std::string>("potential_units")),
    _diff(getADMaterialProperty<Real>("diffem")),
    _mu(getADMaterialProperty<Real>("muem")),
    _grad_potential(adCoupledGradient("potential")),
    _em(adCoupledValue("em")),
    _grad_em(adCoupledGradient("em"))
{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000.;
  else
    mooseError("Potential units " + _potential_units + " not valid! Use V or kV.");
}

ADReal
FVJouleHeating_Element::computeQpResidual()
{
  return -_grad_potential[_qp] * _r_units * _voltage_scaling *
         (-_mu[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_em[_qp]) -
          _diff[_qp] * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units);
}
