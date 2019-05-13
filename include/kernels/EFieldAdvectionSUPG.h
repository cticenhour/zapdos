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

#ifndef EFIELDADVECTIONSUPG_H
#define EFIELDADVECTIONSUPG_H

#include "ADKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class EFieldAdvectionSUPG;

declareADValidParams(EFieldAdvectionSUPG);

template <ComputeStage compute_stage>
class EFieldAdvectionSUPG : public ADKernelPlasmaSUPG<compute_stage>
{
public:
  EFieldAdvectionSUPG(const InputParameters & parameters);

protected:
  virtual ADResidual precomputeQpStrongResidual() override;


  // Material properties

  Real _r_units;

  //const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _sign;

  //const ADVariableGradient & _grad_potential;
  const ADVariableSecond & _second_potential;

  usingKernelPlasmaSUPGMembers;
};

#endif // EFIELDADVECTION_H
