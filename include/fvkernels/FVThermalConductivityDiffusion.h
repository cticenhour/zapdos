
#pragma once

#include "FVFluxKernel.h"

class FVThermalConductivityDiffusion : public FVFluxKernel
{
public:
  static InputParameters validParams();
  FVThermalConductivityDiffusion(const InputParameters & params);

protected:
  virtual ADReal computeQpResidual() override;

  const Real _r_units;
  const Real _coeff;

  const ADMaterialProperty<Real> & _diffem_elem;
  const ADMaterialProperty<Real> & _diffem_neighbor;

  const ADVariableValue & _em_elem;
  const ADVariableValue & _em_neighbor;


  //Moose::FV::InterpMethod _advected_interp_method;
};
