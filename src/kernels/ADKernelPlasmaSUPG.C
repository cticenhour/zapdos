//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADKernelPlasmaSUPG.h"
#include "MathUtils.h"
#include "Assembly.h"

// libmesh includes
#include "libmesh/threads.h"

#define PGParams                                                                                   \
  params.addParam<MaterialPropertyName>(                                                           \
      "tau_name", "tau", "The name of the stabilization parameter tau.");                          \
  params.addRequiredParam<Real>("position_units", "Units of position.");                           \
  params.addRequiredCoupledVar("potential", "The gradient of the potential will be used to compute the SUPG.")

defineADValidParams(ADKernelPlasmaSUPG, ADKernel, PGParams;);
defineADValidParams(ADVectorKernelPlasmaSUPG, ADVectorKernel, PGParams;);

template <typename T, ComputeStage compute_stage>
ADKernelPlasmaSUPGTempl<T, compute_stage>::ADKernelPlasmaSUPGTempl(const InputParameters & parameters)
  : ADKernelStabilizedTempl<T, compute_stage>(parameters),
    _tau(adGetADMaterialProperty<Real>("tau_name")),
    //grad_potential(adCoupledVectorValue("potential")),
    _grad_potential(adCoupledGradient("potential")),
    _mu(adGetMaterialProperty<Real>("mu" + _var.name())),
    _r_units(1. / adGetParam<Real>("position_units"))

{
}

template <typename T, ComputeStage compute_stage>
ADRealVectorValue
ADKernelPlasmaSUPGTempl<T, compute_stage>::computeQpStabilization()
{
  return _r_units * (_mu[_qp] * _grad_potential[_qp] * _r_units) * _tau[_qp];
}

template class ADKernelPlasmaSUPGTempl<Real, RESIDUAL>;
template class ADKernelPlasmaSUPGTempl<Real, JACOBIAN>;
template class ADKernelPlasmaSUPGTempl<RealVectorValue, RESIDUAL>;
template class ADKernelPlasmaSUPGTempl<RealVectorValue, JACOBIAN>;
