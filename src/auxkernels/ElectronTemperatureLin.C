//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectronTemperatureLin.h"

registerMooseObject("ZapdosApp", ElectronTemperatureLin);

InputParameters
ElectronTemperatureLin::validParams()
{
  InputParameters params = AuxKernel::validParams();

  params.addRequiredCoupledVar("electron_density", "The electron density");
  params.addRequiredCoupledVar("mean_en", "The logarathmic representation of the mean energy.");
  params.addClassDescription("Returns the electron temperature");

  return params;
}

ElectronTemperatureLin::ElectronTemperatureLin(const InputParameters & parameters)
  : AuxKernel(parameters),

    _electron_density(coupledValue("electron_density")),
    _mean_en(coupledValue("mean_en"))
{
}

Real
ElectronTemperatureLin::computeValue()
{
  return 2.0 / 3 * (_mean_en[_qp] / _electron_density[_qp]);
}
