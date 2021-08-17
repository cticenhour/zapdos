//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVTimeKernelLog.h"

#include "SystemBase.h"

registerADMooseObject("MooseApp", FVTimeKernelLog);

InputParameters
FVTimeKernelLog::validParams()
{
  InputParameters params = FVElementalKernel::validParams();
  params.addClassDescription(
      "Residual contribution from time derivative of a variable for the finite volume method.");
  params.set<MultiMooseEnum>("vector_tags") = "time";
  params.set<MultiMooseEnum>("matrix_tags") = "system time";
  return params;
}

FVTimeKernelLog::FVTimeKernelLog(const InputParameters & parameters)
  : FVElementalKernel(parameters), _u_dot(_var.adUDot())
{
}

ADReal
FVTimeKernelLog::computeQpResidual()
{
  return std::exp(_u[_qp]) * _u_dot[_qp];
}
