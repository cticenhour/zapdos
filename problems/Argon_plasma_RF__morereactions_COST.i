dom0Scale=1

[GlobalParams]
  offset = 20
  # offset = 0
  potential_units = kV
  use_moles = true
  time_units = 1
  #potential_units = V
[]

[Mesh]
  type = FileMesh
  file = 'COST_1D_NoScaling.msh'
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
  # kernel_coverage_check = false
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    electrode_area = 0.0314159
    ballast_resist = 1e3
    e = 1.6e-19
  [../]
[]

[Variables]
  [./em]
  [../]

  [./Ar*]
  [../]

  [./Ar+]
  [../]

  [./Ar_2+]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]
[]

[Kernels]
  [./em_time_deriv]
    type = ElectronTimeDerivative
    variable = em
  [../]
  [./em_advection]
    type = EFieldAdvectionElectrons
    variable = em
    potential = potential
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_diffusion]
    type = CoeffDiffusionElectrons
    variable = em
    mean_en = mean_en
    position_units = ${dom0Scale}
  [../]
  [./em_log_stabilization]
    type = LogStabilizationMoles
    variable = em
    # offset = 30
  [../]

  [./potential_diffusion_dom0]
    type = CoeffDiffusionLin
    variable = potential
    position_units = ${dom0Scale}
  [../]

  [./Ar+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar+
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
  [../]
  [./Ar_2+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar_2+
  [../]

  [./Ar+_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar+
  [../]
  [./Ar+_advection]
    type = EFieldAdvection
    variable = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./Ar+_diffusion]
    type = CoeffDiffusion
    variable = Ar+
    position_units = ${dom0Scale}
  [../]
  [./Ar+_log_stabilization]
    type = LogStabilizationMoles
    variable = Ar+
    #offset = 20
  [../]

  [./Ar_2+_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar_2+
  [../]
  [./Ar_2+_advection]
    type = EFieldAdvection
    variable = Ar_2+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./Ar_2+_diffusion]
    type = CoeffDiffusion
    variable = Ar_2+
    position_units = ${dom0Scale}
  [../]
  [./Ar_2+_log_stabilization]
    type = LogStabilizationMoles
    variable = Ar_2+
    #offset = 20
  [../]


  [./Ar*_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar*
  [../]
  [./Ar*_diffusion]
    type = CoeffDiffusion
    variable = Ar*
    position_units = ${dom0Scale}
  [../]
  [./Ar*_log_stabilization]
    type = LogStabilizationMoles
    variable = Ar*
    #offset = 20
    offset = 30
  [../]


  [./mean_en_time_deriv]
    type = ElectronTimeDerivative
    variable = mean_en
  [../]
  [./mean_en_advection]
    type = EFieldAdvectionEnergy
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_diffusion]
    type = CoeffDiffusionEnergy
    variable = mean_en
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_joule_heating]
    type = JouleHeating
    variable = mean_en
    potential = potential
    em = em
    position_units = ${dom0Scale}
  [../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    # offset = 20
  [../]
[]


[AuxVariables]
  [./Te]
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
  [../]

  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Ar+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Ar*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]


  [./Ar_2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./Ar]
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
  [./Current_Ar]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Current_Ar2]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./tot_gas_current]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./e_temp]
    type = ElectronTemperature
    variable = Te
    electron_density = em
    mean_en = mean_en
  [../]
  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]

  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
  [../]
  [./Ar+_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar+_lin
    density_log = Ar+
  [../]
  [./Ar*_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar*_lin
    density_log = Ar*
  [../]
  [./Ar_2+_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar_2+_lin
    density_log = Ar_2+
  [../]

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 2.4463141e25
    value = 3.7043332
    execute_on = INITIAL
  [../]

  [./Efield_calc]
    type = Efield
    component = 0
    potential = potential
    variable = Efield
    position_units = ${dom0Scale}
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
  [./Current_Ar]
    type = Current
    potential = potential
    density_log = Ar+
    variable = Current_Ar
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./Current_Ar2]
    type = Current
    potential = potential
    density_log = Ar_2+
    variable = Current_Ar2
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_Ar Current_Ar2'
    function = 'Current_em + Current_Ar + Current_Ar2'
    execute_on = 'timestep_end'
    block = 0
  [../]


[]


[BCs]
  # [./potential_left]
  #   type = NeumannCircuitVoltageMoles_KV
  #   variable = potential
  #   boundary = left
  #   function = potential_bc_func
  #   ip = Ar+
  #   data_provider = data_provider
  #   em = em
  #   mean_en = mean_en
  #   r = 0
  #   position_units = ${dom0Scale}
  # [../]
  [./potential_left]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'left'
    function = potential_bc_func
  [../]
  [./potential_dirichlet_right]
    type = DirichletBC
    variable = potential
    boundary = 'right'
    value = 0
  [../]

  [./em_physical_right]
    type = HagelaarElectronBC
    variable = em
    boundary = 'right'
    potential = potential
    mean_en = mean_en
    r = 0.0
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./Ar+_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar+
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar+_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar+
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]


  [./Ar+_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar+
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar+_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar+
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./Ar*_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar*
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar*_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar*
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]


  [./Ar_2+_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar_2+
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar_2+_physical_right_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar_2+
    boundary = 'right'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar_2+_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar_2+
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar_2+_physical_left_advection]
    type = HagelaarIonAdvectionBC
    variable = Ar_2+
    boundary = 'left'
    potential = potential
    r = 0
    position_units = ${dom0Scale}
  [../]

  [./mean_en_physical_right]
    # type = HagelaarEnergyBC
    type = EnergyBC2
    variable = mean_en
    boundary = 'right'
    potential = potential
    em = em
    ip = Ar+
    args = 'Ar+ Ar_2+'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_left]
    # type = HagelaarEnergyBC
    type = EnergyBC2
    variable = mean_en
    boundary = 'left'
    potential = potential
    em = em
    ip = Ar+
    args = 'Ar+ Ar_2+'
    r = 0
    position_units = ${dom0Scale}
  [../]

[]


[ICs]
  [./em_ic]
    type = ConstantIC
    variable = em
    value = -21
  [../]
  [./Ar+_ic]
    type = ConstantIC
    variable = Ar+
    value = -21
  [../]
  [./Ar*_ic]
    type = ConstantIC
    variable = Ar*
    value = -21
  [../]
  [./Ar_2+_ic]
    type = ConstantIC
    variable = Ar_2+
    value = -24
  [../]

  [./mean_en_ic]
    type = ConstantIC
    variable = mean_en
    value = -20
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
    value = '0.240*cos(2*3.1415926*13.56e6*t)'
    # value = '0.2'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    # value = '1.25 * (1.0001e-3 - x)'
    # value = '0.2 * (1.0001e-3 - x)'
    value = '0.2*cos(0)'
  [../]
[]

# [Postprocessors]
#   [./dk_den_parsed]
#     type = ElementIntegralMaterialProperty
#     mat_prop = dk_den
#   [../]
#   # [./dk_den_exact]
#   #   type = ElementIntegralMaterialProperty
#   #   mat_prop = dk_den_exact
#   # [../]
# []

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = true
    ramp_trans_coeffs = false
    user_p_gas = 1.01325e5
    em = em
    potential = potential
    mean_en = mean_en
    user_se_coeff = 0
    #property_tables_file = electron_moments.txt
    property_tables_file = Argon_reactions/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
   type = HeavySpeciesMaterial
   heavy_species_name = Ar+
   heavy_species_mass = 6.64e-26
   heavy_species_charge = 1.0
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
  [./gas_species_4]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar_2+
    heavy_species_mass = 1.32670418e-25
    heavy_species_charge = 1.0
  [../]
  [./gas_species_7]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
[]


[ChemicalReactions]
  [./ZapdosNetwork]
    species = 'em Ar Ar* Ar+ Ar_2+'
    aux_species = 'Ar'
    reaction_coefficient_format = 'townsend'
    electron_energy = 'mean_en'
    species_energy = 'mean_en'
    electron_density = 'em'
    include_electrons = true
    potential = 'potential'
    position_units = ${dom0Scale}

    file_location = 'Argon_reactions'
    equation_constants = 'Tgas'
    equation_values = '345'
    equation_variables = 'Te Efield'

    reactions = 'em + Ar -> em + Ar                  : EEDF [elastic]
                 em + Ar -> em + Ar*                 : EEDF [-11.5]
                 em + Ar -> em + em + Ar+            : EEDF [-1.576e1]
                 em + Ar* -> em + em + Ar+           : EEDF [-4.30]
                 Ar_2+ + em -> Ar* + Ar              : {8.5e-7*((Te/1.5)*11600/300.0)^(-0.67)}
                 Ar_2+ + Ar -> Ar+ + Ar + Ar         : {(6.06e-6/Tgas)*exp(-15130.0/Tgas)}
                 Ar* + Ar* -> Ar_2+ + em             : 6.0e-10
                 Ar+ + em + e -> Ar + em             : {8.75e-27*((Te/1.5)^(-4.5))}
                 Ar* + Ar + Ar -> Ar + Ar + Ar       : 1.399e-32
                 Ar+ + Ar + Ar -> Ar_2+ + Ar         : {2.25e-31*(Tgas/300.0)^(-0.4)}'

  [../]
[]

[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
    # ksp_norm = none
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  end_time = 1e-3
  # dt = 1e-9
  #dtmax = 1e-8
  dtmax = 3.7e-9
  # num_steps = 100
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  # dt = 1e-9
  # solve_type = JFNK
  # solve_type = PJFNK
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  # petsc_options_value = 'lu NONZERO 1.e-10 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-5
  dtmin = 1e-14
  l_max_its = 20

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    growth_factor = 1.2
    optimal_iterations = 20
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = Argon_COST_rf_SCALE_long_240V
  #print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
[]
