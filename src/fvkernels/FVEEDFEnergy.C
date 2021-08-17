
#include "FVEEDFEnergy.h"

registerMooseObject("ZapdosApp", FVEEDFEnergy);

InputParameters
FVEEDFEnergy::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("electrons", "The electron density.");
  params.addRequiredCoupledVar("target", "The target species.");
  params.addRequiredParam<Real>("threshold_energy", "Energy required for reaction to take place.");
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

FVEEDFEnergy::FVEEDFEnergy(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _reaction_name(getParam<std::string>("reaction")),
    _reaction_coefficient(getADMaterialProperty<Real>("k" + getParam<std::string>("number") + "_" +
                                                      getParam<std::string>("reaction"))),
    _em(adCoupledValue("electrons")),
    _target(adCoupledValue("target")),
    _threshold_energy(getParam<Real>("threshold_energy"))
{
}

ADReal
FVEEDFEnergy::computeQpResidual()
{
  return -_reaction_coefficient[_qp] * _em[_qp] * _target[_qp] *
         _threshold_energy;
}
