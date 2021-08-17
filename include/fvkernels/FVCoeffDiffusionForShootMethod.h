
#pragma once

#include "FVFluxKernel.h"

class FVCoeffDiffusionForShootMethod : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVCoeffDiffusionForShootMethod(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const MooseVariableFieldBase & _density_var;
  const ADMaterialProperty<Real> & _diff_elem;
  const ADMaterialProperty<Real> & _diff_neighbor;
  const Real _r_units;
};
