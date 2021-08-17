
#pragma once

#include "FVFluxKernel.h"

class FVCoeffDiffusionNonLog : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVCoeffDiffusionNonLog(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;
  const Real _r_units;
};
