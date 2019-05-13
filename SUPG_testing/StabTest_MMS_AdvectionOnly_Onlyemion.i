dom0Scale=1

[GlobalParams]
  potential_units = V
  use_moles = true
  time_units = 1
  alpha = 1
[]

[Mesh]
  type = FileMesh
  file = 'MMS.msh'
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
[]

[Kernels]
  #Electron Equations
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
      mean_en = 0
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
      mean_en = 0
      position_units = ${dom0Scale}
    [../]
    [./em_source]
      type = BodyForce
      variable = em
      function = 'em_source_func'
    [../]

  #Electron Equations
    #Time Derivative term of electron
    [./Ar+_time_deriv]
      type = ElectronTimeDerivative
      variable = Ar+
    [../]
    #Advection term of electron
    [./Ar+_advection]
      type = EFieldAdvectionElectrons
      variable = Ar+
      potential = potential
      mean_en = 0
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
    [./Ar+_source]
      type = BodyForce
      variable = Ar+
      function = Ar+_source_func
    [../]

  []


[AuxVariables]

  [./potential]
  [../]

  [./x]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./x_node]
  [../]

  [./em_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Ar+_lin]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./potential]
    type = FunctionAux
    variable = potential
    function = potential_sol_func
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
[]


[BCs]
#New Boundary conditions for electons
  [./em_physical_left]
    type = FunctionDirichletBC
    variable = em
    boundary = 'left'
    function = em_left_bc_func
  [../]
  [./em_physical_right]
    type = FunctionDirichletBC
    variable = em
    boundary = 'right'
    function = em_right_bc_func
  [../]

#New Boundary conditions for ion
  [./Ar+_physical_left]
    type = FunctionDirichletBC
    variable = Ar+
    boundary = 'left'
    function = Ar+_left_bc_func
  [../]
  [./Ar+_physical_right]
    type = FunctionDirichletBC
    variable = Ar+
    boundary = 'right'
    function = Ar+_right_bc_func
  [../]

[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = em_ic_func
  [../]

  [./Ar+_ic]
    type = FunctionIC
    variable = Ar+
    function = Ar+_ic_func
  [../]
[]

[Functions]
  [./em_left_bc_func]
    type = ParsedFunction
    value = 'log(3)'
  [../]
  [./em_right_bc_func]
    type = ParsedFunction
    value = 'log(3)'
  [../]
  [./em_ic_func]
    type = ParsedFunction
    value = 'log(3)'
  [../]
  [./Ar+_left_bc_func]
    type = ParsedFunction
    value = 'log(-2*cos(t) + 3)'
  [../]
  [./Ar+_right_bc_func]
    type = ParsedFunction
    value = 'log(-2*cos(t) + 3)'
  [../]
  [./Ar+_ic_func]
    type = ParsedFunction
    value = 'log(1)'
  [../]
  [./em_source_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = '2*x*cos(t)*(10*x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 3)
    + x^2*cos(t)*(10*x*(exp(-t) - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 10*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1)
    + (sin(t) - 1)*(x - 1)) + 20*x*sin(t)*(exp(-t) - 1)*(x - 1)) + 10*x*(cos(t)*(x - 1) + x*cos(t))*(exp(-t) - 1)*(x - 1)
    - 10*x*exp(-t)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1))'
  [../]
  [./Ar+_source_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = '2*sin(t) + 2*x*cos(t)*(10*x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) - 2*cos(t) + 3)
    + x^2*cos(t)*(10*x*(exp(-t) - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 10*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1)
    + (sin(t) - 1)*(x - 1)) + 20*x*sin(t)*(exp(-t) - 1)*(x - 1)) + 10*x*(cos(t)*(x - 1) + x*cos(t))*(exp(-t) - 1)*(x - 1)
    - 10*x*exp(-t)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1))'
  [../]
  [./potential_sol_func]
    type = ParsedFunction
    value = 'x*x*cos(t)'
  [../]
[]

[Materials]
  [./muem_prop]
    type = GenericConstantMaterial
    prop_names = 'muem'
    prop_values = '1'
  [../]
  [./diffem_prop]
    type = GenericConstantMaterial
    prop_names = 'diffem'
    prop_values = 1
  [../]
  [./muAr+_prop]
    type = GenericConstantMaterial
    prop_names = 'muAr+'
    prop_values = '1'
  [../]
  [./diffAr+_prop]
    type = GenericConstantMaterial
    prop_names = 'diffAr+'
    prop_values = 1
  [../]
  [./constents_prop]
    type = GenericConstantMaterial
    prop_names = 'e N_A diffpotential sgnAr+ sgnem d_muem_d_actual_mean_en d_diffem_d_actual_mean_en'
    #prop_values = '1.6e-19 6.022e23 8.85e-12 1 -1 0 0'
    prop_values = '1.0 1.0 1.0 1 -1 0 0'
  [../]
  [./tauem]
    type = ADMaterialsPlasmaSUPG
    species_name = em
    position_units = ${dom0Scale}
    potential = potential
    transient_term = true
  [../]
  [./tauAr+]
    type = ADMaterialsPlasmaSUPG
    species_name = Ar+
    position_units = ${dom0Scale}
    potential = potential
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
  end_time = 10
  dtmax = 0.01
  petsc_options = '-snes_converged_reason -snes_linesearch_monitor'
  # dt = 1e-9
  # solve_type = JFNK
  # solve_type = PJFNK
  solve_type = NEWTON
  #petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  #petsc_options_value = 'lu NONZERO 1.e-10 fgmres 1e-3'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -ksp_type -snes_linesearch_minlambda'
  petsc_options_value = 'lu NONZERO 1.e-10 preonly 1e-3'
  # petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_shift_amount -snes_linesearch_minlambda'
  # petsc_options_value = 'lu NONZERO 1.e-10 1e-3'
  nl_rel_tol = 1e-4
  nl_abs_tol = 7.6e-6
  dtmin = 1e-30
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
  [./out]
    type = Exodus
  [../]
[]
