
#include "TimeDerivativeSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", TimeDerivativeSUPG);

defineADValidParams(
  TimeDerivativeSUPG,
  ADTimeKernelPlasmaSUPG,
  params.set<MultiMooseEnum>("vector_tags") = "time";
  params.set<MultiMooseEnum>("matrix_tags") = "system time";
  params.addClassDescription("The time derivative operator for SUPG."););


template <ComputeStage compute_stage>
TimeDerivativeSUPG<compute_stage>::TimeDerivativeSUPG(const InputParameters & parameters)
    : ADTimeKernelPlasmaSUPG<compute_stage>(parameters)

{
}

template <ComputeStage compute_stage>
ADResidual
TimeDerivativeSUPG<compute_stage>::precomputeQpStrongResidual()
{

  return  std::exp(_u[_qp]) * _u_dot[_qp];


}
