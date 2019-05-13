#include "JouleHeatingSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", JouleHeatingSUPG);

defineADValidParams(
  JouleHeatingSUPG,
  ADKernelPlasmaSUPG,
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addRequiredParam<Real>("position_units", "Units of position."););


template <ComputeStage compute_stage>
JouleHeatingSUPG<compute_stage>::JouleHeatingSUPG(const InputParameters & parameters)
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _r_units(1. / adGetParam<Real>("position_units")),


    // Coupled variables

    _potential_units(adGetParam<std::string>("potential_units")),
    _em(adCoupledValue("em")),
    _grad_em(adCoupledGradient("em")),
    _muem(adGetMaterialProperty<Real>("muem")),
    _diffem(adGetMaterialProperty<Real>("diffem"))

{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000;
}

template <ComputeStage compute_stage>
ADResidual
JouleHeatingSUPG<compute_stage>::precomputeQpStrongResidual()
{

  return -_grad_potential[_qp] * _r_units * _voltage_scaling *
          (-_muem[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_em[_qp]) -
          _diffem[_qp] * std::exp(_em[_qp]) * _grad_em[_qp] * _r_units);


}
