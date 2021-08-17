
#include "FVShootMethodLog.h"

registerMooseObject("ZapdosApp", FVShootMethodLog);

InputParameters
FVShootMethodLog::validParams()
{
  InputParameters params = FVElementalKernel::validParams();

  params.addRequiredCoupledVar("density_at_start_cycle",
                               "The accelerated density at the start of the cycle in log form");
  params.addRequiredCoupledVar("density_at_end_cycle",
                               "The accelerated density at the end of the cycle in log form");
  params.addParam<Real>("growth_limit",
                        0.0,
                        "A limit of the growth factor"
                        "(growth_limit = 0.0 means no limit)");
  params.addRequiredCoupledVar("sensitivity_variable",
                               "The variable that represents the sensitivity of acceleration"
                               "as defined for the shooting method");
  params.addClassDescription("An acceleration scheme based on the shooting method");

  return params;
}

FVShootMethodLog::FVShootMethodLog(const InputParameters & parameters)
  : FVElementalKernel(parameters),
    _density_at_start_cycle(adCoupledValue("density_at_start_cycle")),
    _density_at_end_cycle(adCoupledValue("density_at_end_cycle")),
    _sensitivity(adCoupledValue("sensitivity_variable")),
    _limit(getParam<Real>("growth_limit"))
{
}

ADReal
FVShootMethodLog::computeQpResidual()
{
  Real limiter = 0.0;
  if (_limit > 0.0)
    limiter = (1. / _limit);

  ADReal Scaling = 1.0 / ((1. - _sensitivity[_qp]) + limiter);

  return (std::exp(_u[_qp]) - std::exp(_density_at_start_cycle[_qp]) +
           (std::exp(_density_at_start_cycle[_qp]) -
            std::exp(_density_at_end_cycle[_qp])) * Scaling);
}
