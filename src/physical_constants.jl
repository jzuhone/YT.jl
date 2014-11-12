module physical_constants

import ..array: YTQuantity

import PyCall: @pyimport

@pyimport yt.utilities as ytutils

G = YTQuantity(ytutils.physical_constants["G"])
kboltz = YTQuantity(ytutils.physical_constants["kboltz"])
clight = YTQuantity(ytutils.physical_constants["clight"])
me = YTQuantity(ytutils.physical_constants["me"])
mp = YTQuantity(ytutils.physical_constants["mp"])
mh = mp
qp = YTQuantity(ytutils.physical_constants["qp"])
hcgs = YTQuantity(ytutils.physical_constants["hcgs"])
sigma_thompson = YTQuantity(ytutils.physical_constants["sigma_thompson"])
amu_cgs = YTQuantity(ytutils.physical_constants["amu_cgs"])
Na = 1 / amu_cgs
Tcmb = YTQuantity(ytutils.physical_constants["Tcmb"])
stefan_boltzmann_constant_cgs = YTQuantity(ytutils.physical_constants["stefan_boltzmann_constant_cgs"])
hbar = 0.5*hcgs/pi
m_pl = YTQuantity(ytutils.physical_constants["m_pl"])
l_pl = YTQuantity(ytutils.physical_constants["l_pl"])
t_pl = YTQuantity(ytutils.physical_constants["t_pl"])
E_pl = YTQuantity(ytutils.physical_constants["E_pl"])
T_pl = YTQuantity(ytutils.physical_constants["T_pl"])
q_pl = YTQuantity(ytutils.physical_constants["q_pl"])
mu_0 = YTQuantity(ytutils.physical_constants["mu_0"])
eps_0 = YTQuantity(ytutils.physical_constants["eps_0"])
k_e = 1.0/(4*pi*eps_0)

end
