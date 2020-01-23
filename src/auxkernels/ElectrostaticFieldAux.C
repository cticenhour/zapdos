//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ElectrostaticFieldAux.h"

registerMooseObject("ZapdosApp", ElectrostaticFieldAux);

template <>
InputParameters
validParams<ElectrostaticFieldAux>()
{
  InputParameters params = validParams<VectorAuxKernel>();
  params.addRequiredCoupledVar("potential", "The electric potential (electrostatic).");
  params.addClassDescription("A VectorAuxKernel used to calculate an electrostatic electric field "
                             "based on a calculated electrostatic potential solution variable.");
  return params;
}

ElectrostaticFieldAux::ElectrostaticFieldAux(const InputParameters & parameters)
  : VectorAuxKernel(parameters), _grad_potential(coupledGradient("potential"))
{
}

RealVectorValue
ElectrostaticFieldAux::computeValue()
{
  return -_grad_potential[_qp];
}
