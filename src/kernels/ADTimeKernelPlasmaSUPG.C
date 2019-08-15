//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ADTimeKernelPlasmaSUPG.h"

#include "MathUtils.h"
#include "Assembly.h"
#include "MooseVariableFE.h"
#include "SystemBase.h"

// libmesh includes
#include "libmesh/threads.h"
#include "libmesh/quadrature.h"

#define PGParams                                                                                   \
  params.addParam<MaterialPropertyName>(                                                           \
      "tau_name", "tau", "The name of the stabilization parameter tau.");                          \
  params.addRequiredParam<Real>("position_units", "Units of position.");                           \
  params.addRequiredCoupledVar("potential", "The gradient of the potential will be used to compute the SUPG.")

defineADValidParams(ADTimeKernelPlasmaSUPG, ADKernel, PGParams; params.set<MultiMooseEnum>("vector_tags") = "time";
                    params.set<MultiMooseEnum>("matrix_tags") = "system time";);
defineADValidParams(ADVectorTimeKernelPlasmaSUPG,
                    ADVectorKernel,
                    PGParams;
                    params.set<MultiMooseEnum>("vector_tags") = "time";
                    params.set<MultiMooseEnum>("matrix_tags") = "system time";);

template <typename T, ComputeStage compute_stage>
ADTimeKernelPlasmaSUPGTempl<T, compute_stage>::ADTimeKernelPlasmaSUPGTempl(const InputParameters & parameters)
  : ADKernelStabilizedTempl<T, compute_stage>(parameters),
    _u_dot(_var.template adUDot<compute_stage>()),
    _tau(getADMaterialProperty<Real>("tau_name")),
    //grad_potential(adCoupledVectorValue("potential")),
    _grad_potential(adCoupledGradient("potential")),
    _mu(getMaterialProperty<Real>("mu" + _var.name())),
    _r_units(1. / getParam<Real>("position_units"))

{
}

template <typename T, ComputeStage compute_stage>
ADRealVectorValue
ADTimeKernelPlasmaSUPGTempl<T, compute_stage>::computeQpStabilization()
{
  return _r_units * (_mu[_qp] * _grad_potential[_qp] * _r_units) * _tau[_qp];
}

template class ADTimeKernelPlasmaSUPGTempl<Real, RESIDUAL>;
template class ADTimeKernelPlasmaSUPGTempl<Real, JACOBIAN>;
template class ADTimeKernelPlasmaSUPGTempl<RealVectorValue, RESIDUAL>;
template class ADTimeKernelPlasmaSUPGTempl<RealVectorValue, JACOBIAN>;
