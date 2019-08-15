#include "ReactantSecondOrderLogSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", ReactantSecondOrderLogSUPG);

defineADValidParams(
  ReactantSecondOrderLogSUPG,
  ADKernelPlasmaSUPG,

  params.addCoupledVar("v", "The first variable that is reacting to create u.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("coefficient", "The stoichiometric coeffient."););


template <ComputeStage compute_stage>
ReactantSecondOrderLogSUPG<compute_stage>::ReactantSecondOrderLogSUPG(const InputParameters & parameters)
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _reaction_coeff(getMaterialProperty<Real>("k_"+getParam<std::string>("reaction"))),
    _v(adCoupledValue("v")),
    _n_gas(getMaterialProperty<Real>("n_gas")),
    _stoichiometric_coeff(getParam<Real>("coefficient"))
{
}

template <ComputeStage compute_stage>
ADReal
ReactantSecondOrderLogSUPG<compute_stage>::precomputeQpStrongResidual()
{


  if (isCoupled("v"))
  {
    return -_stoichiometric_coeff * _reaction_coeff[_qp] * std::exp(_v[_qp]) * std::exp(_u[_qp]);
  }
  else
  {
    return -_stoichiometric_coeff * _reaction_coeff[_qp] * _n_gas[_qp] * std::exp(_u[_qp]);
  }

}
