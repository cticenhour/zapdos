<<<<<<< HEAD
//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
=======
/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/
>>>>>>> 3afd528a4c7afa746018a4cc26c57e5566f85c3a

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
