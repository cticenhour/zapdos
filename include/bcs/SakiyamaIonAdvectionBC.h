#ifndef SakiyamaIonAdvectionBC_H
#define SakiyamaIonAdvectionBC_H

#include "IntegratedBC.h"

class SakiyamaIonAdvectionBC;

template <>
InputParameters validParams<SakiyamaIonAdvectionBC>();

class SakiyamaIonAdvectionBC : public IntegratedBC
{
public:
  SakiyamaIonAdvectionBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  Real _r_units;
//  Real _r;

  // Coupled variables

  const VariableGradient & _grad_potential;
  unsigned int _potential_id;

  const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _e;
  const MaterialProperty<Real> & _sgn;

  Real _a;
};

#endif // SakiyamaIonAdvectionBC_H
