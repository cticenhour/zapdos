
#include "FVEFieldAdvection.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVEFieldAdvection);

InputParameters
FVEFieldAdvection::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic electric field driven advection term using finite volume method.");
  params.addRequiredCoupledVar(
      "potential", "The gradient of the potential will be used to compute the advection velocity.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  MooseEnum advected_interp_method("average upwind", "upwind");

  params.addParam<MooseEnum>("advected_interp_method",
                             advected_interp_method,
                             "The interpolation to use for the advected quantity. Options are "
                             "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVEFieldAdvection::FVEFieldAdvection(const InputParameters & params)
  : FVFluxKernel(params),
    _mu_elem(getADMaterialProperty<Real>("mu" + _var.name())),
    _mu_neighbor(getNeighborADMaterialProperty<Real>("mu" + _var.name())),
    _sign(getMaterialProperty<Real>("sgn" + _var.name())),
    _r_units(1. / getParam<Real>("position_units"))
{
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
FVEFieldAdvection::computeQpResidual()
{
  ADReal u_interface;

  ADRealVectorValue grad_potential = adCoupledGradientFace("potential", *_face_info);

  using namespace Moose::FV;

  ADReal mobility;
  interpolate(InterpMethod::Average,
              mobility,
              _mu_elem[_qp],
              _mu_neighbor[_qp],
              *_face_info,
              true);

  interpolate(
      _advected_interp_method,
      u_interface,
      std::exp(_u_elem[_qp]),
      std::exp(_u_neighbor[_qp]),
      grad_potential,
      *_face_info,
      true);

   return _sign[_qp] * mobility * -1.0 * grad_potential * _r_units * _normal * u_interface;
}
