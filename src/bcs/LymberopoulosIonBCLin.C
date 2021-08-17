//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "LymberopoulosIonBCLin.h"

registerMooseObject("ZapdosApp", LymberopoulosIonBCLin);

InputParameters
LymberopoulosIonBCLin::validParams()
{
  InputParameters params = ADIntegratedBC::validParams();
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Simpified kinetic ion boundary condition"
                             "(Based on DOI: https://doi.org/10.1063/1.352926)");
  return params;
}

LymberopoulosIonBCLin::LymberopoulosIonBCLin(const InputParameters & parameters)
  : ADIntegratedBC(parameters),

    _r_units(1. / getParam<Real>("position_units")),

    // Coupled Variables
    _grad_potential(adCoupledGradient("potential")),

    _mu(getADMaterialProperty<Real>("mu" + _var.name()))
{
}

ADReal
LymberopoulosIonBCLin::computeQpResidual()
{
  return _test[_i][_qp] * _r_units * _mu[_qp] * -_grad_potential[_qp] * _r_units *
         _u[_qp] * _normals[_qp];
}
