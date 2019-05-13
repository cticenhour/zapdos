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

#ifndef ElectronEnergyTermRateSUPG_H
#define ElectronEnergyTermRateSUPG_H

#include "ADKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class ElectronEnergyTermRateSUPG;

declareADValidParams(ElectronEnergyTermRateSUPG);

template <ComputeStage compute_stage>
class ElectronEnergyTermRateSUPG : public ADKernelPlasmaSUPG<compute_stage>
{
public:
  ElectronEnergyTermRateSUPG(const InputParameters & parameters);

protected:
  virtual ADResidual precomputeQpStrongResidual() override;


  bool _elastic;
  Real _threshold_energy;
  Real _energy_change;
  const MaterialProperty<Real> & _n_gas;
  const MaterialProperty<Real> & _rate_coefficient;
  const ADVariableValue & _em;
  const ADVariableValue & _v;
  const ADVariableGradient & _grad_em;

  usingKernelPlasmaSUPGMembers;
};

#endif // EFIELDADVECTION_H
