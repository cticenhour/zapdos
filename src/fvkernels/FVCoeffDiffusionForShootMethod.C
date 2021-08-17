
#include "FVCoeffDiffusionForShootMethod.h"

registerMooseObject("ZapdosApp", FVCoeffDiffusionForShootMethod);

InputParameters
FVCoeffDiffusionForShootMethod::validParams()
{
  InputParameters params = FVFluxKernel::validParams();
  params.addRequiredCoupledVar("density", "The log of the accelerated density.");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addClassDescription("The derivative of the generic diffusion term used to calculate the "
                             "sensitivity value for the shoothing method."
                             "(Densities must be in log form)");
  params.set<unsigned short>("ghost_layers") = 2;
  return params;
}

FVCoeffDiffusionForShootMethod::FVCoeffDiffusionForShootMethod(const InputParameters & params)
  : FVFluxKernel(params),

    _density_var(*getFieldVar("density", 0)),
    _diff_elem(getADMaterialProperty<Real>("diff" + _density_var.name())),
    _diff_neighbor(getNeighborADMaterialProperty<Real>("diff" + _density_var.name())),
    _r_units(1. / getParam<Real>("position_units"))
{
}

ADReal
FVCoeffDiffusionForShootMethod::computeQpResidual()
{
  auto dudn = gradUDotNormal();

  ADReal diffusivity;
  interpolate(Moose::FV::InterpMethod::Average,
              diffusivity,
              _diff_elem[_qp],
              _diff_neighbor[_qp],
              *_face_info,
              true);

  return -1.0 * diffusivity * dudn * _r_units;
}
