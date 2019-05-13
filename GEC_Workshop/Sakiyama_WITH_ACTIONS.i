dom0Scale=1e-3

[GlobalParams]
  potential_units = kV
  use_moles = true
[]

[Mesh]
  type = FileMesh
  file = 'Sakiyama.msh'
[]


[Problem]
  type = FEProblem
[]

#[Adaptivity]
#  max_h_level = 3
#  marker = marker
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = em
#    [../]
#  [../]
#  [./Markers]
#    [./marker]
#      type = ErrorFractionMarker
#      coarsen = 0.4
#      indicator = error
#      refine = 0.7
#    [../]
#  [../]
#[]

[AuxVariables]
  [./He]
  [../]
  [./N2]
  [../]

  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./N2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He2*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./x_node]
  [../]

  [./mean_en_eV]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./e_temp]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./EfieldX]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./EfieldY]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./em_current]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./HeIon_current]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He2Ion_current]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./N2Ion_current]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Total_current]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./surface_charge]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./He_val]
    type = ConstantAux
    variable = He
    # value = 2.504e25
    value = 3.727640209
    execute_on = INITIAL
  [../]
  [./N2_val]
    type = ConstantAux
    variable = N2
    # value = 3.22e22
    value = -10.08786723
    execute_on = INITIAL
  [../]

  [./mean_en_eV]
    type = ParsedAux
    variable = mean_en_eV
    args = 'e_temp'
    function = '(3.0/2.0)*e_temp'
    #execute_on = 'LINEAR TIMESTEP_END'
    block = 'plasma'
  [../]
  [./e_temp]
    type = ElectronTemperature
    variable = e_temp
    electron_density = em
    mean_en = mean_en
  [../]
  [./Efield_calcX]
    type = Efield
    component = 0
    potential = potential
    variable = EfieldX
    position_units = ${dom0Scale}
  [../]
  [./Efield_calcY]
    type = Efield
    component = 1
    potential = potential
    variable = EfieldY
    position_units = ${dom0Scale}
  [../]

  [./em_lin]
    type = DensityMoles
    convert_moles = true
    variable = em_lin
    density_log = em
  [../]
  [./He+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He+_lin
    density_log = He+
  [../]
  [./He2+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He2+_lin
    density_log = He2+
  [../]
  [./He*_lin]
    type = DensityMoles
    convert_moles = true
    variable = He*_lin
    density_log = He*
  [../]
  [./He2*_lin]
    type = DensityMoles
    convert_moles = true
    variable = He2*_lin
    density_log = He2*
  [../]
  [./N2+_lin]
    type = DensityMoles
    convert_moles = true
    variable = N2+_lin
    density_log = N2+
  [../]

  [./x_g]
    type = Position
    variable = x
    position_units = ${dom0Scale}
  [../]
  [./y_g]
    type = Position
    variable = y
    position_units = ${dom0Scale}
  [../]
  [./x_ng]
    type = Position
    variable = x_node
    position_units = ${dom0Scale}
  [../]

  [./em_current]
    type = Current
    variable = em_current
    density_log = em
    potential = potential
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./HeIon_current]
    type = Current
    variable = HeIon_current
    density_log = He+
    potential = potential
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./He2Ion_current]
    type = Current
    variable = He2Ion_current
    density_log = He2+
    potential = potential
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./N2Ion_current]
    type = Current
    variable = N2Ion_current
    density_log = N2+
    potential = potential
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./Total_current]
    type = ParsedAux
    variable = Total_current
    args = 'em_current HeIon_current He2Ion_current N2Ion_current'
    function = 'em_current + HeIon_current + He2Ion_current + N2Ion_current'
    #execute_on = 'LINEAR TIMESTEP_END'
    block = 'plasma'
  [../]

  [./surface_charge]
    type = VariableTimeIntegrationAux
    variable = surface_charge
    variable_to_integrate = Total_current
  [../]
[]

#[DriftDiffusionAction]
#  Ions = 'He+ He2+ N2+'
#  Neutrals = 'He* He2*'
#  CRANE_Coupled = true
#  block = 'plasma'
#  position_units = ${dom0Scale}
#  potential_units = kV
#  use_moles = true
#  Additional_Outputs = 'EField ElectronTemperature'
#  component = 0
#[../]

[Variables]
  [./em]
  [../]

  [./He+]
  [../]

  [./He2+]
  [../]

  [./N2+]
  [../]

  [./He*]
  [../]

  [./He2*]
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
    #Advection term of electron
    [./em_advection]
      type = EFieldAdvectionElectrons
      variable = em
      potential = potential
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons
    [./em_diffusion]
      type = CoeffDiffusionElectrons
      variable = em
      mean_en = mean_en
      position_units = ${dom0Scale}
    [../]

  #He Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./He+_time_deriv]
      type = ElectronTimeDerivative
      variable = He+
    [../]
    #Advection term of ions
    [./He+_advection]
      type = EFieldAdvection
      variable = He+
      potential = potential
      position_units = ${dom0Scale}
    [../]
    [./He+_diffusion]
      type = CoeffDiffusion
      variable = He+
      position_units = ${dom0Scale}
    [../]

  #He2 Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./He2+_time_deriv]
      type = ElectronTimeDerivative
      variable = He2+
    [../]
    #Advection term of ions
    [./He2+_advection]
      type = EFieldAdvection
      variable = He2+
      potential = potential
      position_units = ${dom0Scale}
    [../]
    [./He2+_diffusion]
      type = CoeffDiffusion
      variable = He2+
      position_units = ${dom0Scale}
    [../]

  #N2 Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./N2+_time_deriv]
      type = ElectronTimeDerivative
      variable = N2+
    [../]
    #Advection term of ions
    [./N2+_advection]
      type = EFieldAdvection
      variable = N2+
      potential = potential
      position_units = ${dom0Scale}
    [../]
    [./N2+_diffusion]
      type = CoeffDiffusion
      variable = N2+
      position_units = ${dom0Scale}
    [../]

  #He Excited Equations (Same as in paper)
    #Time Derivative term of excited Argon
    [./He*_time_deriv]
      type = ElectronTimeDerivative
      variable = He*
    [../]
    #Diffusion term of excited Argon
    [./He*_diffusion]
      type = CoeffDiffusion
      variable = He*
      position_units = ${dom0Scale}
    [../]

  #He2 Excited Equations (Same as in paper)
    #Time Derivative term of excited Argon
    [./He2*_time_deriv]
      type = ElectronTimeDerivative
      variable = He2*
    [../]
    #Diffusion term of excited Argon
    [./He2*_diffusion]
      type = CoeffDiffusion
      variable = He2*
      position_units = ${dom0Scale}
    [../]

  #Voltage Equations (Same as in paper)
    #Voltage term in Poissons Eqaution
    [./potential_diffusion_dom0]
      type = CoeffDiffusionLin
      variable = potential
      position_units = ${dom0Scale}
    [../]
    #Ion term in Poissons Equation
    [./He+_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = He+
    [../]
    [./He2+_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = He2+
    [../]
    [./N2+_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = N2+
    [../]
    #Electron term in Poissons Equation
    [./em_charge_source]
      type = ChargeSourceMoles_KV
      variable = potential
      charged = em
    [../]

  #The energy equations
    #Time Derivative term of electron energy
    [./mean_en_time_deriv]
      type = ElectronTimeDerivative
      variable = mean_en
    [../]
    #Advection term of electron energy
    [./mean_en_advection]
      type = EFieldAdvectionEnergy
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    #Diffusion term of electrons energy
    [./mean_en_diffusion]
      type = CoeffDiffusionEnergy
      variable = mean_en
      em = em
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
[]

[ChemicalReactions]
  [./ZapdosNetwork]
    species = 'em He+ He2+ N2+ He* He2*'
    aux_species = 'He N2'
    reaction_coefficient_format = 'rate'
    gas_species = 'Ar N2'
    electron_energy = 'mean_en'
    species_energy = 'mean_en'
    sampling_variable = 'electron_energy'
    electron_density = 'em'
    include_electrons = true
    file_location = 'Sakiyama_paper_RateCoefficients'
    potential = 'potential'
    use_log = true
    position_units = ${dom0Scale}

    equation_variables = 'e_temp mean_en_eV'
    equation_constants = 'NA'
    equation_values = '6.022e23'

    reactions = 'He + em -> He + em               : EEDF
                 He + em -> He* + em              : EEDF [-19.8]
                 He + em -> He+ + em + em         : EEDF [-24.6]
                 He* + em -> He+ + em + em        : EEDF [-4.8]
                 He* + He + He -> He2* + He       : 72.528968
                 He+ + He + He -> He2+ + He       : 39890.9324
                 He2* -> He + He                  : 1.0e4
                 He* + He* -> He2+ + em           : 9.033e8 [17.2]
                 He2* + He2* -> He2+ + He + He + em   : 9.033e8 [13.8]
                 He* + N2 -> N2+ + He + em        : 3.011e7 [4.2]
                 He2* + N2 -> N2+ + He + He + em  : 1.8066e7 [2.5]
                 He2+ + N2 -> N2+ + He2*          : 8.4308e8'

  [../]
[]

[Kernels]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_needle]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'needle'
    function = potential_bc_func
  [../]
  [./potential_plate]
    type = DielectricBC
    variable = potential
    boundary = 'plate'
    surface_charge = surface_charge
    dielectric_constant = 4.4271e-11
    thickness = 0.005
    position_units = ${dom0Scale}
  [../]

#Electron Boundary Condition
  [./em_thermalBC]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_He+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He+
    r = 0
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_He2+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He2+
    r = 0
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_He*_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He*
    r = 0
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_He2*_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He2*
    r = 0
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_N2+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = N2+
    r = 0
    users_gamma = 0.005
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He+ Boundary Condition
  [./He+_advectionBC]
    type = HagelaarIonAdvectionBC
    variable = He+
    potential = potential
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./He+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He+
    r = 0
    variable_temp = true
    neutral_gas = He
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He2+ Boundary Condition
  [./He2+_advectionBC]
    type = HagelaarIonAdvectionBC
    variable = He2+
    potential = potential
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./He2+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He2+
    r = 0
    variable_temp = true
    neutral_gas = He
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#N2+ Boundary Condition
  [./N2+_advectionBC]
    type = HagelaarIonAdvectionBC
    variable = N2+
    potential = potential
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./N2+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = N2+
    r = 0
    variable_temp = true
    neutral_gas = He
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He* Boundary Condition
  [./He*_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He*
    neutral_gas = He
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He2* Boundary Condition
  [./He2*_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He2*
    neutral_gas = He
    r = 0
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#Mean electron energy Boundary Condition
  [./mean_en_BC]
    type = ElectronTemperatureDirichletBC
    variable = mean_en
    em = em
    value = 0.6666667
    boundary = 'needle plate'
  [../]
[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = density_ic_func
  [../]
  [./He+_ic]
    type = FunctionIC
    variable = He+
    function = density_ic_func
  [../]
  [./He2+_ic]
    type = FunctionIC
    variable = He2+
    function = density_ic_func
  [../]
  [./He*_ic]
    type = FunctionIC
    variable = He*
    function = density_ic_func
  [../]
  [./He2*_ic]
    type = FunctionIC
    variable = He2*
    function = density_ic_func
  [../]
  [./N2+_ic]
    type = FunctionIC
    variable = N2+
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
    value = '0.188*cos(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '0.188 * (1.5e-3 - x)'
  [../]
  [./density_ic_func]
    type = ParsedFunction
    #value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    value = 'log((1e14)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e14)/6.022e23)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = true
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 101325
    user_T_gas = 300
    em = em
    potential = potential
    mean_en = mean_en
    property_tables_file = Sakiyama_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
    type = HeavySpeciesMaterial
    heavy_species_name = He*
    heavy_species_mass = 6.7e-27
    heavy_species_charge = 0
    mobility = 0
    diffusivity = 1.64e-4
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = He+
    heavy_species_mass = 6.7e-27
    heavy_species_charge = 1
    mobility = 1.16e-3
    diffusivity = 2.9989e-5
  [../]
  [./gas_species_2]
    type = HeavySpeciesMaterial
    heavy_species_name = He2*
    heavy_species_mass = 1.34e-26
    heavy_species_charge = 0.0
    mobility = 0
    diffusivity = 4.75e-5
  [../]
  [./gas_species_3]
    type = HeavySpeciesMaterial
    heavy_species_name = He2+
    heavy_species_mass = 1.34e-26
    heavy_species_charge = 1.0
    mobility = 1.83e-3
    diffusivity = 4.7310e-5
  [../]
  [./gas_species_4]
    type = HeavySpeciesMaterial
    heavy_species_name = N2+
    heavy_species_mass = 4.65e-26
    heavy_species_charge = 1.0
    mobility = 2.28e-3
    diffusivity = 5.8944e-5
  [../]
  [./gas_species_5]
    type = HeavySpeciesMaterial
    heavy_species_name = He
    heavy_species_mass = 6.7e-27
    heavy_species_charge = 0.0
  [../]
  [./gas_species_6]
    type = HeavySpeciesMaterial
    heavy_species_name = N2
    heavy_species_mass = 4.65e-26
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
  dtmax = 3.6e-9
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-5
  dtmin = 1e-14
  l_max_its = 20

  #Time steps based on the inverse of the plasma frequency
  #[./TimeStepper]
  #  type = PostprocessorDT
  #  postprocessor = InversePlasmaFreq
  #  scale = 1
  #[../]
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
  [./out]
    type = Exodus
  [../]
[]
