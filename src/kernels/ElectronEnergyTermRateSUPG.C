#include "ElectronEnergyTermRateSUPG.h"

// MOOSE includes
#include "MooseVariable.h"

registerADMooseObject("ZapdosApp", ElectronEnergyTermRateSUPG);

defineADValidParams(
  ElectronEnergyTermRateSUPG,
  ADKernelPlasmaSUPG,
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");

  params.addRequiredCoupledVar("em", "The electron density.");
  params.addCoupledVar("v", "The second reactant species.");
  params.addParam<bool>("elastic_collision", false, "If the collision is elastic.");
  params.addRequiredParam<std::string>("reaction", "The reaction that is adding/removing energy.");
  params.addParam<Real>("threshold_energy", 0.0, "Energy required for reaction to take place.");

  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addParam<Real>("alpha", 1., "Multiplicative factor on the stabilization parameter tau.");
  params.addParam<bool>("transient_term",
                        false,
                        "Whether there should be a transient term in the momentum residuals."););


template <ComputeStage compute_stage>
ElectronEnergyTermRateSUPG<compute_stage>::ElectronEnergyTermRateSUPG(const InputParameters & parameters)
    : ADKernelPlasmaSUPG<compute_stage>(parameters),

    _elastic(adGetParam<bool>("elastic_collision")),
    _threshold_energy(adGetParam<Real>("threshold_energy")),
    _n_gas(adGetMaterialProperty<Real>("n_gas")),
    _rate_coefficient(adGetMaterialProperty<Real>("k_"+adGetParam<std::string>("reaction"))),
    _em(adCoupledValue("em")),
    _v(adCoupledValue("v")),
    _grad_em(adCoupledGradient("em"))

{
  if (!_elastic && !isParamValid("threshold_energy"))
    mooseError("ElectronEnergyTerm: Elastic collision set to false, but no threshold energy for this reaction is provided!");
  // if (_elastic)
  //   _energy_change = _elastic_energy[_qp];
  // else
  //   _energy_change = _threshold_energy;
  _energy_change = _threshold_energy;
}

template <ComputeStage compute_stage>
ADResidual
ElectronEnergyTermRateSUPG<compute_stage>::precomputeQpStrongResidual()
{

  if (isCoupled("v"))
  {
    return -_rate_coefficient[_qp] * std::exp(_v[_qp]) * std::exp(_em[_qp]) * _energy_change;
  }
  else
  {
    return -_rate_coefficient[_qp] * _n_gas[_qp] * std::exp(_em[_qp]) * _energy_change;
  }


}
