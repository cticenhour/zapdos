#include "EnergyBC2.h"

// MOOSE includes
#include "MooseVariable.h"

registerMooseObject("ZapdosApp", EnergyBC2);

template <>
InputParameters
validParams<EnergyBC2>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("r", "The reflection coefficient");
  params.addRequiredCoupledVar("potential", "The electric potential");
  params.addRequiredCoupledVar("em", "The electron density.");
  params.addRequiredCoupledVar("ip", "The ion density.");
  params.addCoupledVar("args", "coupled variables");
  params.addRequiredParam<Real>("position_units", "Units of position.");
  params.addRequiredParam<Real>("time_units", 1, "Units of time");
  return params;
}

EnergyBC2::EnergyBC2(const InputParameters & parameters)
  : IntegratedBC(parameters),

    _time_units(getParam<Real>("time_units")),
    _r_units(1. / getParam<Real>("position_units")),
    _r(getParam<Real>("r")),

    // Coupled Variables
    _grad_potential(coupledGradient("potential")),
    _potential_id(coupled("potential")),
    _em(coupledValue("em")),
    _em_id(coupled("em")),
    _ip_var(*getVar("ip", 0)),
    _ip(coupledValue("ip")),
    _grad_ip(coupledGradient("ip")),
    _ip_id(coupled("ip")),

    _nargs(coupledComponents("args")),
    _args(_nargs),
    _grad_args(_nargs),
    _args_id(_nargs),
    _sgnion(_nargs),
    _muion(_nargs),
    _Dion(_nargs),

    _muem(getMaterialProperty<Real>("muem")),
    _d_muem_d_actual_mean_en(getMaterialProperty<Real>("d_muem_d_actual_mean_en")),
    _massem(getMaterialProperty<Real>("massem")),
    _e(getMaterialProperty<Real>("e")),
    _sgnip(getMaterialProperty<Real>("sgn" + _ip_var.name())),
    _muip(getMaterialProperty<Real>("mu" + _ip_var.name())),
    _Dip(getMaterialProperty<Real>("diff" + _ip_var.name())),
    _se_coeff(getMaterialProperty<Real>("se_coeff")),
    _se_energy(getMaterialProperty<Real>("se_energy")),
    _mumean_en(getMaterialProperty<Real>("mumean_en")),
    _d_mumean_en_d_actual_mean_en(getMaterialProperty<Real>("d_mumean_en_d_actual_mean_en")),
    _a(0.5),
    _v_thermal(0),
    _ion_flux(0, 0, 0),
    _n_gamma(0),
    _d_v_thermal_d_u(0),
    _d_v_thermal_d_em(0),
    _d_ion_flux_d_potential(0, 0, 0),
    _d_ion_flux_d_ip(0, 0, 0),
    _d_n_gamma_d_potential(0),
    _d_n_gamma_d_ip(0),
    _d_n_gamma_d_u(0),
    _d_n_gamma_d_em(0),
    _actual_mean_en(0)
{
  for (unsigned int i = 0; i < _nargs; ++i)
  {
    _args[i] = &coupledValue("args", i);
    _grad_args[i] = &coupledGradient("args", i);
    _args_id[i] = coupled("args", i);
    // _arg_name[i] = &getVar("args", i);
    // std::cout << (*_arg_name[i]) << std::endl;
    _sgnion[i] = &getMaterialProperty<Real>("sgn"+(getVar("args", i)->name()));
    _muion[i] = &getMaterialProperty<Real>("mu"+(getVar("args", i)->name()));
    _Dion[i] = &getMaterialProperty<Real>("diff"+(getVar("args", i)->name()));
  }
}

Real
EnergyBC2::computeQpResidual()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  for (unsigned int i = 0; i < _nargs; ++i)
  {
    _ion_flux += (*_sgnion[i])[_qp] * (*_muion[i])[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
                (*_Dion[i])[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
    // (*_sgnion[i])[_qp]
    // _ion_flux += _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
    //             _Dip[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
  }

  // _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_ip[_qp]) -
              // _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp] * _r_units;
  // _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] / (_muem[_qp] *
  // -_grad_potential[_qp] * _r_units * _normals[_qp] + std::numeric_limits<double>::epsilon());
  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

  return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) *
         (10. * _ion_flux * _normals[_qp] * _se_energy[_qp] * _se_coeff[_qp] * (_a - 1.) *
              (_r + 1.) +
          (_r - 1.) * (std::exp(_u[_qp]) - _se_energy[_qp] * _n_gamma) *
              (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] * _mumean_en[_qp] *
                   (2. * _a - 1.) -
               5. * _v_thermal * _time_units));
}

Real
EnergyBC2::computeQpJacobian()
{
  if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  {
    _a = 1.0;
  }
  else
  {
    _a = 0.0;
  }

  for (unsigned int i = 0; i < _nargs; ++i)
  {
    _ion_flux += (*_sgnion[i])[_qp] * (*_muion[i])[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
                (*_Dion[i])[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
    // (*_sgnion[i])[_qp]
    // _ion_flux += _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
    //             _Dip[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
  }

  // _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_ip[_qp]) -
  //             _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp] * _r_units;
  // _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] / (_muem[_qp] *
  // -_grad_potential[_qp] * _r_units * _normals[_qp] + std::numeric_limits<double>::epsilon());
  _actual_mean_en = std::exp(_u[_qp] - _em[_qp]);
  // _d_n_gamma_d_u = -1. * (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
  // (std::pow(_muem[_qp] * -_grad_potential[_qp] * _r_units * _normals[_qp], 2.) +
  // std::numeric_limits<double>::epsilon()) * -_grad_potential[_qp] * _r_units * _normals[_qp] *
  // _d_muem_d_actual_mean_en[_qp] * _actual_mean_en * _phi[_j][_qp];
  _v_thermal =
      std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));
  _d_v_thermal_d_u = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) /
                     (M_PI * _massem[_qp]) * _phi[_j][_qp];

  return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) * (_r - 1.) *
         ((std::exp(_u[_qp]) * _phi[_j][_qp] - _se_energy[_qp] * _d_n_gamma_d_u) *
              (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] * _mumean_en[_qp] *
                   (2. * _a - 1.) -
               5. * _v_thermal * _time_units) +
          (std::exp(_u[_qp]) - _se_energy[_qp] * _n_gamma) *
              (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] *
                   _d_mumean_en_d_actual_mean_en[_qp] * _actual_mean_en * _phi[_j][_qp] *
                   (2. * _a - 1.) -
               5. * _d_v_thermal_d_u * _time_units));
}

Real
EnergyBC2::computeQpOffDiagJacobian(unsigned int jvar)
{
  auto it = std::find(_args_id.begin(), _args_id.end(), jvar);
  int index;

  if (jvar == _potential_id)
  {
    if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
      _a = 1.0;
    else
      _a = 0.0;

    for (unsigned int i = 0; i < _nargs; ++i)
    {
      _ion_flux += (*_sgnion[i])[_qp] * (*_muion[i])[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
                  (*_Dion[i])[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
      // (*_sgnion[i])[_qp]
      // _ion_flux += _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp((*_args[i])[_qp]) -
      //             _Dip[_qp] * std::exp((*_args[i])[_qp]) * (*_grad_args[i])[_qp] * _r_units;
      _d_ion_flux_d_potential =
          (*_sgnion[i])[_qp] * (*_muion[i])[_qp] * -_grad_phi[_j][_qp] * _r_units * std::exp((*_args[i])[_qp]);

    }

    // _ion_flux = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units * std::exp(_ip[_qp]) -
    //             _Dip[_qp] * std::exp(_ip[_qp]) * _grad_ip[_qp] * _r_units;
    // _d_ion_flux_d_potential =
    //     _sgnip[_qp] * _muip[_qp] * -_grad_phi[_j][_qp] * _r_units * std::exp(_ip[_qp]);
    // _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] / (_muem[_qp] *
    //           -_grad_potential[_qp] * _r_units * _normals[_qp] + std::numeric_limits<double>::epsilon());
    // _d_n_gamma_d_potential = (1. - _a) * _se_coeff[_qp] / _muem[_qp] * (_d_ion_flux_d_potential *
    // _normals[_qp] / (-_grad_potential[_qp] * _r_units * _normals[_qp] +
    // std::numeric_limits<double>::epsilon()) - _ion_flux * _normals[_qp] /
    // (std::pow(-_grad_potential[_qp] * _r_units * _normals[_qp], 2.) +
    // std::numeric_limits<double>::epsilon()) * -_grad_phi[_j][_qp] * _r_units * _normals[_qp]);
    _v_thermal =
        std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

    return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) *
           (10. * _d_ion_flux_d_potential * _normals[_qp] * _se_energy[_qp] * _se_coeff[_qp] *
                (_a - 1.) * (_r + 1.) +
            (_r - 1.) * ((-_se_energy[_qp] * _d_n_gamma_d_potential) *
                             (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] *
                                  _mumean_en[_qp] * (2. * _a - 1.) -
                              5. * _v_thermal * _time_units) +
                         (std::exp(_u[_qp]) - _se_energy[_qp] * _n_gamma) *
                             (6. * -_grad_phi[_j][_qp] * _r_units * _normals[_qp] *
                              _mumean_en[_qp] * (2. * _a - 1.))));
  }

  else if (jvar == _em_id)
  {
    if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }
    _v_thermal =
        std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));
    _d_v_thermal_d_em = 0.5 / _v_thermal * 8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) /
                        (M_PI * _massem[_qp]) * -_phi[_j][_qp];
    // _n_gamma = (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] / (_muem[_qp] *
    // -_grad_potential[_qp] * _r_units * _normals[_qp] + std::numeric_limits<double>::epsilon());
    _actual_mean_en = std::exp(_u[_qp] - _em[_qp]);
    // _d_n_gamma_d_em = -1. * (1. - _a) * _se_coeff[_qp] * _ion_flux * _normals[_qp] /
    // (std::pow(_muem[_qp] * -_grad_potential[_qp] * _r_units * _normals[_qp], 2.) +
    // std::numeric_limits<double>::epsilon()) * -_grad_potential[_qp] * _r_units * _normals[_qp] *
    // _d_muem_d_actual_mean_en[_qp] * _actual_mean_en * -_phi[_j][_qp];

    return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) *
           ((_r - 1.) * (std::exp(_u[_qp]) - _se_energy[_qp] * _n_gamma) *
                (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] *
                     _d_mumean_en_d_actual_mean_en[_qp] * _actual_mean_en * -_phi[_j][_qp] *
                     (2. * _a - 1.) -
                 5. * _d_v_thermal_d_em * _time_units) +
            (_r - 1.) * (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] * _mumean_en[_qp] *
                             (2. * _a - 1.) -
                         5. * _v_thermal * _time_units) *
                -_se_energy[_qp] * _d_n_gamma_d_em);
  }


  else if (it != _args_id.end())
  {
    index = std::distance(_args_id.begin(), it);
    if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
    {
      _a = 1.0;
    }
    else
    {
      _a = 0.0;
    }

    _v_thermal = std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));

    _d_ion_flux_d_ip = (*_sgnion[index])[_qp] * (*_muion[index])[_qp] * -_grad_potential[_qp] * _r_units *
                       std::exp((*_args[index])[_qp]) * _phi[_j][_qp];
    // _d_ion_flux_d_ip = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units *
                       // std::exp((*_args[index])[_qp]) * _phi[_j][_qp];

   return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) *
          (10. * _d_ion_flux_d_ip * _normals[_qp] * _se_energy[_qp] * _se_coeff[_qp] * (_a - 1.) *
               (_r + 1.) +
           (_r - 1.) * (-_se_energy[_qp] * _d_n_gamma_d_ip) *
               (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] * _mumean_en[_qp] *
                    (2. * _a - 1.) -
                5. * _v_thermal * _time_units));
  }
  // else if (jvar == _ip_id)
  // {
  //   if (_normals[_qp] * -1.0 * -_grad_potential[_qp] > 0.0)
  //   {
  //     _a = 1.0;
  //   }
  //   else
  //   {
  //     _a = 0.0;
  //   }
  //   _v_thermal =
  //       std::sqrt(8 * _e[_qp] * 2.0 / 3 * std::exp(_u[_qp] - _em[_qp]) / (M_PI * _massem[_qp]));
  //   _d_ion_flux_d_ip = _sgnip[_qp] * _muip[_qp] * -_grad_potential[_qp] * _r_units *
  //                          std::exp(_ip[_qp]) * _phi[_j][_qp] -
  //                      _Dip[_qp] * std::exp(_ip[_qp]) * _grad_phi[_j][_qp] * _r_units -
  //                      _Dip[_qp] * std::exp(_ip[_qp]) * _phi[_j][_qp] * _grad_ip[_qp] * _r_units;
  //   // _d_n_gamma_d_ip = (1. - _a) * _se_coeff[_qp] * _d_ion_flux_d_ip * _normals[_qp] / (_muem[_qp]
  //   // * -_grad_potential[_qp] * _r_units * _normals[_qp] + std::numeric_limits<double>::epsilon());
  //
  //   return _test[_i][_qp] * _r_units / (6. * (_r + 1.)) *
  //          (10. * _d_ion_flux_d_ip * _normals[_qp] * _se_energy[_qp] * _se_coeff[_qp] * (_a - 1.) *
  //               (_r + 1.) +
  //           (_r - 1.) * (-_se_energy[_qp] * _d_n_gamma_d_ip) *
  //               (6. * -_grad_potential[_qp] * _r_units * _normals[_qp] * _mumean_en[_qp] *
  //                    (2. * _a - 1.) -
  //                5. * _v_thermal));
  // }

  else
    return 0.0;
}
