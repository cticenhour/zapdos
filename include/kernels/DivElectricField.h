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

#include "VectorKernel.h"

class DivElectricField;

template <>
InputParameters validParams<DivElectricField>();

// This kernel should only be used with species whose values are in the logarithmic form.

class DivElectricField : public VectorKernel
{
public:
  DivElectricField(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();

  Real _r_units;

  const MaterialProperty<Real> & _diffusivity;

  MooseVariable & _potential_var;

  const VariablePhiValue & _scalar_test;
};
