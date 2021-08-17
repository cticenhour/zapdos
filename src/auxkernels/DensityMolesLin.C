//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DensityMolesLin.h"

registerMooseObject("ZapdosApp", DensityMolesLin);

InputParameters
DensityMolesLin::validParams()
{
  InputParameters params = AuxKernel::validParams();

  params.addRequiredParam<bool>("use_moles", "Whether to convert from units of moles to #.");
  params.addClassDescription("Returns physical densities in units of #/m^3");
  params.addRequiredCoupledVar("density", "The variable representing the density.");
  return params;
}

DensityMolesLin::DensityMolesLin(const InputParameters & parameters)
  : AuxKernel(parameters),

    _convert_moles(getParam<bool>("use_moles")),
    _N_A(getMaterialProperty<Real>("N_A")),
    _density(coupledValue("density"))
{
}

Real
DensityMolesLin::computeValue()
{
  return _density[_qp] * _N_A[_qp];
}
