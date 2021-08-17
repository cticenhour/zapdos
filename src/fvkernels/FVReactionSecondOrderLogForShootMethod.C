
#include "FVReactionSecondOrderLogForShootMethod.h"

registerMooseObject("ZapdosApp", FVReactionSecondOrderLogForShootMethod);

InputParameters
FVReactionSecondOrderLogForShootMethod::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("v", "The first variable that is reacting to create u.");
  params.addCoupledVar("density", "The accelerated density variable.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("coefficient", "The stoichiometric coeffient.");
  params.addParam<std::string>(
      "number",
      "",
      "The reaction number. Optional, just for material property naming purposes. If a single "
      "reaction has multiple different rate coefficients (frequently the case when multiple "
      "species are lumped together to simplify a reaction network), this will prevent the same "
      "material property from being declared multiple times.");

  return params;
}

FVReactionSecondOrderLogForShootMethod::FVReactionSecondOrderLogForShootMethod(const InputParameters & parameters)
  : FVElementalKernel(parameters),

    _density(adCoupledValue("density")),
    _density_id(coupled("density")),
    _v(adCoupledValue("v")),
    _v_id(coupled("v")),
    _reaction_coeff(getMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                                getParam<std::string>("reaction"))),
    _stoichiometric_coeff(getParam<Real>("coefficient"))
{
}

ADReal
FVReactionSecondOrderLogForShootMethod::computeQpResidual()
{
  Real power;

  power = 1.;
  if (_v_id == _density_id)
    power += 1.;

  return -_stoichiometric_coeff * _reaction_coeff[_qp] *
         std::exp(_v[_qp]) * _u[_qp];
}
