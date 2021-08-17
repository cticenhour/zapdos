
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVReactionThirdOrderLog : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVReactionThirdOrderLog(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADVariableValue & _v;
  const ADVariableValue & _w;
  const ADVariableValue & _x;

  const MaterialProperty<Real> & _reaction_coeff;
  Real _stoichiometric_coeff;
};
