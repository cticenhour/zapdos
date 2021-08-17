
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVReactionSecondOrder : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVReactionSecondOrder(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADVariableValue & _v;
  const ADVariableValue & _w;

  const MaterialProperty<Real> & _reaction_coeff;
  Real _stoichiometric_coeff;
};
