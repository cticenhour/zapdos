//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef ElectronEnergyDirichletBC_H
#define ElectronEnergyDirichletBC_H

#include "NodalBC.h"

// Forward Declarations
class ElectronEnergyDirichletBC;

template <>
InputParameters validParams<ElectronEnergyDirichletBC>();

/**
 * Implements a simple coupled boundary condition where u=v on the boundary.
 */
class ElectronEnergyDirichletBC : public NodalBC
{
public:
  ElectronEnergyDirichletBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const VariableValue & _em;
  unsigned int _em_id;
  Real _value;
  Real _penalty_value;
};

#endif // ElectronEnergyDirichletBC_H
