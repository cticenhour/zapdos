dom0Scale=25.4e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'Lymberopoulos.msh'
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

[AuxVariables]
  [./emDeBug]
  [../]
  [./Ar+_DeBug]
  [../]
  [./Ar*_DeBug]
  [../]
  [./mean_enDeBug]
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

  [./Ar]
  [../]

  [./emRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./exRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./swRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./deexRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./quRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./poolRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./TwoBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
  [./ThreeBRate]
    order = CONSTANT
    family = MONOMIAL
    block = 0
  [../]
[]

[AuxKernels]
  [./emDeBug]
    type = DebugResidualAux
    variable = emDeBug
    debug_variable = em
    #execute_on = 'LINEAR NONLINEAR TIMESTEP_BEGIN'
  [../]
  [./Ar+_DeBug]
    type = DebugResidualAux
    variable = Ar+_DeBug
    debug_variable = Ar+
    #execute_on = 'LINEAR NONLINEAR TIMESTEP_BEGIN'
  [../]
  [./mean_enDeBug]
    type = DebugResidualAux
    variable = mean_enDeBug
    debug_variable = mean_en
    #execute_on = 'LINEAR NONLINEAR TIMESTEP_BEGIN'
  [../]
  [./Ar*_DeBug]
    type = DebugResidualAux
    variable = Ar*_DeBug
    debug_variable = Ar*
    #execute_on = 'LINEAR NONLINEAR TIMESTEP_BEGIN'
  [../]

  [./emRate]
    type = ProcRateForRateCoeff
    variable = emRate
    v = em
    w = Ar
    reaction = 'em + Ar -> em + em + Ar+'
  [../]
  [./exRate]
    type = ProcRateForRateCoeff
    variable = exRate
    v = em
    w = Ar*
    reaction = 'em + Ar -> em + Ar*'
  [../]
  [./swRate]
    type = ProcRateForRateCoeff
    variable = swRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + em + Ar+'
  [../]
  [./deexRate]
    type = ProcRateForRateCoeff
    variable = deexRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + Ar'
  [../]
  [./quRate]
    type = ProcRateForRateCoeff
    variable = quRate
    v = em
    w = Ar*
    reaction = 'em + Ar* -> em + Ar_r'
  [../]
  [./poolRate]
    type = ProcRateForRateCoeff
    variable = poolRate
    v = Ar*
    w = Ar*
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
  [../]
  [./TwoBRate]
    type = ProcRateForRateCoeff
    variable = TwoBRate
    v = Ar*
    w = Ar
    reaction = 'Ar* + Ar -> Ar + Ar'
  [../]
  [./ThreeBRate]
    type = ProcRateForRateCoeffThreeBody
    variable = ThreeBRate
    v = Ar*
    w = Ar
    vv = Ar
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
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

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 3.22e22
    value = -2.928623
    execute_on = INITIAL
  [../]

[]

[DriftDiffusionAction]
  Ions = Ar+
  Neutrals = Ar*
  CRANE_Coupled = true
  block = 0
  position_units = 25.4e-3
  potential_units = kV
  use_moles = true
  Additional_Outputs = 'Current EField ElectronTemperature'
  component = 0
[../]

[ChemicalReactions]
  [./ZapdosNetwork]
    species = 'Ar* em Ar+'
    aux_species = 'Ar'
    reaction_coefficient_format = 'rate'
    gas_species = 'Ar'
    electron_energy = 'mean_en'
    species_energy = 'mean_en'
    sampling_variable = 'electron_energy'
    electron_density = 'em'
    include_electrons = true
    file_location = 'Argon_reactions_paper_RateCoefficients'
    potential = 'potential'
    use_log = true
    position_units = ${dom0Scale}

    reactions = 'em + Ar -> em + Ar*              : EEDF [-11.56]
                 em + Ar -> em + em + Ar+         : EEDF [-15.7]
                 em + Ar* -> em + Ar              : EEDF [11.56]
                 em + Ar* -> em + em + Ar+        : EEDF [-4.14]
                 em + Ar* -> em + Ar_r            : 1.2044e11
                 Ar* + Ar* -> Ar+ + Ar + em       : 373364000
                 Ar* + Ar -> Ar + Ar              : 1806.6
                 Ar* + Ar + Ar -> Ar_2 + Ar       : 398909.324'
  [../]
[]

[BCs]
#Voltage Boundary Condition, same as in paper
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

#New Boundary conditions for electons, same as in paper
  [./em_physical_right]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    #gamma = 1
    ks = 1.19e5
    #ks = 0.0
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
  [./Ar+_physical_right_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'right'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_physical_left_advection]
    type = LymberopoulosIonBC
    variable = Ar+
    potential = potential
    boundary = 'left'
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
#(except the metastables are not set to zero, since Zapdos uses log form)
  [./Ar*_physical_right_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'right'
    value = 100
  [../]
  [./Ar*_physical_left_diffusion]
    type = LogDensityDirichletBC
    variable = Ar*
    boundary = 'left'
    value = 100
  [../]

#New Boundary conditions for mean energy, should be the same as in paper
  [./mean_en_physical_right]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'right'
  [../]
  [./mean_en_physical_left]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.5
    boundary = 'left'
  [../]

[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  [../]
  [./Ar+_ic]
    type = FunctionIC
    variable = Ar+
    function = density_ic_func
  [../]
  [./Ar*_ic]
    type = FunctionIC
    variable = Ar*
    function = density_ic_func
  [../]
  [./mean_en_ic]
    type = FunctionIC
    variable = mean_en
    function = energy_density_ic_func
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
    value = '0.100*sin(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '0.100 * (25.4e-3 - x)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 133.322
    em = em
    potential = potential
    mean_en = mean_en
    user_electron_mobility = 30.0
    user_electron_diffusion_coeff = 119.8757763975
    property_tables_file = Argon_reactions_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 0.144409938
    diffusivity = 6.428571e-3
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 7.515528e-3
  [../]
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
[]

#New postprocessor that calculates the inverse of the plasma frequency
[Postprocessors]
  [./InversePlasmaFreq]
    type = PlasmaFrequencyInverse
    variable = em
    use_moles = true
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]


[Preconditioning]
  active = 'smp'
  [./smp]
    type = SMP
    full = true
  [../]

  [./fdp]
    type = FDP
    full = true
  [../]
[]


[Executioner]
  type = Transient
  end_time = 3e-7
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  nl_rel_tol = 1e-8
  #nl_abs_tol = 7.6e-5
  dtmin = 1e-14
  l_max_its = 20

  #Time steps based on the inverse of the plasma frequency
  [./TimeStepper]
    type = PostprocessorDT
    postprocessor = InversePlasmaFreq
  [../]
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
