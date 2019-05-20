#ifndef SakiyamaIonDiffusionBC_H
#define SakiyamaIonDiffusionBC_H

#include "IntegratedBC.h"

class SakiyamaIonDiffusionBC;

template <>
InputParameters validParams<SakiyamaIonDiffusionBC>();

class SakiyamaIonDiffusionBC : public IntegratedBC
{
public:
  SakiyamaIonDiffusionBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);


  Real _r_units;
  // Real _r;

  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T;
  const MaterialProperty<Real> & _mass;

  Real _v_thermal;
  Real _user_velocity;

  const MaterialProperty<Real> & _massNeutral;
  bool _variable_temp;
  const VariableGradient & _grad_potential;
  unsigned int _potential_id;
  const MaterialProperty<Real> & _mu;
  Real _temp;
  Real _d_temp_d_potential;
  Real _d_v_thermal_d_potential;
};

#endif // SakiyamaIonDiffusionBC_H
