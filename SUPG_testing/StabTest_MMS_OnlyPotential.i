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
  [./potential]
  [../]
[]

[Kernels]
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

  [./em]
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
  [./em]
    type = FunctionAux
    variable = em
    function = em_sol_func
  [../]
  [./Ar+]
    type = FunctionAux
    variable = Ar+
    function = Ar+_sol_func
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

[]


[ICs]
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
    value = '0.100*sin(2*3.1415926*13.56e6*t)'
  [../]
  [./potential_ic_func]
    type = ParsedFunction
    #value = '(1.6e-19 / 8.85e-12) * x * x'
    value = '0.100 * (x)'
  [../]
  [./em_sol_func]
    type = ParsedFunction
    value = 'log((-8e13*x*(x - 1)*(x*(sin(2*3.1415926*13.56e6*t) + 1) + (sin(2*3.1415926*13.56e6*t) - 1)*(x - 1)) + 1e1)/6.022e23)'
  [../]
  [./Ar+_sol_func]
    type = ParsedFunction
    value = 'log((-1e14*x*(x - 1) + 1e1)/6.022e23)'
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
  [./muAr+_prop]
    type = GenericConstantMaterial
    prop_names = 'muAr+'
    prop_values = '1'
  [../]
  [./diffAr+_prop]
    type = GenericConstantMaterial
    prop_names = 'diffAr+'
    prop_values = 0
  [../]
  [./constents_prop]
    type = GenericConstantMaterial
    prop_names = 'e N_A diffpotential sgnAr+ sgnem d_muem_d_actual_mean_en d_diffem_d_actual_mean_en'
    prop_values = '1.6e-19 6.022e23 8.85e-12 1 -1 0 0'
    #prop_values = '1.0 1.0 1.0 1 -1 0 0'
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
  end_time = 5e-4
  dtmax = 3.7e-9
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
