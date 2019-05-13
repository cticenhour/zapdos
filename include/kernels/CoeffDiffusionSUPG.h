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

#ifndef COEFFDIFFUSIONSUPG_H
#define COEFFDIFFUSIONSUPG_H

#include "ADKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class CoeffDiffusionSUPG;

declareADValidParams(CoeffDiffusionSUPG);

template <ComputeStage compute_stage>
class CoeffDiffusionSUPG : public ADKernelPlasmaSUPG<compute_stage>
{
public:
  CoeffDiffusionSUPG(const InputParameters & parameters);

protected:
  //virtual ADResidual computeQpResidual() override;
  virtual ADResidual precomputeQpStrongResidual() override;


  // Material properties

  Real _r_units;

  const ADVariableSecond & _second_var;

  const MaterialProperty<Real> & _diff;

  //usingKernelMembers;
  usingKernelPlasmaSUPGMembers;
};

#endif // EFIELDADVECTION_H
