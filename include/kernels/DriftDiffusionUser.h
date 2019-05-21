//* This file is part of Zapdos, an open-source
//* application for the simulation of plasmas
//* https://github.com/shannon-lab/zapdos
//*
//* Zapdos is powered by the MOOSE Framework
//* https://www.mooseframework.org
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef DRIFTDIFFUSIONUSER_H
#define DRIFTDIFFUSIONUSER_H

#include "DriftDiffusion.h"

class DriftDiffusionUser;

template <>
InputParameters validParams<DriftDiffusionUser>();

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

class DriftDiffusionUser : public DriftDiffusion
{
public:
  DriftDiffusionUser(const InputParameters & parameters);

protected:
  MooseArray<Real> _mu;
  MooseArray<Real> _sign;
  MooseArray<Real> _diffusivity;
};

#endif /* DRIFTDIFFUSIONUSER_H */
