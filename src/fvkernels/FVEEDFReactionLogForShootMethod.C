
#include "FVEEDFReactionLogForShootMethod.h"

registerMooseObject("ZapdosApp", FVEEDFReactionLogForShootMethod);

InputParameters
FVEEDFReactionLogForShootMethod::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("electrons", "The electron density.");
  params.addRequiredParam<Real>(
      "coefficient",
      "The number of species consumed or produced in this reaction.\ne.g. e + Ar -> e + e + Arp:\n "
      "coefficient of e is 1, coefficient of Ar is -1, and coefficient of Arp is 1.");
  params.addRequiredParam<std::string>("reaction", "Stores the full reaction equation.");
  params.addParam<std::string>(
      "number",
      "",
      "The reaction number. Optional, just for material property naming purposes. If a single "
      "reaction has multiple different rate coefficients (frequently the case when multiple "
      "species are lumped together to simplify a reaction network), this will prevent the same "
      "material property from being declared multiple times.");

  return params;
}

FVEEDFReactionLogForShootMethod::FVEEDFReactionLogForShootMethod(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _reaction_coeff(getADMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                                getParam<std::string>("reaction"))),
    _em(adCoupledValue("electrons")),
    _coefficient(getParam<Real>("coefficient"))
{
}

ADReal
FVEEDFReactionLogForShootMethod::computeQpResidual()
{
  return -_reaction_coeff[_qp] * std::exp(_em[_qp]) * _u[_qp] * _coefficient;
}
