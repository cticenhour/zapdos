#!/bin/bash
#BSUB -n 20                          # Number of Cores: Required
#BSUB -W 72:00                       # Wall Time: Required
#BSUB -R span[hosts=1]               # Number of nodes: Optional
#BSUB -q shared_memory               # Choosing a queue: Optional
#BSUB -o testrun_ArgonCase_out%J     # Name of the output file (the one of tracking convergence, Not the .e file )
#BSUB -e testrun_ArgonCase_error%J   # Name of error file
#BSUB -J testrun_ArgonCase           # Name of the job
source /usr/local/usrapps/plasmas/.moose_profile  #Opens the moose environment
mpirun /usr/local/usrapps/plasmas/zapdos/zapdos-opt -i Lymberopoulos_with_argon_metastables.i
