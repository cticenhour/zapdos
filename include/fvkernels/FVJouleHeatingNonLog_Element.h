
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVJouleHeatingNonLog_Element : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVJouleHeatingNonLog_Element(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  /// Position units
  const Real _r_units;
  const std::string & _potential_units;

  /// The diffusion coefficient (either constant or mixture-averaged)
  const ADMaterialProperty<Real> & _diff;
  const ADMaterialProperty<Real> & _mu;
  const ADVariableGradient & _grad_potential;
  const ADVariableValue & _em;
  const ADVariableGradient & _grad_em;

  Real _voltage_scaling;
};
