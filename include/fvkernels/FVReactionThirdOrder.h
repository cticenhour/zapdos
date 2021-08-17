
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVReactionThirdOrder : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVReactionThirdOrder(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADVariableValue & _v;
  const ADVariableValue & _w;
  const ADVariableValue & _x;

  const MaterialProperty<Real> & _reaction_coeff;
  Real _stoichiometric_coeff;
};
