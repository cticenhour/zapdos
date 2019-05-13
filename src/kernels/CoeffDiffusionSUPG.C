#include "CoeffDiffusionSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", CoeffDiffusionSUPG);

defineADValidParams(
  CoeffDiffusionSUPG,
  //ADKernel,
  ADKernelPlasmaSUPG,
  params.addRequiredCoupledVar(
      "var_for_second_derivative", "The second derivative of the variable will be used to compute the SUPG.");
  params.addRequiredParam<Real>("position_units", "Units of position."););


template <ComputeStage compute_stage>
CoeffDiffusionSUPG<compute_stage>::CoeffDiffusionSUPG(const InputParameters & parameters)
    //: ADKernel<compute_stage>(parameters),
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _r_units(1. / adGetParam<Real>("position_units")),


    // Coupled variables
    _second_var(adCoupledSecond("var_for_second_derivative")),

    _diff(adGetMaterialProperty<Real>("diff" + _var.name()))


{
}

//template <ComputeStage compute_stage>
//ADResidual
//CoeffDiffusionSUPG<compute_stage>::computeQpResidual()
template <ComputeStage compute_stage>
ADResidual
CoeffDiffusionSUPG<compute_stage>::precomputeQpStrongResidual()
{

  //return -_diff[_qp] * (std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * _grad_u[_qp] * _r_units
  //                      + std::exp(_u[_qp]) * _second_var[_qp].tr() * _r_units * _r_units);

  return -_diff[_qp] * (std::exp(_u[_qp]) * _grad_u[_qp] * _r_units * _grad_u[_qp] * _r_units
                        + std::exp(_u[_qp]) * _second_var[_qp].tr() * _r_units * _r_units);


}
