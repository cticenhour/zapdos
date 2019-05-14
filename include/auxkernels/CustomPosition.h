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

#ifndef CUSTOMPOSITION_H
#define CUSTOMPOSITION_H

#include "AuxKernel.h"

// Forward Declarations
class CustomPosition;

template <>
InputParameters validParams<CustomPosition>();

/**
 * Function auxiliary value
 */
class CustomPosition : public AuxKernel
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CustomPosition(const InputParameters & parameters);

  virtual ~CustomPosition() {}

protected:
  Real _r_units;
  int _component;

  virtual Real computeValue();
};

#endif // CustomPosition_H
