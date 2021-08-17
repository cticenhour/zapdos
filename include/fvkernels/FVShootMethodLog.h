
#pragma once

#include "FVElementalKernel.h"

/**
 * Simple class to demonstrate off diagonal Jacobian contributions.
 */
class FVShootMethodLog : public FVElementalKernel
{
public:
  static InputParameters validParams();

  FVShootMethodLog(const InputParameters & parameters);

protected:
  ADReal computeQpResidual() override;

  const ADVariableValue & _density_at_start_cycle;
  const ADVariableValue & _density_at_end_cycle;
  const ADVariableValue & _sensitivity;
  const Real & _limit;
};
