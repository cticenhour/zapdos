dom0Scale=1

[GlobalParams]
  #offset = 1
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
  #Electron Equations (Same as in paper)
    #Time Derivative term of electron
    [./em_time_deriv]
      type = ElectronTimeDerivative
      variable = em
    [../]
    #[./em_time_deriv_SUPG]
    #  type = TimeDerivativeSUPG
    #  variable = em
    #  potential = potential
    #  position_units = ${dom0Scale}
    #  tau_name = tauem
    #[../]
    #Advection term of electron
    [./em_advection]
      type = EFieldAdvectionElectrons
      variable = em
      potential = potential
      mean_en = 0
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
    #[./em_diffusion]
    #  type = CoeffDiffusionElectrons
    #  variable = em
    #  mean_en = 0
    #  position_units = ${dom0Scale}
    #[../]
    [./source]
      type = BodyForce
      variable = em
      function = 'source_func'
    [../]

    #[./em_diffusion_SUPG]
    #  type = CoeffDiffusionSUPG
    #  variable = em
    #  var_for_second_derivative = em
    #  potential = potential
    #  tau_name = tauem
    #  position_units = ${dom0Scale}
    #[../]
    #Log Offset for electron density, not in paper since Zapdos uses an exponent form of density
    #[./em_log_stabilization]
    #  type = LogStabilizationMoles
    #  variable = em
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

  []


[AuxVariables]
  [./Ar+]
  [../]
  #[./potential]
  #[../]

  [./em_sol]
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
  #[./potential]
  #  type = FunctionAux
  #  variable =  potential
  #  function =  potential_func
  #[../]
  [./em_sol]
    type = FunctionAux
    variable = em_sol
    function = em_sol_func
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
#Voltage Boundary Condition, same as in paper
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

#New Boundary conditions for electons, should be same as in paper
#Checked Once, might need to check again later
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
  #[./potential_func]
  #  type = ParsedFunction
  #  #value = '(1.6e-19 / 8.85e-12) * cos(t)'
  #  value = 'x*x*cos(t)'
  #[../]
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
  [./Ar+_func]
    type = ParsedFunction
    value = 'log(10*x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) - 2*cos(t) + 3)'
  [../]
  [./source_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = '2*x*cos(t)*(10*x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 3)
    + x^2*cos(t)*(10*x*(exp(-t) - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 10*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1)
    + (sin(t) - 1)*(x - 1)) + 20*x*sin(t)*(exp(-t) - 1)*(x - 1)) + 10*x*(cos(t)*(x - 1) + x*cos(t))*(exp(-t) - 1)*(x - 1)
    - 10*x*exp(-t)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1))'
  [../]
  #[./dne_dt_func]
  #  type = ParsedFunction
  #  value = 'x*(cos(t)*(x - 1) + x*cos(t))*(exp(-t) - 1)*(x - 1) - x*exp(-t)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1))'
  #[../]
  #[./grad_grad_potent_ne_func]
  #  type = ParsedFunction
  #  value = '(2*x + x*cos(t))*(x*(exp(-t) - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1))
  #  + (exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 2*x*sin(t)*(exp(-t) - 1)*(x - 1) + 2)
  #  + (cos(t) + 2)*(2*x + x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 2)'
  #[../]
  #[./grad_grad_ne_func]
  #  type = ParsedFunction
  #  value = '2*(exp(-t) - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 4*x*sin(t)*(exp(-t) - 1) + 4*sin(t)*(exp(-t) - 1)*(x - 1)'
  #[../]
  [./muem_func]
    type = ParsedFunction
    #vars = 'a b c'
    #vals = 'dne_dt_func grad_grad_potent_ne_func grad_grad_ne_func'
    #value = '(c - a)/b'
    value = '1'
  [../]

  [./em_sol_func]
    type = ParsedFunction
    value = 'log(10*x*(exp(-t) - 1)*(x - 1)*(x*(sin(t) + 1) + (sin(t) - 1)*(x - 1)) + 3)'
  [../]
[]

[Materials]
  [./muem_prop]
    type = GenericFunctionMaterial
    prop_names = 'muem'
    prop_values = 'muem_func'
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
    prop_values = '1.0 1.0 1.0 1 -1 0 0'
  [../]
  [./tauem]
    type = ADMaterialsPlasmaSUPG
    species_name = em
    position_units = ${dom0Scale}
    potential = potential
    transient_term = false
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
  end_time = 20
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
  dtmin = 1e-20
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
