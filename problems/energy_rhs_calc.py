#!/usr/bin/env python
from sympy import *

x, y, z = symbols('x y z')

De = 1.1988e6
Di = 64.29
mue = 3e5
mui = 1.444e3
N = 3.22e16
ki = 6.02909e-11
kex = 1.35369e-10
V = 0.2 * (-x * x + 2.54 * x)
ne = 2e7 * (-x * x + 2.54 * x) + 1e3
ni = 2e7 * (-x * x + 2.54 * x) + 1e3
energy = exp((log(9.0) / 2.54) * x) + 3
e = 1.602177e-19
eps = 8.854188e-12

diff_ne = diff(ne, x)
diff_ni = diff(ni, x)
diff_energy = diff(energy, x)
diff_V = diff(V, x)
diff2_V = diff(diff_V, x)

lhs_ne_preDiff = -De * diff_ne + mue * ne * diff_V
rxn_ne = ki * N * ne
ne_MMS_rhs = diff(lhs_ne_preDiff, x) - rxn_ne

lhs_ni_preDiff = -Di * diff_ni - mui * ni * diff_V
rxn_ni = rxn_ne
ni_MMS_rhs = diff(lhs_ni_preDiff, x) - rxn_ni

V_MMS_rhs = -diff2_V - (e / eps) * (ni - ne)

energy_flux_preDiff = -(5.0 / 3.0) * De * ne * diff_energy + (5.0 / 3.0) * energy * (-De * diff_ne + mue * ne * diff_V)
energy_ne_flux = e * (-De * diff_ne + mue * ne * diff_V) * diff_V
energy_rxns = 11.56 * kex * N * ne + 15.7 * ki * N * ne
energy_MMS_rhs = diff(energy_flux_preDiff, x) - energy_ne_flux + energy_rxns
