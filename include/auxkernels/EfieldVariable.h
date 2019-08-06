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

#ifndef EfieldVariable_H
#define EfieldVariable_H

#include "AuxKernel.h"

// Forward Declarations
class EfieldVariable;

template <>
InputParameters validParams<EfieldVariable>();

/**
 * Constant auxiliary value
 */
class EfieldVariable : public AuxKernel
{
public:
  EfieldVariable(const InputParameters & parameters);

  virtual ~EfieldVariable() {}

protected:
  /**
   * AuxKernels MUST override computeValue.  computeValue() is called on
   * every quadrature point.  For Nodal Auxiliary variables those quadrature
   * points coincide with the nodes.
   */
  virtual Real computeValue();

  int _component;
  Real _r_units;

  /// The gradient of a coupled variable
  const VariableGradient & _grad_potential;

};

#endif // EfieldVariable_H
