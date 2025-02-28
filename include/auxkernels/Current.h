//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "AuxKernel.h"

template <bool is_ad>
class CurrentTempl : public AuxKernel
{
public:
  CurrentTempl(const InputParameters & parameters);

  static InputParameters validParams();

  virtual ~CurrentTempl() {}
  virtual Real computeValue() override;

protected:
  const int _component;
  const Real _r_units;

  const MooseVariable & _density_var;
  const VariableValue & _density_log;
  const VariableGradient & _grad_density_log;
  const VariableGradient & _grad_potential;
  const GenericMaterialProperty<Real, is_ad> & _mu;
  const MaterialProperty<Real> & _sgn;
  const GenericMaterialProperty<Real, is_ad> & _diff;
  bool _art_diff;
};

typedef CurrentTempl<false> Current;
typedef CurrentTempl<true> ADCurrent;
