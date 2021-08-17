
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVChargeSourceMoles_KVNonLog : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVChargeSourceMoles_KVNonLog(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

protected:
  /// Coupled variable
  const MooseVariableFieldBase & _charged_var;
  const ADVariableValue & _charged;

  /// Material properties (regular because these are constants)
  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _sgn;
  const MaterialProperty<Real> & _N_A;

  /// Units scaling
  const std::string & _potential_units;
  Real _voltage_scaling;
};
