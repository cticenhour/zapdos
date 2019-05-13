dom0Scale=1

[GlobalParams]
  potential_units = V
  use_moles = true
  time_units = 1
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

  [./potential]
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
    [./source]
      type = BodyForce
      variable = em
      function = 'source_func'
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

  []


[AuxVariables]
  [./Ar+]
  [../]

  [./em_sol]
  [../]


    [./potent_sol]
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
[]

[AuxKernels]
  [./Ar+]
    type = FunctionAux
    variable = Ar+
    function = Ar+_func
  [../]
  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_sol_func
  [../]
  [./potent_sol]
    type = FunctionAux
    variable = potent_sol
    function = potent_sol_func
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
[]


[BCs]
#Voltage Boundary Condition
[./potential_dirichlet_left]
  type = FunctionDirichletBC
  variable = potential
  boundary = 'left'
  function = potential_left_bc_func
[../]
  [./potential_dirichlet_right]
    type = FunctionDirichletBC
    variable = potential
    boundary = 'right'
    function = potential_right_bc_func
  [../]

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

[]


[ICs]
  [./em_ic]
    type = FunctionIC
    variable = em
    function = em_ic_func
  [../]

  [./potential_ic]
    type = FunctionIC
    variable = potential
    function = potential_ic_func
  [../]
[]

[Functions]
  [./potential_left_bc_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * cos(t)'
    value = '0'
  [../]
  [./potential_right_bc_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * cos(t)'
    value = 'cos(t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = 'x * x'
  [../]
  [./em_left_bc_func]
    type = ParsedFunction
    value = 'log((10^14)/6.022e23)'
  [../]
  [./em_right_bc_func]
    type = ParsedFunction
    value = 'log((10^14)/6.022e23)'
  [../]
  [./em_ic_func]
    type = ParsedFunction
    value = 'log((10^14)/6.022e23)'
  [../]
  [./Ar+_func]
    type = ParsedFunction
    value = 'log((-2*cos(t) + 1e14 + 1e20*x*(1-x)*t)/6.022e23)'
  [../]
  [./source_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = 'log((-100000000000000000000*x*(x - 1) - x^2*cos(t)*(100000000000000000000*t*x + 100000000000000000000*t*(x - 1)) - 2*x*cos(t)*(100000000000000000000*t*x*(x - 1) - 100000000000000))/6.022e23)'
  [../]
  [./em_sol_func]
    type = ParsedFunction
    value = 'log((1e14 + 1e20*x*(1-x)*t)/6.022e23)'
  [../]
  [./potent_sol_func]
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
    prop_values = 0
  [../]
  [./constents_prop]
    type = GenericConstantMaterial
    prop_names = 'e N_A diffpotential sgnAr+ sgnem d_muem_d_actual_mean_en d_diffem_d_actual_mean_en'
    #prop_values = '1.6e-19 6.022e23 8.85e-12 1 -1 0 0'
    prop_values = '1.0 6.022e23 1.0 1 -1 0 0'
  [../]
  [./tauem]
    type = ADMaterialsPlasmaSUPG
    species_name = em
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
  nl_abs_tol = 7.6e-5
  dtmin = 1e-16
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
