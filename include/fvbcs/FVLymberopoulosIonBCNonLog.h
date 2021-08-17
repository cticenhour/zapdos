//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "FVFluxBC.h"

class Function;

class FVLymberopoulosIonBCNonLog : public FVFluxBC
{
public:
  FVLymberopoulosIonBCNonLog(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  Real _r_units;

  const ADMaterialProperty<Real> & _mu_elem;
  const ADMaterialProperty<Real> & _mu_neighbor;

  Moose::FV::InterpMethod _advected_interp_method;
};
