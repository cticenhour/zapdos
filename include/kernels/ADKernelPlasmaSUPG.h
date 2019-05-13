//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ADKERNELPLASMASUPG_H
#define ADKERNELPLASMASUPG_H

#include "ADKernelStabilized.h"

#define usingTemplKernelPlasmaSUPGMembers(type)                                                    \
  usingTemplKernelStabilizedMembers(type);                                                         \
  using ADKernelPlasmaSUPGTempl<type, compute_stage>::_grad_potential;                             \
  using ADKernelPlasmaSUPGTempl<type, compute_stage>::_mu;                                         \
  using ADKernelPlasmaSUPGTempl<type, compute_stage>::_tau
#define usingKernelPlasmaSUPGMembers usingTemplKernelPlasmaSUPGMembers(Real)
#define usingVectorKernelPlasmaSUPGMembers usingTemplKernelPlasmaSUPGMembers(RealVectorValue)

template <typename, ComputeStage>
class ADKernelPlasmaSUPGTempl;

template <ComputeStage compute_stage>
using ADKernelPlasmaSUPG = ADKernelPlasmaSUPGTempl<Real, compute_stage>;
template <ComputeStage compute_stage>
using ADVectorKernelPlasmaSUPG = ADKernelPlasmaSUPGTempl<RealVectorValue, compute_stage>;

declareADValidParams(ADKernelPlasmaSUPG);
declareADValidParams(ADVectorKernelPlasmaSUPG);

template <typename T, ComputeStage compute_stage>
class ADKernelPlasmaSUPGTempl : public ADKernelStabilizedTempl<T, compute_stage>
{
public:
  ADKernelPlasmaSUPGTempl(const InputParameters & parameters);

protected:
  ADRealVectorValue virtual computeQpStabilization() override;

  const ADMaterialProperty(Real) & _tau;
  //const ADVectorVariableGradient & _grad_potential;
  const ADVariableGradient & _grad_potential;
  const MaterialProperty<Real> & _mu;
  Real _r_units;

  usingTemplKernelStabilizedMembers(T);
};

#endif /* ADKernelPlasmaSUPG_H */
