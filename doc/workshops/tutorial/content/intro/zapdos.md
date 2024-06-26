# Zapdos Introduction

!---

# Zapdos Overview

- Zapdos is an open source multi-fluid plasma code, that:

  - Utilizes the finite element method, and
  - Solves for species densities in log-molar form.


- As a MOOSE-based application, Zapdos can take advantage of:

  - Scalable parallel computing, and
  - Flexible multiphysics coupling.

!---

# Current Research Efforts style=margin-top:1em;

- Validation and Verification

  - Modeling physical systems and comparing to experimental results.
  - Utilizing the Method of Manufactured Solutions (MMS) to ensure correct implementation.

!row!
!col! small=12 medium=4 large=4 icon=flash_on
!media media/experimental.png
       style=width:40%;display:block;margin-top:-0.5em;margin-left:3em;margin-right:auto;
       caption=Experimental Comparison with results from [!cite](greenberg1993electron).

!col-end!

!col! small=12 medium=4 large=4 icon=flash_on
!media media/mms.png
       style=width:37%;display:block;margin-top:-0.5em;margin-left:-5em;margin-right:auto;
       caption=1D MMS Convergence study results for a single ionic species, electrons and mean electron energy.

!col-end!
!row-end!

!---

#  Code Development

- Improving physics
- Electromagnetic coupling
- Improving the user interface
- Finite volume implementation
