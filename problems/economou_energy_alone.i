[Mesh]
  type = GeneratedMesh
  xmin = 0
  xmax = 2.54
  nx = 10
  dim = 1
[]

[Materials]
  [./argon_ionization]
    type = GenericConstantMaterial
    prop_names = ki
    prop_values = 6.02909e-11
  [../]
  [./argon_excitation]
    type = GenericConstantMaterial
    prop_names = kex
    prop_values = 1.35369e-10
  [../]
  [./diffusioncoeff_en]
    type = GenericConstantMaterial
    prop_names = diffmean_en
    prop_values = 1.988e6
  [../]
  [./advectioncoeff_en]
    type = GenericConstantMaterial
    prop_names = mumean_en
    prop_values = 3e5
  [../]
[]

[Variables]
  [./mean_en]
  [../]
[]

[AuxVariables]
  [./ne]
    order = FIRST
    family = LAGRANGE
  [../]
  [./potential]
    order = FIRST
    family = LAGRANGE
  [../]
  [./mean_en_lin]
    order = FIRST
    family = LAGRANGE
  [../]
  [./mean_en_MMS]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxKernels]
  [./ne_MMS]
    type = FunctionAux
    variable = ne
    function = ne_profile_func
  [../]
  [./potential_MMS]
    type = FunctionAux
    variable = potential
    function = potential_func
  [../]
  [./mean_en_lin]
    type = Density
    variable = mean_en_lin
    density_log = mean_en
  [../]
  [./mean_en_MMS]
    type = FunctionAux
    variable = mean_en_MMS
    function = energy_profile_func
  [../]
[]

[Kernels]
  [./energy_diffusion]
    type = CoupledEnergyDiffusion
    variable = mean_en
    diffusivity = 1.988e6
    electrons = 16.8112428315
  [../]
  [./energy_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    electrons = 16.8112428315
    mobility = 3e5
    potential = potential
  [../]
  [./energy_electron_diffusion]
    type = ElectronDiffusionEnergy
    variable = mean_en
    diffusivity = 1.988e6
    electrons = ne
  [../]
  [./energy_joule_heating]
    type = JouleHeating
    variable = mean_en
    electrons = ne
    potential = potential
    diffusivity = 1.988e6
    mobility = 3e5
  [../]
  [./energy_gnd_state_excitation]
    type = EnergyExcitation
    variable = mean_en
    electrons = ne
    background_gas_density = 3.22e16
  [../]
  [./energy_gnd_state_ionization]
    type = EnergyIonization
    variable = mean_en
    electrons = ne
    background_gas_density = 3.22e16
  [../]
  [./energy_rhs]
    type = BodyForce
    function = energy_rhs_func
    variable = mean_en
  [../]
[]

[BCs]
  [./left_energy]
    type = FunctionDirichletBC
    variable = mean_en
    function = energy_bc_left
    boundary = left
  [../]
  [./right_energy]
    type = FunctionDirichletBC
    variable = mean_en
    function = energy_bc_right
    boundary = right
  [../]
[]

[Functions]
  [./energy_bc_left]
    type = ParsedFunction
    value = 'log(4.0)'
  [../]
  [./energy_bc_right]
    type = ParsedFunction
    value = 'log(12.0)'
  [../]
  [./potential_func]
    type = ParsedFunction
    value = '0.2 * (-x^2 + 2.54 * x)'
  [../]
  [./ne_profile_func]
    type = ParsedFunction
    value = 'log(2e7)'
  [../]
  [./energy_profile_func]
    type = ParsedFunction
    value = 'exp((log(9.0) / 2.54) * x) + 3'
  [../]
  [./energy_linear]
    type = ParsedFunction
    value = 'log(exp((log(9.0) / 2.54) * x) + 3)'
  [../]
  [./energy_rhs_func]
    type = ParsedFunction
    value = '1.4417484103256*(-2400000000000.0*x + 3048000000000.0)*exp(0.865049046195362*x) - 4000000000000.0*exp(0.865049046195362*x) - 12000000000000.0'
  [../]
[]

[Preconditioning]
  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
  #petsc_options = '-snes_check_jacobian'
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  execute_on = 'TIMESTEP_END'
  csv = true
  print_linear_residuals = true
  perf_graph = true
[]
