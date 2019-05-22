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
    coord_type = RZ
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
[]

[DriftDiffusionAction]
  Ions = 'He+ He2+ N2+'
  Neutrals = 'He* He2*'
  CRANE_Coupled = true
  block = 'plasma'
  position_units = ${dom0Scale}
  potential_units = kV
  use_moles = true
  Additional_Outputs = 'EField ElectronTemperature'
  component = 0
[../]

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
                 He* + He* -> He2+ + em           : 9.033e8
                 He2* + He2* -> He2+ + He + He + em   : 9.033e8
                 He* + N2 -> N2+ + He + em        : 3.011e7
                 He2* + N2 -> N2+ + He + He + em  : 1.8066e7
                 He2+ + N2 -> N2+ + He2*          : 8.4308e8'
                 #He2+ + em -> He* + He            : EEDF
                 #N2+ + em -> N2                   : EEDF
  [../]
[]


[Kernels]
  [./ElectronLossR11]
    type = ElectronReactantSecondOrderLog
    variable = em
    v = He2+
    energy = mean_en
    reaction = 'He2+ + em -> He* + He'
    coefficient = -1
  [../]
  [./He2+LossR11]
    type = ElectronProductSecondOrderLog
    variable = He2+
    electron = em
    target = He2+
    energy = mean_en
    reaction = 'He2+ + em -> He* + He'
    coefficient = -1
    _target_eq_u = true
  [../]
  [./He*GainR11]
    type = ElectronProductSecondOrderLog
    variable = He*
    electron = em
    target = He2+
    energy = mean_en
    reaction = 'He2+ + em -> He* + He'
    coefficient = 1
  [../]
  [./ElectronLossR13]
    type = ElectronReactantSecondOrderLog
    variable = em
    v = N2+
    energy = mean_en
    reaction = 'N2+ + em -> N2'
    coefficient = -1
  [../]
  [./N2+LossR13]
    type = ElectronProductSecondOrderLog
    variable = N2+
    electron = em
    target = N2+
    energy = mean_en
    reaction = 'He2+ + em -> He* + He'
    coefficient = -1
    _target_eq_u = true
  [../]
#New Energy Loss Kernels not included in the Actions
  [./EnergyLossDueToR7]
    type = ElectronEnergyTermRateNonElectronInclusion
    variable = mean_en
    v = He*
    w = He*
    em = em
    reaction = 'He* + He* -> He2+ + em'
    threshold_energy = 17.2
    position_units = ${dom0Scale}
  [../]
  [./EnergyLossDueToR8]
    type = ElectronEnergyTermRateNonElectronInclusion
    variable = mean_en
    v = He2*
    w = He2*
    em = em
    reaction = 'He2* + He2* -> He2+ + He + He + em'
    threshold_energy = 13.8
    position_units = ${dom0Scale}
  [../]
  [./EnergyLossDueToR9]
    type = ElectronEnergyTermRateNonElectronInclusion
    variable = mean_en
    v = He*
    w = N2
    em = em
    reaction = 'He* + N2 -> N2+ + He + em'
    threshold_energy = 4.2
    position_units = ${dom0Scale}
  [../]
  [./EnergyLossDueToR10]
    type = ElectronEnergyTermRateNonElectronInclusion
    variable = mean_en
    v = He2*
    w = N2
    em = em
    reaction = 'He2* + N2 -> N2+ + He + He + em'
    threshold_energy = 2.5
    position_units = ${dom0Scale}
  [../]
  [./EnergyLossDueToR11]
    type = ElectronEnergyTermRateDependentThreshold
    variable = mean_en
    v = He2+
    em = em
    reaction = 'He2+ + em -> He* + He'
    position_units = ${dom0Scale}
  [../]
  [./EnergyLossDueToR13]
    type = ElectronEnergyTermRateDependentThreshold
    variable = mean_en
    v = N2+
    em = em
    reaction = 'N2+ + em -> N2'
    position_units = ${dom0Scale}
  [../]
[]

[BCs]
#Voltage Boundary Condition
  [./potential_needle]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'needle'
    function = potential_bc_func
  [../]
  [./potential_plate_Dielectric]
    type = DielectricBC
    variable = potential
    boundary = 'plate'
    dielectric_constant = 4.4271e-11
    thickness = 0.005
    position_units = ${dom0Scale}
  [../]
  [./potential_plate_em_surface_charge]
    type = SurfaceChargeBC
    variable = potential
    boundary = 'plate'
    species = em
    position_units = ${dom0Scale}
  [../]
  [./potential_plate_He+_surface_charge]
    type = SurfaceChargeBC
    variable = potential
    boundary = 'plate'
    species = He+
    position_units = ${dom0Scale}
  [../]
  [./potential_plate_He2+_surface_charge]
    type = SurfaceChargeBC
    variable = potential
    boundary = 'plate'
    species = He2+
    position_units = ${dom0Scale}
  [../]
  [./potential_plate_N2+_surface_charge]
    type = SurfaceChargeBC
    variable = potential
    boundary = 'plate'
    species = N2+
    position_units = ${dom0Scale}
  [../]

#Electron Boundary Condition
  [./em_thermalBC]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./em_He+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He+
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./em_He2+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He2+
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./em_He*_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He*
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./em_He2*_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = He2*
    users_gamma = 0.25
    boundary = 'needle plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./em_N2+_second_emissions]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = N2+
    users_gamma = 0.005
    boundary = 'needle plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]

#He+ Boundary Condition
  [./He+_advectionBC]
    type = SakiyamaIonAdvectionBC
    variable = He+
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./He+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He+
    variable_temp = true
    neutral_gas = He
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He2+ Boundary Condition
  [./He2+_advectionBC]
    type = SakiyamaIonAdvectionBC
    variable = He2+
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./He2+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He2+
    variable_temp = true
    neutral_gas = He
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#N2+ Boundary Condition
  [./N2+_advectionBC]
    type = SakiyamaIonAdvectionBC
    variable = N2+
    potential = potential
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]
  [./N2+_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = N2+
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
    boundary = 'needle plate'
    position_units = ${dom0Scale}
  [../]

#He2* Boundary Condition
  [./He2*_diffusionBC]
    type = SakiyamaIonDiffusionBC
    variable = He2*
    neutral_gas = He
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
    value = '0.155*cos(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    value = '0.155 * (1.5e-3 - x)'
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
  [./reaction_He2+]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He2+ + em -> He* + He.txt'
    reaction = 'He2+ + em -> He* + He'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_N2+]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_N2+ + em -> N2.txt'
    reaction = 'N2+ + em -> N2'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./surface_charge_em]
    type = SurfaceChargeForSeperateSpecies
    species = em
    species_em = true
    em = em
    ip = He+
    mean_en = mean_en
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]
  [./surface_charge_He+]
    type = SurfaceChargeForSeperateSpecies
    species = He+
    species_em = false
    ip = He+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]
  [./surface_charge_He2+]
    type = SurfaceChargeForSeperateSpecies
    species = He2+
    species_em = false
    ip = He2+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]
  [./surface_charge_N2+]
    type = SurfaceChargeForSeperateSpecies
    species = N2+
    species_em = false
    ip = N2+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
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
  end_time = 7.4e-3
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
  [./TimeStepper]
    type = PostprocessorDT
    postprocessor = InversePlasmaFreq
    scale = 0.2
  [../]
  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  cutback_factor = 0.4
  #  dt = 1e-11
  #  growth_factor = 1.2
  #  optimal_iterations = 15
  #[../]
[]

[Outputs]
  print_perf_log = true
  [./out]
    type = Exodus
  [../]
[]
