/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*           (c) 2010 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#ifndef CoeffDiffusionTempDependent_H
#define CoeffDiffusionTempDependent_H

#include "Diffusion.h"

class CoeffDiffusionTempDependent;

template <>
InputParameters validParams<CoeffDiffusionTempDependent>();

// This diffusion kernel should only be used with species whose values are in the logarithmic form.

class CoeffDiffusionTempDependent : public Diffusion
{
public:
  CoeffDiffusionTempDependent(const InputParameters & parameters);
  virtual ~CoeffDiffusionTempDependent();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;

  const MaterialProperty<Real> & _charge;
  const MaterialProperty<Real> & _massNeutral;
  const MaterialProperty<Real> & _mass;
  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T;
  const VariableGradient & _grad_potential;
  unsigned int _potential_id;
  const MaterialProperty<Real> & _mu;
  Real _diffusivity;
  Real _temp;
  Real _d_temp_d_potential;
  Real _d_diffusivity_d_potential;
};

#endif /* CoeffDiffusionTempDependent_H */
