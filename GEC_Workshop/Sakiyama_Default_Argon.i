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
  rz_coord_axis = Y
[]

#[Adaptivity]
#  max_h_level = 3
#  marker = marker
#  [./Indicators]
#    [./error]
#      type = GradientJumpIndicator
#      variable = Ar+
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

[Variables]
  [./em]
  [../]

  [./Ar+]
  [../]

  [./Ar*]
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
    #[./em_advection_SUPG]
    #  type = EFieldAdvectionSUPG
    #  variable = em
    #  potential = potential
    #  tau_name = tauem
    #  position_units = ${dom0Scale}
    #[../]
    #Diffusion term of electrons
    [./em_diffusion]
      type = CoeffDiffusionElectrons
      variable = em
      mean_en = mean_en
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
    #Net electron production from step-wise ionization
    [./em_stepwise_ionization]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = Ar*
      energy = mean_en
      reaction = 'em + Ar* -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net electron production from metastable pooling
    [./em_pooling]
      type = ProductSecondOrderLog
      variable = em
      v = Ar*
      w = Ar*
      reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
      coefficient = 1
    [../]

  #Argon Ion Equations (Same as in paper)
    #Time Derivative term of the ions
    [./Ar+_time_deriv]
      type = ElectronTimeDerivative
      variable = Ar+
    [../]
    #Advection term of ions
    [./Ar+_advection]
      type = EFieldAdvection
      variable = Ar+
      potential = potential
      position_units = ${dom0Scale}
    [../]
    #[./Ar+_advection_SUPG]
    #  type = EFieldAdvectionSUPG
    #  variable = Ar+
    #  potential = potential
    #  tau_name = tauAr+
    #  position_units = ${dom0Scale}
    #[../]
    [./Ar+_diffusion]
      type = CoeffDiffusion
      variable = Ar+
      position_units = ${dom0Scale}
      #type = CoeffDiffusionTempDependent
      #variable = Ar+
      #potential = potential
      #position_units = ${dom0Scale}
      #neutral_gas = Ar
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
    #Net ion production from step-wise ionization
    [./Ar+_stepwise_ionization]
      type = ElectronProductSecondOrderLog
      variable = Ar+
      electron = em
      target = Ar*
      energy = mean_en
      reaction = 'em + Ar* -> em + em + Ar+'
      coefficient = 1
    [../]
    #Net ion production from metastable pooling
    [./Ar+_pooling]
      type = ProductSecondOrderLog
      variable = Ar+
      v = Ar*
      w = Ar*
      reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
      coefficient = 1
    [../]

    #Argon Excited Equations (Same as in paper)
      #Time Derivative term of excited Argon
      [./Ar*_time_deriv]
        type = ElectronTimeDerivative
        variable = Ar*
      [../]
      #Diffusion term of excited Argon
      [./Ar*_diffusion]
        type = CoeffDiffusion
        variable = Ar*
        position_units = ${dom0Scale}
      [../]
      #Net excited Argon production from excitation
      [./Ar*_excitation]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar
        energy = mean_en
        reaction = 'em + Ar -> em + Ar*'
        coefficient = 1
      [../]
      #Net excited Argon loss from step-wise ionization
      [./Ar*_stepwise_ionization]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + em + Ar+'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from superelastic collisions
      [./Ar*_collisions]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + Ar'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from quenching to resonant
      [./Ar*_quenching]
        type = ElectronProductSecondOrderLog
        variable = Ar*
        electron = em
        target = Ar*
        energy = mean_en
        reaction = 'em + Ar* -> em + Ar_r'
        coefficient = -1
        _target_eq_u = true
      [../]
      #Net excited Argon loss from  metastable pooling
      [./Ar*_pooling]
        type = ReactantSecondOrderLog
        variable = Ar*
        v = Ar*
        reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
        coefficient = -2
        _v_eq_u = true
      [../]
      #Net excited Argon loss from two-body quenching
      [./Ar*_2B_quenching]
        type = ReactantSecondOrderLog
        variable = Ar*
        v = Ar
        reaction = 'Ar* + Ar -> Ar + Ar'
        coefficient = -1
      [../]
      #Net excited Argon loss from three-body quenching
      [./Ar*_3B_quenching]
        type = ReactantThirdOrderLog
        variable = Ar*
        v = Ar
        w = Ar
        reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
        coefficient = -1
      [../]

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
    #Advection term of electron energy
    [./mean_en_advection]
      type = EFieldAdvectionEnergy
      variable = mean_en
      potential = potential
      em = em
      position_units = ${dom0Scale}
    [../]
    #[./mean_en_advection_SUPG]
    #  type = EFieldAdvectionSUPG
    #  variable = mean_en
    #  potential = potential
    #  tau_name = taumean_en
    #  position_units = ${dom0Scale}
    #[../]
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
    #Energy loss from excitation
    [./Excitation_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar
      reaction = 'em + Ar -> em + Ar*'
      threshold_energy = -11.56
      position_units = ${dom0Scale}
    [../]
    #Energy loss from step-wise ionization
    [./Stepwise_Ionization_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar*
      reaction = 'em + Ar* -> em + em + Ar+'
      threshold_energy = -4.14
      position_units = ${dom0Scale}
    [../]
    #Energy gain from superelastic collisions
    [./Collisions_Loss]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = Ar*
      reaction = 'em + Ar* -> em + Ar'
      threshold_energy = 11.56
      position_units = ${dom0Scale}
    [../]
  []


[AuxVariables]
  [./Current_em]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]
  [./Current_Ar]
    order = CONSTANT
    family = MONOMIAL
    block = 'plasma'
  [../]

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

  [./y]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./y_node]
  [../]

  [./Efield_x]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Efield_y]
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

  [./SC]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCem]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCArIon]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./Ar_val]
    type = ConstantAux
    variable = Ar
    # value = 2.504e25
    value = 3.727640209
    execute_on = INITIAL
  [../]

  [./Current_em]
    type = Current
    potential = potential
    density_log = em
    variable = Current_em
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]
  [./Current_Ar]
    type = Current
    potential = potential
    density_log = Ar+
    variable = Current_Ar
    art_diff = false
    block = 'plasma'
    position_units = ${dom0Scale}
  [../]

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

  [./y_g]
    type = CustomPosition
    variable = y
    CustomPosition_units = ${dom0Scale}
    component = 1
  [../]
  [./y_ng]
    type = CustomPosition
    variable = y_node
    CustomPosition_units = ${dom0Scale}
    component = 1
  [../]

  [./Efield_calc_x]
    type = Efield
    component = 0
    potential = potential
    variable = Efield_x
    position_units = ${dom0Scale}
  [../]
  [./Efield_calc_y]
    type = Efield
    component = 1
    potential = potential
    variable = Efield_y
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

  [./SC_em]
    type = MaterialRealAux
    variable = SCem
    property = surface_chargeem
    boundary = 'plate'
  [../]
  [./SC_ArIon]
    type = MaterialRealAux
    variable = SCArIon
    property = surface_chargeAr+
    boundary = 'plate'
  [../]
  #[./SC_He2Ion]
  #  type = MaterialRealAux
  #  variable = SCHe2Ion
  #  property = surface_chargeHe2+
  #  boundary = 'plate'
  #[../]
  #[./SC_N2Ion]
  #  type = MaterialRealAux
  #  variable = SCN2Ion
  #  property = surface_chargeN2+
  #  boundary = 'plate'
  #[../]
  [./Total_SC]
    type = ParsedAux
    variable = SC
    args = 'SCem SCArIon'
    function = 'SCem + SCArIon'
    #execute_on = 'LINEAR TIMESTEP_END'
    #block = 'plasma'
    boundary = 'plate'
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
  [./potential_plate]
    type = DirichletBC
    variable = potential
    boundary = 'plate'
    value = 0
  [../]
  #[./potential_plate_Dielectric]
  #  type = DielectricBC
  #  variable = potential
  #  boundary = 'plate'
  #  dielectric_constant = 4.4271e-11
  #  thickness = 0.005
  #  position_units = ${dom0Scale}
  #[../]
  #[./potential_plate_em_surface_charge]
  #  type = SurfaceChargeBC
  #  variable = potential
  #  boundary = 'plate'
  #  species = em
  #  position_units = ${dom0Scale}
  #[../]
  #[./potential_plate_Ar+_surface_charge]
  #  type = SurfaceChargeBC
  #  variable = potential
  #  boundary = 'plate'
  #  species = Ar+
  #  position_units = ${dom0Scale}
  #[../]


#Electron Boundary Condition
  [./em_thermalBC_needle]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    boundary = 'needle'
    position_units = ${dom0Scale}
  [../]
  [./em_Ar+_second_emissions_needle]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = Ar+
    #users_gamma = 0.01
    users_gamma = 0.15
    boundary = 'needle'
    position_units = ${dom0Scale}
    neutral_gas = Ar
    #variable_temp = true
  [../]
  [./em_thermalBC_plate]
    type = SakiyamaElectronDiffusionBC
    variable = em
    mean_en = mean_en
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]
  [./em_Ar+_second_emissions_plate]
    type = SakiyamaSecondaryElectronBC
    variable = em
    mean_en = mean_en
    potential = potential
    ip = Ar+
    #users_gamma = 0.01
    users_gamma = 0.15
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = Ar
    #variable_temp = true
  [../]

#Ar+ Boundary Condition
  [./Ar+_advectionBC_needle]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    potential = potential
    boundary = 'needle'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_diffusionBC_needle]
    type = SakiyamaIonDiffusionBC
    variable = Ar+
    #variable_temp = true
    variable_temp = false
    neutral_gas = Ar
    potential = potential
    boundary = 'needle'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_advectionBC_plate]
    type = SakiyamaIonAdvectionBC
    variable = Ar+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]
  [./Ar+_diffusionBC_plate]
    type = SakiyamaIonDiffusionBC
    variable = Ar+
    #variable_temp = true
    variable_temp = false
    neutral_gas = Ar
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]

#He* Boundary Condition
  [./Ar*_diffusionBC_needle]
    type = SakiyamaIonDiffusionBC
    variable = Ar*
    neutral_gas = Ar
    boundary = 'needle'
    position_units = ${dom0Scale}
  [../]
  [./Ar*_diffusionBC_plate]
    type = SakiyamaIonDiffusionBC
    variable = Ar*
    neutral_gas = Ar
    boundary = 'plate'
    position_units = ${dom0Scale}
  [../]

#Mean electron energy Boundary Condition
  [./mean_en_BC_needle]
    type = ElectronEnergyDirichletBC
    variable = mean_en
    em = em
    value = 1
    boundary = 'needle'
  [../]
  [./mean_en_BC_plate]
    type = ElectronEnergyDirichletBC
    variable = mean_en
    em = em
    value = 1
    boundary = 'plate'
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
    #type = ConstantIC
    #variable = He*
    #value = -30
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
    value = '0.200*sin(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    #value = '0.180 * (1.5e-3 - x)'
    value = 0
  [../]
  [./density_ic_func]
    type = ParsedFunction
    #value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    value = 'log((1e13)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((1e13)/6.022e23)'
  [../]
[]

[Materials]
  [./GasBasics]
    type = GasElectronMoments
    interp_trans_coeffs = false
    interp_elastic_coeff = false
    ramp_trans_coeffs = false
    user_p_gas = 101325
    user_T_gas = 300
    user_electron_mobility = 0.038578275
    user_electron_diffusion_coeff = 0.154153355
    em = em
    potential = potential
    mean_en = mean_en
    property_tables_file = Sakiyama_paper_RateCoefficients/electron_moments.txt
    position_units = ${dom0Scale}
  [../]
  [./gas_species_0]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar+
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 1.0
    mobility = 1.85702875e-4
    diffusivity = 8.266773163e-6
  [../]
  [./gas_species_1]
    type = HeavySpeciesMaterial
    heavy_species_name = Ar*
    heavy_species_mass = 6.64e-26
    heavy_species_charge = 0.0
    diffusivity = 9.664536741e-6
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
  [./reaction_2]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + Ar.txt'
    reaction = 'em + Ar* -> em + Ar'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_3]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Argon_reactions_paper_RateCoefficients/reaction_em + Ar* -> em + em + Ar+.txt'
    reaction = 'em + Ar* -> em + em + Ar+'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_4]
    type = GenericRateConstant
    reaction = 'em + Ar* -> em + Ar_r'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1.2044e11
  [../]
  [./reaction_5]
    type = GenericRateConstant
    reaction = 'Ar* + Ar* -> Ar+ + Ar + em'
    #reaction_rate_value = 6.2e-16
    reaction_rate_value = 373364000
  [../]
  [./reaction_6]
    type = GenericRateConstant
    reaction = 'Ar* + Ar -> Ar + Ar'
    #reaction_rate_value = 3e-21
    reaction_rate_value = 1806.6
  [../]
  [./reaction_7]
    type = GenericRateConstant
    reaction = 'Ar* + Ar + Ar -> Ar_2 + Ar'
    #reaction_rate_value = 1.1e-42
    reaction_rate_value = 398909.324
  [../]
  [./surface_charge_em]
    type = SurfaceChargeForSeperateSpecies
    species = em
    species_em = true
    em = em
    ip = Ar+
    mean_en = mean_en
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = Ar
  [../]
  [./surface_charge_Ar+]
    type = SurfaceChargeForSeperateSpecies
    species = Ar+
    species_em = false
    ip = Ar+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = Ar
  [../]
  #[./tauem]
  # type = ADMaterialsPlasmaSUPG
  #  species_name = em
  #  position_units = ${dom0Scale}
  #  potential = potential
  #  transient_term = true
  #[../]
  #[./tauAr+]
  #  type = ADMaterialsPlasmaSUPG
  #  species_name = Ar+
  #  position_units = ${dom0Scale}
  #  potential = potential
  #  transient_term = true
  #[../]
  #[./taumean_en]
  #  type = ADMaterialsPlasmaSUPG
  #  species_name = mean_en
  #  position_units = ${dom0Scale}
  #  potential = potential
  #  transient_term = true
  #[../]
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
  dtmax = 1e-10
  #dtmax = 1e-10
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
  #solve_type = PJFNK
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
  #  scale = 0.2
  #[../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.4
    dt = 1e-11
    #growth_factor = 1.2
    growth_factor = 1.02
    optimal_iterations = 15
  [../]
[]

[Outputs]
  print_perf_log = true
  file_base = 'Default_Sakiyama_Argon_SEC'
  [./out]
    type = Exodus
  [../]
[]
