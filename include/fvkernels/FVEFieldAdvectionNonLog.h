
#pragma once

#include "FVFluxKernel.h"

class FVEFieldAdvectionNonLog : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVEFieldAdvectionNonLog(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  const MaterialProperty<Real> & _sign;
  const Real _r_units;

  Moose::FV::InterpMethod _advected_interp_method;
};
