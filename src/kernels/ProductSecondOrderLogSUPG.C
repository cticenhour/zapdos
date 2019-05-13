#include "ProductSecondOrderLogSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", ProductSecondOrderLogSUPG);

defineADValidParams(
  ProductSecondOrderLogSUPG,
  ADKernelPlasmaSUPG,

  params.addCoupledVar("v", "The first variable that is reacting to create u.");
  params.addCoupledVar("w", "The secound variable that is reacting to create u.");
  params.addRequiredParam<std::string>("reaction", "The full reaction equation.");
  params.addRequiredParam<Real>("coefficient", "The stoichiometric coeffient."););


template <ComputeStage compute_stage>
ProductSecondOrderLogSUPG<compute_stage>::ProductSecondOrderLogSUPG(const InputParameters & parameters)
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _reaction_coeff(adGetMaterialProperty<Real>("k_"+adGetParam<std::string>("reaction"))),
    _v(adCoupledValue("v")),
    _w(adCoupledValue("w")),
    _n_gas(adGetMaterialProperty<Real>("n_gas")),
    _stoichiometric_coeff(adGetParam<Real>("coefficient"))

{
}

template <ComputeStage compute_stage>
ADResidual
ProductSecondOrderLogSUPG<compute_stage>::precomputeQpStrongResidual()
{

  if (isCoupled("v"))
  {
    if (isCoupled("w"))
    {
      return -_stoichiometric_coeff * _reaction_coeff[_qp] * std::exp(_v[_qp]) * std::exp(_w[_qp]);
    }
    else
    {
      return -_stoichiometric_coeff * _reaction_coeff[_qp] * std::exp(_v[_qp]) * _n_gas[_qp];
    }
  }
  else
  {
    if (isCoupled("w"))
    {
      return -_stoichiometric_coeff * _reaction_coeff[_qp] * _n_gas[_qp] * std::exp(_w[_qp]);
    }
    else
    {
      return  -_stoichiometric_coeff * _reaction_coeff[_qp] * _n_gas[_qp] * _n_gas[_qp];
    }
  }

}
