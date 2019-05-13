//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// Navier-Stokes includes
#include "ADMaterialsPlasmaSUPG.h"
#include "NonlinearSystemBase.h"

registerADMooseObject("ZapdosApp", ADMaterialsPlasmaSUPG);

defineADValidParams(
    ADMaterialsPlasmaSUPG,
    ADMaterial,
    params.addClassDescription(
        "This is the material class used to compute the stabilization parameter tau.");
    params.addRequiredCoupledVar(
        "potential", "The gradient of the potential will be used to compute the advection velocity.");
    params.addRequiredParam<Real>("position_units", "Units of position.");
    params.addRequiredParam<std::string>("species_name", "The name of the species involved with SUPG");
    params.addParam<bool>("transient_term",
                          false,
                          "Whether there should be a transient term in the momentum residuals.");
    params.addParam<Real>("alpha",
                          1.,
                          "Multiplicative factor on the stabilization parameter tau."););

template <ComputeStage compute_stage>
ADMaterialsPlasmaSUPG<compute_stage>::ADMaterialsPlasmaSUPG(const InputParameters & parameters)
  : ADMaterial<compute_stage>(parameters),
    _alpha(adGetParam<Real>("alpha")),
    _tau(adDeclareADProperty<Real>("tau" + adGetParam<std::string>("species_name"))),
    _r_units(1. / adGetParam<Real>("position_units")),
    _mu(adGetMaterialProperty<Real>("mu" + adGetParam<std::string>("species_name"))),
    _grad_potential(adCoupledGradient("potential")),
    //_grad_potential(adCoupledVectorGradient("potential")),
    _diff(adGetMaterialProperty<Real>("diff" + adGetParam<std::string>("species_name"))),
    _transient_term(adGetParam<bool>("transient_term"))
{
}

template <ComputeStage compute_stage>
void
ADMaterialsPlasmaSUPG<compute_stage>::computeHMax()
{
  _hmax = _current_elem->hmax() / _r_units;
}

template <>
void
ADMaterialsPlasmaSUPG<JACOBIAN>::computeHMax()
{
  if (!_displacements.size())
  {
    _hmax = _current_elem->hmax() / _r_units;
    return;
  }

  _hmax = 0;

  for (unsigned int n_outer = 0; n_outer < _current_elem->n_vertices(); n_outer++)
    for (unsigned int n_inner = n_outer + 1; n_inner < _current_elem->n_vertices(); n_inner++)
    {
      VectorValue<DualReal> diff = (_current_elem->point(n_outer) - _current_elem->point(n_inner));
      unsigned dimension = 0;
      for (const auto & disp_num : _displacements)
      {
        diff(dimension)
            .derivatives()[disp_num * _fe_problem.getNonlinearSystemBase().getMaxVarNDofsPerElem() +
                           n_outer] = 1.;
        diff(dimension++)
            .derivatives()[disp_num * _fe_problem.getNonlinearSystemBase().getMaxVarNDofsPerElem() +
                           n_inner] = -1.;
      }

      _hmax = std::max(_hmax, diff.norm_sq());
    }

  _hmax = std::sqrt(_hmax) / _r_units;
}

template <ComputeStage compute_stage>
void
ADMaterialsPlasmaSUPG<compute_stage>::computeProperties()
{
  computeHMax();

  Material::computeProperties();
}

template <ComputeStage compute_stage>
void
ADMaterialsPlasmaSUPG<compute_stage>::computeQpProperties()
{

  auto && W = _mu[_qp] * _grad_potential[_qp] * _r_units;
  auto && transient_part = _transient_term ? 4. / (_dt * _dt) : 0.;
  _tau[_qp] = _alpha / std::sqrt(transient_part +
                                 (2. * (_mu[_qp] * _grad_potential[_qp] * _r_units).norm() / _hmax) *
                                     (2. * (_mu[_qp] * _grad_potential[_qp] * _r_units).norm() / _hmax) +
                                 9. * (4. * _diff[_qp] / (_hmax * _hmax)) * (4. * _diff[_qp] / (_hmax * _hmax)));

  //_tau[_qp] = _hmax / (2. * (_mu[_qp] * _grad_potential[_qp] * _r_units).norm());
  //_tau[_qp] = _alpha * _hmax / (2. * W.norm());
}
