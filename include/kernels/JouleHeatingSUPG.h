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

#ifndef JOULEHEATINGSUPG_H
#define JOULEHEATINGSUPG_H

#include "ADKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class JouleHeatingSUPG;

declareADValidParams(JouleHeatingSUPG);

template <ComputeStage compute_stage>
class JouleHeatingSUPG : public ADKernelPlasmaSUPG<compute_stage>
{
public:
  JouleHeatingSUPG(const InputParameters & parameters);

protected:
  virtual ADReal precomputeQpStrongResidual() override;


  // Material properties

  Real _r_units;

  std::string _potential_units;
  const ADVariableValue & _em;
  const ADVariableGradient & _grad_em;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _diffem;

  Real _voltage_scaling;

  usingKernelPlasmaSUPGMembers;
};

#endif // EFIELDADVECTION_H
