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

#include "Kernel.h"

class ElectrostaticField;

template <>
InputParameters validParams<ElectrostaticField>();

class ElectrostaticField : public Kernel
{
public:
  ElectrostaticField(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  Real _r_units;

  VectorMooseVariable & _field_var;

  const VectorVariableValue & _electric_field;

  const VectorVariablePhiValue & _vector_test;

  const VectorVariablePhiGradient & _grad_vector_test;

  const VectorVariablePhiValue & _field_phi;

  unsigned int _field_id;
};
