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
