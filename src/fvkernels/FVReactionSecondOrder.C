
#include "FVReactionSecondOrder.h"

registerMooseObject("ZapdosApp", FVReactionSecondOrder);

InputParameters
FVReactionSecondOrder::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("v", "The first variable that is reacting to create u.");
  params.addRequiredCoupledVar("w", "The second variable that is reacting to create u.");
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

FVReactionSecondOrder::FVReactionSecondOrder(const InputParameters & parameters)
  : FVElementalKernel(parameters),

    _v(adCoupledValue("v")),
    _w(adCoupledValue("w")),
    _reaction_coeff(getMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                                getParam<std::string>("reaction"))),
    _stoichiometric_coeff(getParam<Real>("coefficient"))
{
}

ADReal
FVReactionSecondOrder::computeQpResidual()
{
  return -_stoichiometric_coeff * _reaction_coeff[_qp] *
         _v[_qp] * _w[_qp];
}
