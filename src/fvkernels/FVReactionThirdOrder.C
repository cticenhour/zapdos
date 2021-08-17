
#include "FVReactionThirdOrder.h"

registerMooseObject("ZapdosApp", FVReactionThirdOrder);

InputParameters
FVReactionThirdOrder::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("v", "The first variable that is reacting.");
  params.addRequiredCoupledVar("w", "The second variable that is reacting.");
  params.addRequiredCoupledVar("x", "The third variable that is reacting.");
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

FVReactionThirdOrder::FVReactionThirdOrder(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _v(adCoupledValue("v")),
    _w(adCoupledValue("w")),
    _x(adCoupledValue("x")),
    _reaction_coeff(getMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                                getParam<std::string>("reaction"))),
    _stoichiometric_coeff(getParam<Real>("coefficient"))
{
}

ADReal
FVReactionThirdOrder::computeQpResidual()
{
  return -_stoichiometric_coeff * _reaction_coeff[_qp] *
         _v[_qp] * _w[_qp] * _x[_qp];
}
