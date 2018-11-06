#ifndef ENERGYBC2_H
#define ENERGYBC2_H

#include "IntegratedBC.h"

class EnergyBC2;

template <>
InputParameters validParams<EnergyBC2>();

class EnergyBC2 : public IntegratedBC
{
public:
  EnergyBC2(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _time_units;
  Real _r_units;
  Real _r;

  // Coupled variables

  const VariableGradient & _grad_potential;
  unsigned int _potential_id;
  const VariableValue & _em;
  unsigned int _em_id;
  MooseVariable & _ip_var;
  const VariableValue & _ip;
  const VariableGradient & _grad_ip;
  unsigned int _ip_id;

  unsigned int _nargs;
  std::vector<const VariableValue *> _args;
  std::vector<const VariableGradient *> _grad_args;
  std::vector<unsigned int> _args_id;
  std::vector<const MaterialProperty<Real> *> _sgnion;
  std::vector<const MaterialProperty<Real> *> _muion;
  std::vector<const MaterialProperty<Real> *> _Dion;

  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _d_muem_d_actual_mean_en;
  const MaterialProperty<Real> & _massem;
  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _sgnip;
  const MaterialProperty<Real> & _muip;
  const MaterialProperty<Real> & _Dip;
  const MaterialProperty<Real> & _se_coeff;
  const MaterialProperty<Real> & _se_energy;
  const MaterialProperty<Real> & _mumean_en;
  const MaterialProperty<Real> & _d_mumean_en_d_actual_mean_en;

  Real _a;
  Real _v_thermal;
  RealVectorValue _ion_flux;
  Real _n_gamma;
  Real _d_v_thermal_d_u;
  Real _d_v_thermal_d_em;
  RealVectorValue _d_ion_flux_d_potential;
  RealVectorValue _d_ion_flux_d_ip;
  Real _d_n_gamma_d_potential;
  Real _d_n_gamma_d_ip;
  Real _d_n_gamma_d_u;
  Real _d_n_gamma_d_em;
  Real _actual_mean_en;
};

#endif // ENERGYBC2_H
