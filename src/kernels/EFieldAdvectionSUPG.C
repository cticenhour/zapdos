#include "EFieldAdvectionSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", EFieldAdvectionSUPG);

defineADValidParams(
  EFieldAdvectionSUPG,
  ADKernelPlasmaSUPG,
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position."););


template <ComputeStage compute_stage>
EFieldAdvectionSUPG<compute_stage>::EFieldAdvectionSUPG(const InputParameters & parameters)
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    //_mu(adGetMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),

    // Coupled variables

    //_grad_potential(adCoupledGradient("potential")),
    _second_potential(adCoupledSecond("potential"))
{
}

template <ComputeStage compute_stage>
ADReal
EFieldAdvectionSUPG<compute_stage>::precomputeQpStrongResidual()
{

  return  _mu[_qp] * _sign[_qp] * (-_grad_potential[_qp] * _r_units * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units
                                   + -_second_potential[_qp].tr() * _r_units * _r_units * std::exp(_u[_qp]));

  //return  _mu[_qp] * _sign[_qp] * (-_grad_potential[_qp] * _r_units * std::exp(_u[_qp]) * _grad_u[_qp] * _r_units);


}
