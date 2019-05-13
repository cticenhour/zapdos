dom0Scale=1e-3

[GlobalParams]
  offset = 25
  # offset = 0
  potential_units = kV
  use_moles = true
  # potential_units = V
[]

[Mesh]
  # type = GeneratedMesh
  # nx = 2
  # xmax = 1.1
  # dim = 1
  type = FileMesh
  #file = 'just_plasma.msh'
  file = 'GEC_mesh.msh'
[]

[MeshModifiers]
  [./left]
    type = SideSetsFromNormals
    normals = '-1 0 0'
    new_boundary = 'left'
  [../]
  [./right]
    type = SideSetsFromNormals
    normals = '1 0 0'
    new_boundary = 'right'
  [../]
[]

[Problem]
  type = FEProblem
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    ksp_norm = none
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e-1
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 preonly 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-5
  dtmin = 1e-12
  l_max_its = 20
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    # dt = 1.1
    growth_factor = 1.2
   optimal_iterations = 15
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = PlasmaOnly__Offset25_V200_T
  # print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
  #[./dof_map]
  #  type = DOFMap
  #  execute_on = 'initial'
  #[../]
[]

[Debug]
  show_var_residual_norms = true
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    # electrode_area = 5.02e-7 # This one works
    electrode_area = 1.26e-5
    ballast_resist = 1e6
    e = 1.6e-19
    # electrode_area = 1.1
    # ballast_resist = 1.1
    # e = 1.1
  [../]
[]

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
    block = 0
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_ionization]
    type = ElectronsFromIonization
    variable = em
    potential = potential
    mean_en = mean_en
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
    block = 0
  [../]

  [./potential_diffusion_dom1]
    type = CoeffDiffusionLin
    variable = potential
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Arp
    block = 0
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
    block = 0
  [../]

  [./Arp_time_deriv]
    type = ElectronTimeDerivative
    variable = Arp
    block = 0
  [../]
  [./Arp_advection]
    type = EFieldAdvection
    variable = Arp
    potential = potential
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./Arp_diffusion]
    type = CoeffDiffusion
    variable = Arp
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_ionization]
    type = IonsFromIonization
    variable = Arp
    potential = potential
    em = em
    mean_en = mean_en
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_log_stabilization]
    type = LogStabilizationMoles
    variable = Arp
    block = 0
  [../]
  # [./Arp_advection_stabilization]
  #   type = EFieldArtDiff
  #   variable = Arp
  #   potential = potential
  #   block = 0
  # [../]


  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
    block = 0
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_ionization]
    type = ElectronEnergyLossFromIonization
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_elastic]
    type = ElectronEnergyLossFromElastic
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_excitation]
    type = ElectronEnergyLossFromExcitation
    variable = mean_en
    potential = potential
    em = em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    block = 0
    offset = 20
  [../]
  # [./mean_en_advection_stabilization]
  #   type = EFieldArtDiff
  #   variable = mean_en
  #   potential = potential
  #   block = 0
  # [../]
[]

[Variables]
  [./potential]
  [../]
  [./em]
    block = 0
  [../]
  [./Arp]
    block = 0
  [../]

  [./mean_en]
    block = 0
  [../]
[]

[AuxVariables]
  [./e_temp]
    block = 0
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./x_node]
  [../]
  [./rho]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Arp_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Efield]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Current_Arp]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./tot_gas_current]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./EFieldAdvAux_em]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./DiffusiveFlux_em]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./PowerDep_em]
   order = CONSTANT
   family = MONOMIAL
   block = 0
  [../]
  [./PowerDep_Arp]
   order = CONSTANT
   family = MONOMIAL
   block = 0
  [../]
  [./ProcRate_el]
   order = CONSTANT
   family = MONOMIAL
   block = 0
  [../]
  [./ProcRate_ex]
   order = CONSTANT
   family = MONOMIAL
   block = 0
  [../]
  [./ProcRate_iz]
   order = CONSTANT
   family = MONOMIAL
   block = 0
  [../]
[]

[AuxKernels]
  [./PowerDep_em]
    type = PowerDep
    density_log = em
    potential = potential
    art_diff = false
    potential_units = kV
    variable = PowerDep_em
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./PowerDep_Arp]
    type = PowerDep
    density_log = Arp
    potential = potential
    art_diff = false
    potential_units = kV
    variable = PowerDep_Arp
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./ProcRate_el]
    type = ProcRate
    em = em
    potential = potential
    proc = el
    variable = ProcRate_el
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./ProcRate_ex]
    type = ProcRate
    em = em
    potential = potential
    proc = ex
    variable = ProcRate_ex
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./ProcRate_iz]
    type = ProcRate
    em = em
    potential = potential
    proc = iz
    variable = ProcRate_iz
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./e_temp]
    type = ElectronTemperature
    variable = e_temp
    electron_density = em
    mean_en = mean_en
    block = 0
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./rho]
    type = ParsedAux
    variable = rho
    args = 'em_lin Arp_lin'
    function = 'Arp_lin - em_lin'
    execute_on = 'timestep_end'
    block = 0
  [../]
  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_Arp'
    function = 'Current_em + Current_Arp'
    execute_on = 'timestep_end'
    block = 0
  [../]
  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
    block = 0
  [../]
  [./Arp_lin]
    type = DensityMoles
    convert_moles = true
    variable = Arp_lin
    density_log = Arp
    block = 0
  [../]
  [./Efield_g]
    type = Efield
    component = 0
    potential = potential
    variable = Efield
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./Current_em]
    type = Current
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Current_Arp]
    type = Current
    potential = potential
    density_log = Arp
    variable = Current_Arp
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./EFieldAdvAux_em]
    type = EFieldAdvAux
    potential = potential
    density_log = em
    variable = EFieldAdvAux_em
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./DiffusiveFlux_em]
    type = DiffusiveFlux
    density_log = em
    variable = DiffusiveFlux_em
    block = 0
    position_units = ${dom0Scale}
  [../]
[]

[BCs]
  [./potential_left]
    type = NeumannCircuitVoltageMoles_KV
    variable = potential
    boundary = left
    function = potential_bc_func
    ip = Arp
    data_provider = data_provider
    em = em
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = right
    value = 0
  [../]
  [./em_physical_right]
    type = HagelaarElectronBC
    variable = em
    boundary = 'right'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0.99
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_right]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'right'
    potential = potential
    em = em
    ip = Arp
    r = 0.99
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./sec_electrons_left]
    type = SecondaryElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Arp
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Arp
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Arp_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Arp
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_left]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'left'
    potential = potential
    em = em
    ip = Arp
    r = 0
    position_units = ${dom0Scale}
  [../]
[]

[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = -21
    block = 0
  [../]
  [./Arp_ic]
    type = ConstantIC
    variable = Arp
    value = -21
    block = 0
  [../]
  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20
    block = 0
  [../]
  [./potential_ic]
    type = FunctionIC
    variable = potential
    function = potential_ic_func
  [../]
[]

[Functions]
  [./potential_bc_func]
    type = ParsedFunction
    # value = '1.25*tanh(1e6*t)'
    value = 0.2
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '-0.2 * (1.000e-3 - x)'
  [../]
[]

[Materials]
  [./gas_block]
    type = Gas
    interp_trans_coeffs = true
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    em = em
    potential = potential
    ip = Arp
    mean_en = mean_en
    user_se_coeff = .05
    block = 0
    property_tables_file = td_argon_mean_en.txt
 [../]
[]
