
#include "FVThermalConductivityDiffusionNonLog.h"
#include "Assembly.h"

#include "MooseTypes.h"
#include "SubProblem.h"
#include "FEProblem.h"

#include "libmesh/numeric_vector.h"
#include "libmesh/dof_map.h"
#include "libmesh/quadrature.h"
#include "libmesh/boundary_info.h"

registerADMooseObject("ZapdosApp", FVThermalConductivityDiffusionNonLog);

InputParameters
FVThermalConductivityDiffusionNonLog::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addRequiredCoupledVar("em", "The log of the electron density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("Electron energy diffusion term "
                             "that assumes a thermal conductivity of "
                             "$K = 3/2 D_e n_e$ ");
  //MooseEnum advected_interp_method("average upwind", "upwind");
  //
  //params.addParam<MooseEnum>("advected_interp_method",
  //                           advected_interp_method,
  //                           "The interpolation to use for the advected quantity. Options are "
  //                           "'upwind' and 'average', with the default being 'upwind'.");
  return params;
}

FVThermalConductivityDiffusionNonLog::FVThermalConductivityDiffusionNonLog(const InputParameters & params)
  : FVFluxKernel(params),
    _r_units(1. / getParam<Real>("position_units")),
    _coeff(2.0 / 3.0),

    _diffem_elem(getADMaterialProperty<Real>("diffem")),
    _diffem_neighbor(getNeighborADMaterialProperty<Real>("diffem")),

    _em_elem(adCoupledValue("em")),
    _em_neighbor(adCoupledNeighborValue("em"))
{
  //using namespace Moose::FV;
  //
  //const auto & advected_interp_method = getParam<MooseEnum>("advected_interp_method");
  //if (advected_interp_method == "average")
  //  _advected_interp_method = InterpMethod::Average;
  //else if (advected_interp_method == "upwind")
  //  _advected_interp_method = InterpMethod::Upwind;
  //else
  //  mooseError("Unrecognized interpolation type ",
  //             static_cast<std::string>(advected_interp_method));
}

ADReal
FVThermalConductivityDiffusionNonLog::computeQpResidual()
{

  auto grad_u = gradUDotNormal();
  ADRealVectorValue grad_em = adCoupledGradientFace("em", *_face_info);

  using namespace Moose::FV;

  ADReal diffem;
  interpolate(InterpMethod::Average,
              diffem,
              _diffem_elem[_qp],
              _diffem_neighbor[_qp],
              *_face_info,
              true);

  ADReal u_interface;
  interpolate(InterpMethod::Average,
              u_interface,
              _u_elem[_qp],
              _u_neighbor[_qp],
              *_face_info,
              true);

  ADReal em_interface;
  interpolate(InterpMethod::Average,
              em_interface,
              _em_elem[_qp],
              _em_neighbor[_qp],
              *_face_info,
              true);

  //Is _r_units needed like for _grad_test[_i][_qp]???
  return   _coeff * diffem *
          (grad_u * _r_units -
          (u_interface / em_interface) * grad_em * _normal * _r_units);
}
