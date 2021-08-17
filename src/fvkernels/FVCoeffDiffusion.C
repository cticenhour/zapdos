
#include "FVCoeffDiffusion.h"

registerMooseObject("ZapdosApp", FVCoeffDiffusion);

InputParameters
FVCoeffDiffusion::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addClassDescription("Generic diffusion term for finite volume method.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.set<unsigned short>("ghost_layers") = 2;
  return params;
}

FVCoeffDiffusion::FVCoeffDiffusion(const InputParameters & params)
  : FVFluxKernel(params),
    _diff_elem(getADMaterialProperty<Real>("diff" + _var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _var.name())),
    _r_units(1. / getParam<Real>("position_units"))
{
}

ADReal
FVCoeffDiffusion::computeQpResidual()
{
  auto dudn = gradUDotNormal();

  ADReal u_face;
  interpolate(Moose::FV::InterpMethod::Average,
              u_face,
              std::exp(_u_elem[_qp]),
              std::exp(_u_neighbor[_qp]),
              *_face_info,
              true);

  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              _diff_neighbor[_qp],
              *_face_info,
              true);

  return -1.0 * diffusivity * u_face * dudn * _r_units;
}
