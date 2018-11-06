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

#ifndef ELECTRONENERGYTERMELASTICTOWNSEND_H
#define ELECTRONENERGYTERMELASTICTOWNSEND_H

#include "Kernel.h"

class ElectronEnergyTermElasticTownsend;

template <>
InputParameters validParams<ElectronEnergyTermElasticTownsend>();

class ElectronEnergyTermElasticTownsend : public Kernel
{
public:
  ElectronEnergyTermElasticTownsend(const InputParameters & parameters);
  virtual ~ElectronEnergyTermElasticTownsend();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;

  const MaterialProperty<Real> & _diffem;
  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _townsend_coefficient;
  const MaterialProperty<Real> & _d_alpha_d_actual_mean_en;
  const MaterialProperty<Real> & _d_muem_d_actual_mean_en;
  const MaterialProperty<Real> & _d_diffem_d_actual_mean_en;
  const MaterialProperty<Real> & _massIncident;
  const MaterialProperty<Real> & _massTarget;

  const VariableGradient & _grad_potential;
  const VariableValue & _em;
  const VariableGradient & _grad_em;
  unsigned int _potential_id;
  unsigned int _em_id;
};

#endif /* ELECTRONENERGYTERMELASTICTOWNSEND_H */
