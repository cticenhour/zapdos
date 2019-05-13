//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ADMaterialsPlasmaSUPG_H
#define ADMaterialsPlasmaSUPG_H

#include "ADMaterial.h"

template <ComputeStage>
class ADMaterialsPlasmaSUPG;

declareADValidParams(ADMaterialsPlasmaSUPG);

template <ComputeStage compute_stage>
class ADMaterialsPlasmaSUPG : public ADMaterial<compute_stage>
{
public:
  ADMaterialsPlasmaSUPG(const InputParameters & parameters);

protected:
  virtual void computeProperties() override;
  virtual void computeQpProperties() override;
  void computeHMax();

  const Real _alpha;
  ADMaterialProperty(Real) & _tau;
  Real _r_units;
  const MaterialProperty<Real> & _mu;
  const ADVariableGradient & _grad_potential;
  //const ADVectorVariableGradient & _grad_potential;
  const MaterialProperty<Real> & _diff;
  bool _transient_term;

  ADReal _hmax;

  usingMaterialMembers;
};

#endif // ADMaterialsPlasmaSUPG_H
