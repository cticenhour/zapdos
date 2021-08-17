
#pragma once

#include "FVFluxKernel.h"

class FVJouleHeating : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVJouleHeating(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  /// Position units
  const Real _r_units;
  const std::string & _potential_units;

  /// The diffusion coefficient (either constant or mixture-averaged)
  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;
  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  const ADVariableValue & _em_elem;
  const ADVariableValue & _em_neighbor;

  Real _voltage_scaling;

  Moose::FV::InterpMethod _advected_interp_method;
};
