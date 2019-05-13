dom0Scale=25.4e-3


[GlobalParams]
  #offset = 20
  potential_units = kV
  use_moles = true
  time_units = 1
  alpha = 0.5
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

[Variables]
  [./em]
  [../]

  [./Ar+]
  [../]

  [./mean_en]
  [../]

  [./potential]
  [../]
[]

[Kernels]
  #Electron Equations (Same as in paper)
    #Time Derivative term of electron
    [./em_time_deriv]
      type = ElectronTimeDerivative
      variable = em
    [../]
    [./em_time_deriv_SUPG]
      type = TimeDerivativeSUPG
      variable = em
      potential = potential
      position_units = ${dom0Scale}
      tau_name = tauem
    [../]
    #Advection term of electron
    [./em_advection]
      type = EFieldAdvectionElectrons
      variable = em
      potential = potential
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]
    [./em_advection_SUPG]
      type = EFieldAdvectionSUPG
      variable = em
      potential = potential
      tau_name = tauem
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons
    [./em_diffusion]
      type = CoeffDiffusionElectrons
      variable = em
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]
    [./em_diffusion_SUPG]
      type = CoeffDiffusionSUPG
      variable = em
      var_for_second_derivative = em
      potential = potential
      tau_name = tauem
      position_units = ${dom0Scale}
    [../]
    #Net electron production from ionization
    [./em_ionization]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = Ar
      energy = mean_en
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
    [../]
    [./em_ionization_SUPG]
      type = ReactantSecondOrderLogSUPG
      variable = em
      v = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
      tau_name = tauem
      potential = potential
      position_units = ${dom0Scale}
    [../]
    #Log Offset for electron density, not in paper since Zapdos uses an exponent form of density
    #[./em_log_stabilization]
    #  type = LogStabilizationMoles
    #  variable = em
    #[../]

  #Argon Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./Ar+_time_deriv]
      type = ElectronTimeDerivative
      variable = Ar+
    [../]
    [./Ar+_time_deriv_SUPG]
      type = TimeDerivativeSUPG
      variable = Ar+
      potential = potential
      position_units = ${dom0Scale}
      tau_name = tauAr+
    [../]
    #Advection term of ions
    [./Ar+_advection]
      type = EFieldAdvection
      variable = Ar+
      potential = potential
      position_units = ${dom0Scale}
    [../]
    [./Ar+_advection_SUPG]
      type = EFieldAdvectionSUPG
      variable = Ar+
      potential = potential
      tau_name = tauAr+
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons
    [./Ar+_diffusion]
      type = CoeffDiffusion
      variable = Ar+
      position_units = ${dom0Scale}
    [../]
    [./Ar+_diffusion_SUPG]
      type = CoeffDiffusionSUPG
      variable = Ar+
      var_for_second_derivative = Ar+
      potential = potential
      tau_name = tauAr+
      position_units = ${dom0Scale}
    [../]
    #Net ion production from ionization
    [./Ar+_ionization]
      type = ElectronProductSecondOrderLog
      variable = Ar+
      electron = em
      target = Ar
      energy = mean_en
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
    [../]
    [./Ar+_ionization_SUPG]
      type = ProductSecondOrderLogSUPG
      variable = Ar+
      v = em
      w = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      coefficient = 1
      potential = potential
      tau_name = tauAr+
      position_units = ${dom0Scale}
    [../]
   #Log Offset for excited atom density, not in paper since Zapdos uses an exponent form of density
    #[./Ar+_log_stabilization]
    #  type = LogStabilizationMoles
    #  variable = Ar+
    #[../]

  #Voltage Equations (Same as in paper)
    #Voltage term in Poissons Eqaution
    [./potential_diffusion_dom0]
      type = CoeffDiffusionLin
      variable = potential
      position_units = ${dom0Scale}
    [../]
    #Ion term in Poissons Equation
    [./Ar+_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = Ar+
    [../]
    #Electron term in Poissons Equation
    [./em_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = em
    [../]


  #Since the paper uses electron temperature as a variable, the energy equation is in
  #a different form but should be the same physics
    #Time Derivative term of electron energy
    [./mean_en_time_deriv]
      type = ElectronTimeDerivative
      variable = mean_en
    [../]
    [./mean_en_time_deriv_SUPG]
      type = TimeDerivativeSUPG
      variable = mean_en
      potential = potential
      position_units = ${dom0Scale}
      tau_name = taumean_en
    [../]
    #Advection term of electron energy
    [./mean_en_advection]
      type = EFieldAdvectionEnergy
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    [./mean_en_advection_SUPG]
      type = EFieldAdvectionSUPG
      variable = mean_en
      potential = potential
      tau_name = taumean_en
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons energy
    [./mean_en_diffusion]
      type = CoeffDiffusionEnergy
      variable = mean_en
      em = em
      position_units = ${dom0Scale}
    [../]
    [./mean_en_diffusion_SUPG]
      type = CoeffDiffusionSUPG
      variable = mean_en
      var_for_second_derivative = mean_en
      potential = potential
      tau_name = taumean_en
      position_units = ${dom0Scale}
    [../]
    #Joule Heating term
    [./mean_en_joule_heating]
      type = JouleHeating
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    [./mean_en_joul_heating_SUPG]
      type = JouleHeatingSUPG
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
      tau_name = taumean_en
    [../]
    #Energy loss from ionization
    [./Ionization_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      threshold_energy = -15.7
      position_units = ${dom0Scale}
    [../]
    [./Ionization_Loss_SUPG]
      type = ElectronEnergyTermRateSUPG
      variable = mean_en
      em = em
      v = Ar
      reaction = 'em + Ar -> em + em + Ar+'
      threshold_energy = -15.7
      position_units = ${dom0Scale}
      tau_name = taumean_en
      potential = potential
    [../]
    #Energy loss from excitation
    #[./Excitation_Loss]
    #  type = ElectronEnergyTermRate
    #  variable = mean_en
    #  em = em
    #  v = Ar
    #  reaction = 'em + Ar -> em + Ar*'
    #  threshold_energy = -11.56
    #  position_units = ${dom0Scale}
    #[../]
    #[./Exitation_Loss_SUPG]
    #  type = ElectronEnergyTermRateSUPG
    #  variable = mean_en
    #  em = em
    #  v = Ar
    #  reaction = 'em + Ar -> em + Ar*'
    #  threshold_energy = -11.56
    #  position_units = ${dom0Scale}
    #  tau_name = taumean_en
    #  potential = potential
    #[../]

    #Log Offset for excited atom density, not in paper since Zapdos uses an exponent form of density
    #[./mean_en_log_stabilization]
    #  type = LogStabilizationMoles
    #  variable = mean_en
    #  #offset = 15
    #[../]
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
[]

[AuxKernels]
  [./Te]
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

  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 2.4463141e25
    #value = 3.7043332
    # value = 3.22e22
    value = -2.928623
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

#New Boundary conditions for electons, should be same as in paper
#Checked Once, might need to check again later
  [./em_physical_right]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'right'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]
  [./em_physical_left]
    type = LymberopoulosElectronBC
    variable = em
    boundary = 'left'
    gamma = 0.01
    ks = 1.19e5
    ion = Ar+
    potential = potential
    position_units = ${dom0Scale}
  [../]

#New Boundary conditions for ions, should be the same as in paper
#Checked Once, should be good
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
    #value = '0.100*sin(0)'
    value = '0.200 * (25.4e-3 - x)*x'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    #value = '-24.82127 + -20.2161 * (1-x/1)^2 * (x/1)^2'
    value = 'log((1e7 + 1e9 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    #value = -20
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    #value = '-24.82127 + -20.2161 * (1-x/1)^2 * (x/1)^2'
    #value = 'log((3./2.)*1*1.3807e-23*(1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    value = 'log(3./2.) + log((1e7 + 1e9 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
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
    user_se_coeff = 0.00
    #property_tables_file = electron_moments.txt
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
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
  [../]
  [./reaction_0]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + Ar*.txt'
    reaction = 'em + Ar -> em + Ar*'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_1]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar -> em + em + Ar+.txt'
    reaction = 'em + Ar -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./Tau_em]
    type = ADMaterialsPlasmaSUPG
    species_name = em
    potential = potential
    position_units = ${dom0Scale}
    transient_term = true
  [../]
  [./Tau_Ar+]
    type = ADMaterialsPlasmaSUPG
    species_name = Ar+
    potential = potential
    position_units = ${dom0Scale}
    transient_term = true
  [../]
  [./Tau_mean_en]
    type = ADMaterialsPlasmaSUPG
    species_name = mean_en
    potential = potential
    position_units = ${dom0Scale}
    transient_term = true
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
  end_time = 1e-1
  dtmax = 3.7e-9
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  # dt = 1e-9
  # solve_type = JFNK
  # solve_type = PJFNK
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  #petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  #petsc_options_value = 'lu NONZERO 1.e-10 preonly 1e-3'
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
  #file_base = 'StabTest_SUPG_Trans'
  [./out]
    type = Exodus
  [../]
[]
