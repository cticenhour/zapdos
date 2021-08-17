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

class DensityMolesLin : public AuxKernel
{
public:
  DensityMolesLin(const InputParameters & parameters);

  static InputParameters validParams();

  virtual ~DensityMolesLin() {}

protected:
  virtual Real computeValue() override;

  bool _convert_moles;
  const MaterialProperty<Real> & _N_A;
  const VariableValue & _density;
};
