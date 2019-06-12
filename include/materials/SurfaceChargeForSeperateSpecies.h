/****************************************************************/
/*                      DO NOT MODIFY THIS HEADER               */
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*              (c) 2010 Battelle Energy Alliance, LLC          */
/*                      ALL RIGHTS RESERVED                     */
/*                                                              */
/*              Prepared by Battelle Energy Alliance, LLC       */
/*              Under Contract No. DE-AC07-05ID14517            */
/*              With the U. S. Department of Energy             */
/*                                                              */
/*              See COPYRIGHT for full restrictions             */
/****************************************************************/
#ifndef SurfaceChargeForSeperateSpecies_H_
#define SurfaceChargeForSeperateSpecies_H_

#include "Material.h"
/* #include "LinearInterpolation.h" */
#include "SplineInterpolation.h"

class SurfaceChargeForSeperateSpecies;

template <>
InputParameters validParams<SurfaceChargeForSeperateSpecies>();

class SurfaceChargeForSeperateSpecies : public Material
{
public:
  SurfaceChargeForSeperateSpecies(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  virtual void computeQpProperties();

  Real getIntegralValue();

  const MaterialProperty<Real> & _e;
  Real _r_units;
  bool _species_em;

  MaterialProperty<Real> & _surface_charge;
  const MaterialProperty<Real> & _surface_charge_old;

  MaterialProperty<Real> & _current;
  const MaterialProperty<Real> & _current_old;

  const VariableGradient & _grad_potential;
  const VariableValue & _em;
  const VariableValue & _ip;
  MooseVariable & _ip_var;
  const VariableGradient & _grad_em;
  const VariableGradient & _grad_ip;
  const VariableValue & _mean_en;

  const MaterialProperty<Real> & _muem;
  const MaterialProperty<Real> & _diffem;
  const MaterialProperty<Real> & _muip;
  const MaterialProperty<Real> & _diff;
  Real _diffip;

  const MaterialProperty<Real> & _sgnem;
  const MaterialProperty<Real> & _sgnip;
  const MaterialProperty<Real> & _kb;
  const MaterialProperty<Real> & _T;
  const MaterialProperty<Real> & _mass;
  const MaterialProperty<Real> & _massNeutral;
  const MaterialProperty<Real> & _charge;
  Real _temp;
  bool _variable_temp;
  std::string _potential_units;

  Real _voltage_scaling;

};

#endif // SurfaceChargeForSeperateSpecies_H_
