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

#ifndef TimeDerivativeSUPG_H
#define TimeDerivativeSUPG_H

#include "ADTimeKernelPlasmaSUPG.h"

// Forward Declaration
template <ComputeStage>
class TimeDerivativeSUPG;

declareADValidParams(TimeDerivativeSUPG);

template <ComputeStage compute_stage>
class TimeDerivativeSUPG : public ADTimeKernelPlasmaSUPG<compute_stage>
{
public:
  TimeDerivativeSUPG(const InputParameters & parameters);

protected:
  virtual ADResidual precomputeQpStrongResidual() override;



  usingTimeKernelPlasmaSUPGMembers;
};

#endif // TimeDerivative_H
