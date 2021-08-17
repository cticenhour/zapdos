
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVReactionSecondOrderLogForShootMethod : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVReactionSecondOrderLogForShootMethod(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  const ADVariableValue & _density;
  unsigned int _density_id;
  const ADVariableValue & _v;
  unsigned int _v_id;

  const MaterialProperty<Real> & _reaction_coeff;
  Real _stoichiometric_coeff;
};
