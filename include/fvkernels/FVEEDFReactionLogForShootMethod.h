
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVEEDFReactionLogForShootMethod : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVEEDFReactionLogForShootMethod(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADMaterialProperty<Real> & _reaction_coeff;

  const ADVariableValue & _em;
  Real _coefficient;
};
