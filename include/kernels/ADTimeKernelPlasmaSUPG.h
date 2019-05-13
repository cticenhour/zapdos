//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ADTIMEKERNELPLASMASUPG_H
#define ADTIMEKERNELPLASMASUPG_H

#include "ADKernelStabilized.h"

#define usingTemplTimeKernelPlasmaSUPGMembers(type)                                                    \
  usingTemplKernelStabilizedMembers(type);                                                             \
  using ADTimeKernelPlasmaSUPGTempl<type, compute_stage>::_grad_potential;                             \
  using ADTimeKernelPlasmaSUPGTempl<type, compute_stage>::_mu;                                         \
  using ADTimeKernelPlasmaSUPGTempl<type, compute_stage>::_tau;                                        \
  using ADTimeKernelPlasmaSUPGTempl<type, compute_stage>::_u_dot
#define usingTimeKernelPlasmaSUPGMembers usingTemplTimeKernelPlasmaSUPGMembers(Real)
#define usingVectorTimeKernelPlasmaSUPGMembers usingTemplTimeKernelPlasmaSUPGMembers(RealVectorValue)

template <typename, ComputeStage>
class ADTimeKernelPlasmaSUPGTempl;

template <ComputeStage compute_stage>
using ADTimeKernelPlasmaSUPG = ADTimeKernelPlasmaSUPGTempl<Real, compute_stage>;
template <ComputeStage compute_stage>
using ADVectorTimeKernelPlasmaSUPG = ADTimeKernelPlasmaSUPGTempl<RealVectorValue, compute_stage>;

declareADValidParams(ADTimeKernelPlasmaSUPG);
declareADValidParams(ADVectorTimeKernelPlasmaSUPG);

template <typename T, ComputeStage compute_stage>
class ADTimeKernelPlasmaSUPGTempl : public ADKernelStabilizedTempl<T, compute_stage>
{
public:
  ADTimeKernelPlasmaSUPGTempl(const InputParameters & parameters);

protected:
  ADRealVectorValue virtual computeQpStabilization() override;

  const ADTemplateVariableValue & _u_dot;
  const ADMaterialProperty(Real) & _tau;
  //const ADVectorVariableGradient & _grad_potential;
  const ADVariableGradient & _grad_potential;
  const MaterialProperty<Real> & _mu;
  Real _r_units;

  usingTemplKernelStabilizedMembers(T);
};

#endif /* ADTimeKernelPlasmaSUPG_H */
