dom0Scale=1e-3
time0Scale=1

[GlobalParams]
  offset = 20
  potential_units = kV
  use_moles = true
  time_units = ${time0Scale}
[]

[Mesh]
  type = FileMesh
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
    nl_abs_tol = 1e-8
  dtmin = 1e-12
  l_max_its = 20
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    growth_factor = 1.2
   optimal_iterations = 15
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = Zapdos_And_CRANE
  [./out]
    type = Exodus
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]

[UserObjects]
  [./data_provider]
    type = ProvideMobility
    electrode_area = 1.26e-5
    ballast_resist = 1e6
    e = 1.6e-19
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
  #[./em_ionization]
  #  type = ElectronsFromIonization
  #  variable = em
  #  potential = potential
  #  mean_en = mean_en
  #  em = em
  #  block = 0
  #  position_units = ${dom0Scale}
  #[../]
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
  [./Ar+_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = Ar+
    block = 0
  [../]
  [./em_charge_source]
    type = ChargeSourceMoles_KV
    variable = potential
    charged = em
    block = 0
  [../]

  [./Ar+_time_deriv]
    type = ElectronTimeDerivative
    variable = Ar+
    block = 0
  [../]
  [./Ar+_advection]
    type = EFieldAdvection
    variable = Ar+
    potential = potential
    position_units = ${dom0Scale}
    block = 0
  [../]
  [./Ar+_diffusion]
    type = CoeffDiffusion
    variable = Ar+
    block = 0
    position_units = ${dom0Scale}
  [../]
  #[./Ar+_ionization]
  #  type = IonsFromIonization
  #  variable = Ar+
  #  potential = potential
  #  em = em
  #  mean_en = mean_en
  #  block = 0
  #  position_units = ${dom0Scale}
  #[../]
  [./Ar+_log_stabilization]
    type = LogStabilizationMoles
    variable = Ar+
    block = 0
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
    offset = 30
  [../]

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
  #[./mean_en_ionization]
  #  type = ElectronEnergyLossFromIonization
  #  variable = mean_en
  #  potential = potential
  #  em = em
  #  block = 0
  #  position_units = ${dom0Scale}
  #[../]
  #[./mean_en_elastic]
  #  type = ElectronEnergyLossFromElastic
  #  variable = mean_en
  #  potential = potential
  #  em = em
  #  block = 0
  #  position_units = ${dom0Scale}
  #[../]
  #[./mean_en_excitation]
  #  type = ElectronEnergyLossFromExcitation
  #  variable = mean_en
  #  potential = potential
  #  em = em
  #  block = 0
  #  position_units = ${dom0Scale}
  #[../]
  [./mean_en_log_stabilization]
    type = LogStabilizationMoles
    variable = mean_en
    block = 0
    offset = 15
  [../]
[]

[Variables]
  [./potential]
  [../]
  [./em]
    block = 0
  [../]
  [./Ar+]
    block = 0
  [../]
  [./Ar*]
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
  [./Ar+_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Ar*_lin]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./Ar]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 3.7043332
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
[]

[AuxKernels]
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
  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
    block = 0
  [../]
  [./Ar+_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar+_lin
    density_log = Ar+
    block = 0
  [../]
  [./Ar*_lin]
    type = DensityMoles
    convert_moles = true
    variable = Ar*_lin
    density_log = Ar*
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
    density_log = Ar+
    variable = Current_Arp
    art_diff = false
    block = 0
    position_units = ${dom0Scale}
  [../]
  [./tot_gas_current]
    type = ParsedAux
    variable = tot_gas_current
    args = 'Current_em Current_Arp'
    function = 'Current_em + Current_Arp'
    execute_on = 'timestep_end'
    block = 0
  [../]
[]

[BCs]
  [./potential_left]
    type = NeumannCircuitVoltageMoles_KV
    variable = potential
    boundary = left
    function = potential_bc_func
    ip = Ar+
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
    ip = Ar+
    mean_en = mean_en
    r = 0.99
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
  [./Ar*_physical_right_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar*
    boundary = 'left'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./Ar*_physical_left_diffusion]
    type = HagelaarIonDiffusionBC
    variable = Ar*
    boundary = 'right'
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./mean_en_physical_right]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'right'
    potential = potential
    em = em
    ip = Ar+
    r = 0.99
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = HagelaarElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Ar+
    mean_en = mean_en
    r = 0
    position_units = ${dom0Scale}
  [../]
  [./sec_electrons_left]
    type = SecondaryElectronBC
    variable = em
    boundary = 'left'
    potential = potential
    ip = Ar+
    mean_en = mean_en
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
  [./mean_en_physical_left]
    type = HagelaarEnergyBC
    variable = mean_en
    boundary = 'left'
    potential = potential
    em = em
    ip = Ar+
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
  [./Ar+_ic]
    type = ConstantIC
    variable = Ar+
    value = -21
    block = 0
  [../]
  [./Ar*_ic]
    type = ConstantIC
    variable = Ar*
    value = -21
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
    value = 0.200
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '-0.200 * (1.000e-3 - x)'
  [../]
[]

[Materials]
  [./gas_block]
    type = GasElectronMoments
    interp_trans_coeffs = true
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    em = em
    potential = potential
    #ip = Ar+
    user_p_gas = 1.01e5
    mean_en = mean_en
    user_se_coeff = .05
    block = 0
    property_tables_file = Argon_reactions_GEC/electron_moments.txt
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
 [./gas_species_7]
   type = HeavySpeciesMaterial
   heavy_species_name = Ar
   heavy_species_mass = 6.64e-26
   heavy_species_charge = 0.0
 [../]
 [./cathode_boundary]
   type = GenericConstantMaterial
   prop_names = 'T_heavy'
   prop_values = '293'
 [../]
[]

[ChemicalReactions]
  [./ZapdosNetwork]
    species = 'Ar* em Ar+'
    aux_species = 'Ar'
    reaction_coefficient_format = 'townsend'
    gas_species = 'Ar'
    electron_energy = 'mean_en'
    species_energy = 'mean_en'
    electron_density = 'em'
    include_electrons = true
    file_location = 'Argon_reactions_GEC'
    potential = 'potential'
    position_units = ${dom0Scale}

    # equation_variables = 'e_temp'
    equation_constants = 'NA'
    equation_values = '6.022e23'

    # constant_names = 'Tgas'
    # constant_expressions = '1'

    reactions = 'em + Ar -> em + Ar                  : EEDF [elastic]
                 em + Ar -> em + Ar*                 : EEDF [-11.5]
                 em + Ar -> em + em + Ar+            : EEDF [-1.576e1]'
                 # Ar* + Ar* -> Ar+ + Ar + em          : 2.3e-15
  [../]
[]
