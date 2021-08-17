
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVEEDFReaction : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVEEDFReaction(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADMaterialProperty<Real> & _reaction_coeff;

  const ADVariableValue & _em;
  const ADVariableValue & _target;
  Real _coefficient;
};
