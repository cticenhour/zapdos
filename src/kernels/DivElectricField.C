//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DivElectricField.h"

registerMooseObject("ZapdosApp", DivElectricField);

template <>
InputParameters
validParams<DivElectricField>()
{
  InputParameters params = validParams<VectorKernel>();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("potential",
                               "The electric potential (used here for its scalar basis function).");
  params.addClassDescription("Weak form term associated with the divergence of the electric field."
                             "(Values are NOT in log form)");
  return params;
}

// This kernel should only be used with species whose values are in the logarithmic form.

DivElectricField::DivElectricField(const InputParameters & parameters)
  : VectorKernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _diffusivity(getMaterialProperty<Real>("diff" + _var.name())),

    _potential_var(*getVar("potential", 0)),

    // We need the scalar test basis function associated with the potential. This is
    // due to the use of a "split" form of the Gauss's Law equation and the
    // electrostatic field equation. For more information, see
    // https://www-m16.ma.tum.de/foswiki/pub/M16/Allgemeines/AdvFE15/weak_formulations.pdf
    _scalar_test(_potential_var.phi())
{
}

Real
DivElectricField::computeQpResidual()
{
  return _scalar_test[_i][_qp] * _diffusivity[_qp] * _grad_u[_qp].tr() * _r_units;
}

Real
DivElectricField::computeQpJacobian()
{
  return _scalar_test[_i][_qp] * _diffusivity[_qp] * _grad_phi[_j][_qp].tr() * _r_units;
}
