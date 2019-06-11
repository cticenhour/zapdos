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

[Variables]
  [./em]
  [../]

  [./He+]
  [../]

  [./He*]
  [../]

  [./He2+]
  [../]

  [./He2*]
  [../]

  [./N2+]
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
    #Net electron production from He+ ionization
    [./em_R2Gain]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = He
      energy = mean_en
      reaction = 'He + em -> He+ + em + em'
      coefficient = 1
    [../]
    #Net electron production from step-wise ionization
    [./em_R3Gain]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = He*
      energy = mean_en
      reaction = 'He* + em -> He+ + em + em'
      coefficient = 1
    [../]
    #Net electron production from metastable pooling
    [./em_R7Gain]
      type = ProductSecondOrderLog
      variable = em
      v = He*
      w = He*
      reaction = 'He* + He* -> He2+ + em'
      coefficient = 1
    [../]
    [./em_R8Gain]
      type = ProductSecondOrderLog
      variable = em
      v = He2*
      w = He2*
      reaction = 'He2* + He2* -> He2+ + He + He + em'
      coefficient = 1
    [../]
    #Net electron loss from Ion to Metastable production
    [./em_R9Loss]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = He2+
      energy = mean_en
      reaction = 'He2+ + em -> He* + He'
      coefficient = -1
    [../]
    #Net electron production from N2+ ionization
    [./em_R10Gain]
      type = ProductSecondOrderLog
      variable = em
      v = He*
      w = N2
      reaction = 'He* + N2 -> N2+ + He + em'
      coefficient = 1
    [../]
    [./em_R11Gain]
      type = ProductSecondOrderLog
      variable = em
      v = He2*
      w = N2
      reaction = 'He2* + N2 -> N2+ + He + He + em'
      coefficient = 1
    [../]
    #Net electron loss from Ion to Neutral production
    [./em_R13Loss]
      type = ElectronReactantSecondOrderLog
      variable = em
      v = N2+
      energy = mean_en
      reaction = 'N2+ + em -> N2'
      coefficient = -1
    [../]

  #Helium Ion Equations (Same as in paper)
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
    #Diffusion term of Helium ion (might need to change to included changing Diff)
    [./He+_diffusion]
      #type = CoeffDiffusion
      #variable = He+
      #position_units = ${dom0Scale}
      type = CoeffDiffusionTempDependent
      variable = He+
      potential = potential
      neutral_gas = He
      position_units = ${dom0Scale}
    [../]
    #Net ion production from ionization
    [./He+_R2Gain]
      type = ElectronProductSecondOrderLog
      variable = He+
      electron = em
      target = He
      energy = mean_en
      reaction = 'He + em -> He+ + em + em'
      coefficient = 1
    [../]
    #Net ion production from step-wise ionization
    [./He+_R3Gain]
      type = ElectronProductSecondOrderLog
      variable = He+
      electron = em
      target = He*
      energy = mean_en
      reaction = 'He* + em -> He+ + em + em'
      coefficient = 1
    [../]
    #Net ion loss from He2+ production
    [./He+_R5Loss]
      type = ReactantThirdOrderLog
      variable = He+
      v = He
      w = He
      reaction = 'He+ + He + He -> He2+ + He'
      coefficient = -1
    [../]

  #Helium Excited Equations (Same as in paper)
    #Time Derivative term of excited Helium
    [./He*_time_deriv]
      type = ElectronTimeDerivative
      variable = He*
    [../]
    #Diffusion term of excited Helium
    [./He*_diffusion]
      type = CoeffDiffusion
      variable = He*
      position_units = ${dom0Scale}
    [../]
    #Net excited Helium production from excitation
    [./He*_R1Gain]
      type = ElectronProductSecondOrderLog
      variable = He*
      electron = em
      target = He
      energy = mean_en
      reaction = 'He + em -> He* + em'
      coefficient = 1
    [../]
    #Net excited Helium loss from step-wise ionization
    [./He*_R3Loss]
      type = ElectronProductSecondOrderLog
      variable = He*
      electron = em
      target = He*
      energy = mean_en
      reaction = 'He* + em -> He+ + em + em'
      coefficient = -1
      _target_eq_u = true
    [../]
    #Net excited He loss from He2* production
    [./He*_R4Loss]
      type = ReactantThirdOrderLog
      variable = He*
      v = He
      w = He
      reaction = 'He* + He + He -> He2* + He'
      coefficient = -1
    [../]
    #Net excited Helium loss from  metastable pooling
    [./He*_R7Loss]
      type = ReactantSecondOrderLog
      variable = He*
      v = He*
      reaction = 'He* + He* -> He2+ + em'
      coefficient = -2
      _v_eq_u = true
    [../]
    #Net excited Helium production from Ion to Metastable
    [./He*_R9Gain]
      type = ElectronProductSecondOrderLog
      variable = He*
      electron = em
      target = He2+
      energy = mean_en
      reaction = 'He2+ + em -> He* + He'
      coefficient = 1
    [../]
    #Net excited Helium loss from N2+ ionization
    [./He*_R10Loss]
      type = ReactantSecondOrderLog
      variable = He*
      v = N2
      reaction = 'He* + N2 -> N2+ + He + em'
      coefficient = -1
    [../]

  #Helium 2 Ion Equations (Same as in paper)
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
    #Diffusion term of Helium ion (might need to change to included changing Diff)
    [./He2+_diffusion]
      #type = CoeffDiffusion
      #variable = He2+
      #position_units = ${dom0Scale}
      type = CoeffDiffusionTempDependent
      variable = He2+
      potential = potential
      neutral_gas = He
      position_units = ${dom0Scale}
    [../]
    #Net ion production from He+
    [./He2+_R5Gain]
      type = ProductThirdOrderLog
      variable = He2+
      v = He+
      w = He
      x = He
      reaction = 'He+ + He + He -> He2+ + He'
      coefficient = 1
    [../]
    #Net ion production from metastable pooling
    [./He2+_R7Gain]
      type = ProductSecondOrderLog
      variable = He2+
      v = He*
      w = He*
      reaction = 'He* + He* -> He2+ + em'
      coefficient = 1
    [../]
    [./He2+_R8Gain]
      type = ProductSecondOrderLog
      variable = He2+
      v = He2*
      w = He2*
      reaction = 'He2* + He2* -> He2+ + He + He + em'
      coefficient = 1
    [../]
    #Net ion loss from ion to metastable production
    [./He2+_R9Loss]
      type = ElectronProductSecondOrderLog
      variable = He2+
      electron = em
      target = He2+
      energy = mean_en
      reaction = 'He2+ + em -> He* + He'
      coefficient = -1
      _target_eq_u = true
    [../]
    #Net ion loss from N2+ production
    [./He2+_R12Loss]
      type = ReactantSecondOrderLog
      variable = He2+
      v = N2
      reaction = 'He2+ + N2 -> N2+ + He2*'
      coefficient = -1
    [../]

  #Helium 2 Excited Equations (Same as in paper)
    #Time Derivative term of excited Helium
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
    #Net excited Helium 2 production from excited Helium
    [./He2*_R4Gain]
      type = ProductThirdOrderLog
      variable = He2*
      v = He*
      w = He
      x = He
      reaction = 'He* + He + He -> He2* + He'
      coefficient = 1
    [../]
    #Net excited Helium 2 loss from neutral gas production
    [./He2*_R6Loss]
      type = ReactantFirstOrderLog
      variable = He2*
      reaction = 'He2* -> He + He'
      coefficient = -1
    [../]
    #Net excited Helium 2 loss from  metastable pooling
    [./He2*_R8Loss]
      type = ReactantSecondOrderLog
      variable = He2*
      v = He2*
      reaction = 'He2* + He2* -> He2+ + He + He + em'
      coefficient = -2
      _v_eq_u = true
    [../]
    #Net excited Helium 2 loss from N2+ ionization
    [./He2*_R11Loss]
      type = ReactantSecondOrderLog
      variable = He2*
      v = N2
      reaction = 'He2* + N2 -> N2+ + He + He + em'
      coefficient = -1
    [../]
    #Net excited Helium 2 Gain from N2+ ionization
    [./He2*_R12Gain]
      type = ProductSecondOrderLog
      variable = He2*
      v = He2+
      w = N2
      reaction = 'He2+ + N2 -> N2+ + He2*'
      coefficient = 1
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
    #Diffusion term of N2+ ion (might need to change to included changing Diff)
    [./N2+_diffusion]
      #type = CoeffDiffusion
      #variable = N2+
      #position_units = ${dom0Scale}
      type = CoeffDiffusionTempDependent
      variable = N2+
      potential = potential
      neutral_gas = He
      position_units = ${dom0Scale}
    [../]
    #Net ion production
    [./N2+_R10Gain]
      type = ProductSecondOrderLog
      variable = N2+
      v = He*
      w = N2
      reaction = 'He* + N2 -> N2+ + He + em'
      coefficient = 1
    [../]
    [./N2+_R11Gain]
      type = ProductSecondOrderLog
      variable = N2+
      v = He2*
      w = N2
      reaction = 'He2* + N2 -> N2+ + He + He + em'
      coefficient = 1
    [../]
    [./N2+_R12Gain]
      type = ProductSecondOrderLog
      variable = N2+
      v = He2+
      w = N2
      reaction = 'He2+ + N2 -> N2+ + He2*'
      coefficient = 1
    [../]
    #Net ion loss
    [./N2+_R13Loss]
      type = ElectronProductSecondOrderLog
      variable = N2+
      electron = em
      target = N2+
      energy = mean_en
      reaction = 'N2+ + em -> N2'
      coefficient = -1
      _target_eq_u = true
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
    [./Energy_R0]
      type = ElectronEnergyTermElasticRate
      variable = mean_en
      electron_species = em
      target_species = He
      reaction = 'He + em -> He + em'
      position_units = ${dom0Scale}
      potential = potential
    [../]
    #Energy loss from excitation
    [./Energy_R1]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = He
      reaction = 'He + em -> He* + em'
      threshold_energy = -19.8
      position_units = ${dom0Scale}
    [../]
    #Energy loss from ionization
    [./Energy_R2]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = He
      reaction = 'He + em -> He+ + em + em'
      threshold_energy = -24.6
      position_units = ${dom0Scale}
    [../]
    #Energy loss from step-wise ionization
    [./Energy_R3]
      type = ElectronEnergyTermRate
      variable = mean_en
      em = em
      v = He*
      reaction = 'He* + em -> He+ + em + em'
      threshold_energy = -4.8
      position_units = ${dom0Scale}
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
      type = ElectronEnergyTermRateDependentThreshold
      variable = mean_en
      v = He2+
      em = em
      reaction = 'He2+ + em -> He* + He'
      position_units = ${dom0Scale}
    [../]
    [./EnergyLossDueToR10]
      type = ElectronEnergyTermRateNonElectronInclusion
      variable = mean_en
      v = He*
      w = N2
      em = em
      reaction = 'He* + N2 -> N2+ + He + em'
      threshold_energy = 4.2
      position_units = ${dom0Scale}
    [../]
    [./EnergyLossDueToR11]
      type = ElectronEnergyTermRateNonElectronInclusion
      variable = mean_en
      v = He2*
      w = N2
      em = em
      reaction = 'He2* + N2 -> N2+ + He + He + em'
      threshold_energy = 2.5
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
  [./He+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./He2*_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./N2+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./SC]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCem]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCHeIon]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCHe2Ion]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./SCN2Ion]
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
  [./He+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He+_lin
    density_log = He+
  [../]
  [./He*_lin]
    type = DensityMoles
    convert_moles = true
    variable = He*_lin
    density_log = He*
  [../]
  [./He2+_lin]
    type = DensityMoles
    convert_moles = true
    variable = He2+_lin
    density_log = He2+
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

  [./SC_em]
    type = MaterialRealAux
    variable = SCem
    property = surface_chargeem
    boundary = 'plate'
  [../]
  [./SC_HeIon]
    type = MaterialRealAux
    variable = SCHeIon
    property = surface_chargeHe+
    boundary = 'plate'
  [../]
  [./SC_He2Ion]
    type = MaterialRealAux
    variable = SCHe2Ion
    property = surface_chargeHe2+
    boundary = 'plate'
  [../]
  [./SC_N2Ion]
    type = MaterialRealAux
    variable = SCN2Ion
    property = surface_chargeN2+
    boundary = 'plate'
  [../]
  [./Total_SC]
    type = ParsedAux
    variable = SC
    args = 'SCem SCHeIon SCHe2Ion SCN2Ion'
    function = 'SCem + SCHeIon + SCHe2Ion + SCN2Ion'
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
  #[./potential_plate]
  #  type = DirichletBC
  #  variable = potential
  #  boundary = 'plate'
  #  value = 0
  #[../]
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
    variable_temp = true
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
    variable_temp = true
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
    variable_temp = true
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
    #variable_temp = false
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
    #variable_temp = false
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
    #variable_temp = false
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
    #value = 0.6666667
    value = 1
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
    #type = ConstantIC
    #variable = He2+
    #value = -40
    type = FunctionIC
    variable = He2+
    function = density_ic_func
  [../]
  [./He*_ic]
    #type = ConstantIC
    #variable = He*
    #value = -40
    type = FunctionIC
    variable = He*
    function = density_ic_func
  [../]
  [./He2*_ic]
    #type = ConstantIC
    #variable = He2*
    #value = -40
    type = FunctionIC
    variable = He2*
    function = density_ic_func
  [../]
  [./N2+_ic]
    #type = ConstantIC
    #variable = N2+
    #value = -40
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
    value = '0.180*cos(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    #value = '0.180 * (1.5e-3 - x)'
    value = 0.180
  [../]
  [./density_ic_func]
    type = ParsedFunction
    #value = 'log((1e13 + 1e15 * (1-x/1)^2 * (x/1)^2)/6.022e23)'
    value = 'log((7e12)/6.022e23)'
  [../]
  [./energy_density_ic_func]
    type = ParsedFunction
    value = 'log(3./2.) + log((7e12)/6.022e23)'
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
  [./reaction_R0]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He + em -> He + em.txt'
    reaction = 'He + em -> He + em'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_R1]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He + em -> He* + em.txt'
    reaction = 'He + em -> He* + em'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_R2]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He + em -> He+ + em + em.txt'
    reaction = 'He + em -> He+ + em + em'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_R3]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He* + em -> He+ + em + em.txt'
    reaction = 'He* + em -> He+ + em + em'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_R4]
    type = GenericRateConstant
    reaction = 'He* + He + He -> He2* + He'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 72.528968
  [../]
  [./reaction_R5]
    type = GenericRateConstant
    reaction = 'He+ + He + He -> He2+ + He'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 39890.9324
  [../]
  [./reaction_R6]
    type = GenericRateConstant
    reaction = 'He2* -> He + He'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1e4
  [../]
  [./reaction_R7]
    type = GenericRateConstant
    reaction = 'He* + He* -> He2+ + em'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 9.033e8
  [../]
  [./reaction_R8]
    type = GenericRateConstant
    reaction = 'He2* + He2* -> He2+ + He + He + em'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 9.033e8
  [../]
  [./reaction_R9]
    type = ZapdosEEDFRateConstant
    mean_en = mean_en
    sampling_format = electron_energy
    property_file = 'Sakiyama_paper_RateCoefficients/reaction_He2+ + em -> He* + He.txt'
    reaction = 'He2+ + em -> He* + He'
    position_units = ${dom0Scale}
    file_location = ''
    em = em
  [../]
  [./reaction_R10]
    type = GenericRateConstant
    reaction = 'He* + N2 -> N2+ + He + em'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 3.011e7
  [../]
  [./reaction_R11]
    type = GenericRateConstant
    reaction = 'He2* + N2 -> N2+ + He + He + em'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 1.8066e7
  [../]
  [./reaction_R12]
    type = GenericRateConstant
    reaction = 'He2+ + N2 -> N2+ + He2*'
    #reaction_rate_value = 2e-13
    reaction_rate_value = 2.89056e9
  [../]
  [./reaction_R13]
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
    neutral_gas = He
  [../]
  [./surface_charge_He+]
    type = SurfaceChargeForSeperateSpecies
    species = He+
    species_em = false
    ip = He+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./surface_charge_He2+]
    type = SurfaceChargeForSeperateSpecies
    species = He2+
    species_em = false
    ip = He2+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = He
  [../]
  [./surface_charge_N2+]
    type = SurfaceChargeForSeperateSpecies
    species = N2+
    species_em = false
    ip = N2+
    potential = potential
    boundary = 'plate'
    position_units = ${dom0Scale}
    neutral_gas = He
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
  active = 'fdp'
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
  #dtmax = 1e-11
  dtmax = 3.6e-9
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  solve_type = NEWTON
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
