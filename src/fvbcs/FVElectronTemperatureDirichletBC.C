//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FVElectronTemperatureDirichletBC.h"
#include "MooseVariableFV.h"
#include "SystemBase.h"
#include "Assembly.h"
#include "ADUtils.h"

registerMooseObject("MooseApp", FVElectronTemperatureDirichletBC);

InputParameters
FVElectronTemperatureDirichletBC::validParams()
{
  InputParameters params = FVDirichletBCBase::validParams();
  params.addRequiredParam<Real>("value", "Value of the BC");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addClassDescription("Electron temperature boundary condition");
  return params;
}

FVElectronTemperatureDirichletBC::FVElectronTemperatureDirichletBC(const InputParameters & parameters)
  : FVDirichletBCBase(parameters),
    NeighborCoupleableMooseVariableDependencyIntermediateInterface(
        this, /*nodal=*/false, /*neighbor_nodal=*/false, /*is_fv=*/true),

    _u(_var.adSln()),
    _u_neighbor(_var.adSlnNeighbor()),
    _em(adCoupledValue("em")),
    _em_neighbor(adCoupledValue("em")),
    _value(getParam<Real>("value"))
{
}

Real
FVElectronTemperatureDirichletBC::boundaryValue(const FaceInfo & fi) const
{
  using namespace Moose::FV;

  ADReal u_face;
  interpolate(InterpMethod::Average,
              u_face,
              _u[0],
              _u_neighbor[0],
              fi,
              true);

  ADReal em_face;
  interpolate(InterpMethod::Average,
              em_face,
              _em[0],
              _em_neighbor[0],
              fi,
              true);

  return MetaPhysicL::raw_value(2.0 / 3 * (_u[0] / _em[0]) - _value);
}
