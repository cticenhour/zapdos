//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectrostaticField.h"
#include "Assembly.h"

registerMooseObject("ZapdosApp", ElectrostaticField);

template <>
InputParameters
validParams<ElectrostaticField>()
{
  InputParameters params = validParams<Kernel>();
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredCoupledVar("electric_field", "The electric field.");
  params.addClassDescription(
      "Weak form term associated with the electrostatic field equation: $\\vec{E} = -\\nabla V$");
  return params;
}

ElectrostaticField::ElectrostaticField(const InputParameters & parameters)
  : Kernel(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    _field_var(*getVectorVar("electric_field", 0)),

    _electric_field(coupledVectorValue("electric_field")),

    // We need the vector test basis function associated with the electric field. This is
    // due to the use of a "split" form of the Gauss's Law equation and the
    // electrostatic field equation. For more information, see
    // https://www-m16.ma.tum.de/foswiki/pub/M16/Allgemeines/AdvFE15/weak_formulations.pdf
    _vector_test(_field_var.phi()),

    _grad_vector_test(_field_var.gradPhi()),

    _field_phi(_assembly.phi(_field_var)),

    _field_id(coupled("electric_field"))
{
}

Real
ElectrostaticField::computeQpResidual()
{
  return _electric_field[_qp] * _vector_test[_i][_qp] -
         _u[_qp] * _grad_vector_test[_i][_qp].tr() * _r_units;
}

Real
ElectrostaticField::computeQpJacobian()
{
  return -_phi[_j][_qp] * _grad_vector_test[_i][_qp].tr() * _r_units;
}

Real
ElectrostaticField::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _field_id)
    return _field_phi[_j][_qp] * _vector_test[_i][_qp];
  else
    return 0;
}
