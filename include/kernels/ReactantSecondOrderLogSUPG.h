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

#ifndef REACTANTSECONDORDERLOGSUPG_H
#define REACTANTSECONDORDERLOGSUPG_H

#include "ADKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class ReactantSecondOrderLogSUPG;

declareADValidParams(ReactantSecondOrderLogSUPG);

template <ComputeStage compute_stage>
class ReactantSecondOrderLogSUPG : public ADKernelPlasmaSUPG<compute_stage>
{
public:
  ReactantSecondOrderLogSUPG(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpStrongResidual() override;


  // Material properties
  const MaterialProperty<Real> & _reaction_coeff;
  const ADVariableValue & _v;
  const MaterialProperty<Real> & _n_gas;
  Real _stoichiometric_coeff;

  usingKernelPlasmaSUPGMembers;
};

#endif // EFIELDADVECTION_H
