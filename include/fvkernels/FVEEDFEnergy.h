
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVEEDFEnergy : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVEEDFEnergy(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  std::string _reaction_coeff_name;
  std::string _reaction_name;

  const ADMaterialProperty<Real> & _reaction_coefficient;
  const ADVariableValue & _em;
  const ADVariableValue & _target;

  // Threshold energy is just a parameter generally, though elastic collisions require a material property.
  Real _threshold_energy;
};
