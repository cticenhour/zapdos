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

#ifndef ElectronEnergyTermRateNonElectronInclusion_H
#define ElectronEnergyTermRateNonElectronInclusion_H

#include "Kernel.h"

class ElectronEnergyTermRateNonElectronInclusion;

template <>
InputParameters validParams<ElectronEnergyTermRateNonElectronInclusion>();

class ElectronEnergyTermRateNonElectronInclusion : public Kernel
{
public:
  ElectronEnergyTermRateNonElectronInclusion(const InputParameters & parameters);
  virtual ~ElectronEnergyTermRateNonElectronInclusion();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;
  bool _elastic;
  Real _threshold_energy;
  Real _energy_change;

  // const MaterialProperty<Real> & _elastic_energy;
  const MaterialProperty<Real> & _n_gas;
  const MaterialProperty<Real> & _rate_coefficient;
  const MaterialProperty<Real> & _d_iz_d_actual_mean_en;

  const VariableValue & _em;
  const VariableValue & _v;
  const VariableValue & _w;
  const VariableGradient & _grad_em;
  unsigned int _em_id;
  unsigned int _v_id;
  unsigned int _w_id;
};

#endif /* ElectronEnergyTermRateNonElectronInclusion_H */
