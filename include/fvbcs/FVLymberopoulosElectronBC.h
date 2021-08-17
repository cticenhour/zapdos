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

class FVLymberopoulosElectronBC : public FVFluxBC
{
public:
  FVLymberopoulosElectronBC(const InputParameters & parameters);

  static InputParameters validParams();

protected:
  ADReal computeQpResidual() override;

  Real _r_units;
  Real _ks;
  Real _gamma;

  // Coupled variables
  std::vector<const ADVariableValue *> _ion_elem;
  std::vector<const ADVariableValue *> _ion_neighbor;

  Real _sign;

  std::vector<const MaterialProperty<Real> *> _sgnion;

  std::vector<const ADMaterialProperty<Real> *> _muion_elem;
  std::vector<const ADMaterialProperty<Real> *> _muion_neighbor;

  unsigned int _num_ions;
  unsigned int _ip_index;
  std::vector<unsigned int>::iterator _iter;

  ADRealVectorValue _ion_flux;

  Moose::FV::InterpMethod _advected_interp_method;
};
