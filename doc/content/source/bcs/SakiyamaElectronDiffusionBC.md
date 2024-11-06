# SakiyamaElectronDiffusionBC

!syntax description /BCs/SakiyamaElectronDiffusionBC

## Overview

`SakiyamaElectronDiffusionBC` is a thermal outflow boundary condition.

The thermal driven outflow is defined as

\begin{equation}
\Gamma_{e} \cdot \textbf{n} = \frac{1}{4}\sqrt{\frac{8e}{\pi m_{e}} \frac{2}{3} \frac{n_{\varepsilon}}{n_{e}}}n_{e}
\end{equation}

Where $\Gamma_e \cdot \textbf{n}$ is the flux normal to the boundary, $\textbf{n}$ is the normal vector of the boundary, $n_{e}$ is the electron density, $e$ is the elementary charge, and $n_{\varepsilon}$ is the mean energy density. When converting the density to log form and applying a scaling factor of the mesh, the strong form for `SakiyamaElectronDiffusionBC` is defined as

\begin{equation}
\Gamma_{e} \cdot \textbf{n} = \frac{1}{4}\sqrt{\frac{8e}{\pi m_{e}} \frac{2}{3} \exp (N_{\varepsilon} - N_{e})}\exp(N_{e})
\end{equation}

Where $N_{j}$ is the molar density of the species in log form.

## Example Input File Syntax


!listing test/tests/DriftDiffusionAction/2D_RF_Plasma_actions.i block=BCs/em_physical_diffusion

!syntax parameters /BCs/SakiyamaElectronDiffusionBC

!syntax inputs /BCs/SakiyamaElectronDiffusionBC

!syntax children /BCs/SakiyamaElectronDiffusionBC
