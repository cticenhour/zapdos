
#include "FVJouleHeating.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVJouleHeating);

InputParameters
FVJouleHeating::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("potential", "The electron density.");
  params.addRequiredParam<std::string>("potential_units", "The potential units.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription(
      "Joule heating term for electrons (densities must be in log form), where the Jacobian is "
      "computed using forward automatic differentiation.");

  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVJouleHeating::FVJouleHeating(const InputParameters & params)
  : FVFluxKernel(params),

    _r_units(1. / getParam<Real>("position_units")),
    _potential_units(getParam<std::string>("potential_units")),
    _diff_elem(getADMaterialProperty<Real>("diffem")),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diffem")),
    _mu_elem(getADMaterialProperty<Real>("muem")),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("muem")),
    _em_elem(adCoupledValue("em")),
    _em_neighbor(adCoupledNeighborValue("em"))
{
  if (_potential_units.compare("V") == 0)
    _voltage_scaling = 1.;
  else if (_potential_units.compare("kV") == 0)
    _voltage_scaling = 1000.;
  else
    mooseError("Potential units " + _potential_units + " not valid! Use V or kV.");

  using namespace Moose::FV;

  const auto & advected_interp_method = getParam<MooseEnum>("advected_interp_method");
  if (advected_interp_method == "average")
    _advected_interp_method = InterpMethod::Average;
  else if (advected_interp_method == "upwind")
    _advected_interp_method = InterpMethod::Upwind;
  else
    mooseError("Unrecognized interpolation type ",
               static_cast<std::string>(advected_interp_method));
}

ADReal
FVJouleHeating::computeQpResidual()
{
  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info);
  ADRealVectorValue grad_em = adCoupledGradientFace("em", *_face_info);

  using namespace Moose::FV;

  ADReal mu;
  interpolate(InterpMethod::Average,
              mu,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  ADReal diff;
  interpolate(InterpMethod::Average,
              diff,
              _diff_elem[_qp],
              _diff_neighbor[_qp],
              *_face_info,
              true);

  ADReal em_interface;
  interpolate(
      _advected_interp_method,
      em_interface,
      _em_elem[_qp],
      _em_neighbor[_qp],
      grad_potential,
      *_face_info,
      true);

  return -grad_potential * _r_units * _voltage_scaling *
         (-mu * -grad_potential * _r_units * em_interface -
          diff * grad_em * _r_units);
}
