
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVEEDFReactionLog : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVEEDFReactionLog(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADMaterialProperty<Real> & _reaction_coeff;

  const ADVariableValue & _em;
  const ADVariableValue & _target;
  Real _coefficient;
};
