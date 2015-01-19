module physical_constants

import YT.array: YTQuantity

import PyCall: @pyimport

@pyimport yt.utilities as ytutils

# Fundamental constants
G = YTQuantity(ytutils.physical_constants["G"])
kboltz = YTQuantity(ytutils.physical_constants["kboltz"])
clight = YTQuantity(ytutils.physical_constants["clight"])
qp = YTQuantity(ytutils.physical_constants["qp"])
hcgs = YTQuantity(ytutils.physical_constants["hcgs"])
hbar = 0.5*hcgs/pi

# Masses
me = YTQuantity(ytutils.physical_constants["me"])
mp = YTQuantity(ytutils.physical_constants["mp"])
mh = mp
amu_cgs = YTQuantity(ytutils.physical_constants["amu_cgs"])
Na = 1 / amu_cgs

# Planck
m_pl = YTQuantity(ytutils.physical_constants["m_pl"])
l_pl = YTQuantity(ytutils.physical_constants["l_pl"])
t_pl = YTQuantity(ytutils.physical_constants["t_pl"])
E_pl = YTQuantity(ytutils.physical_constants["E_pl"])
T_pl = YTQuantity(ytutils.physical_constants["T_pl"])
q_pl = YTQuantity(ytutils.physical_constants["q_pl"])

# Electromagnetism
mu_0 = YTQuantity(ytutils.physical_constants["mu_0"])
eps_0 = YTQuantity(ytutils.physical_constants["eps_0"])
k_e = 1.0/(4*pi*eps_0)

# Solar System
# Standish, E.M. (1995) "Report of the IAU WGAS Sub-Group on Numerical Standards",
# in Highlights of Astronomy (I. Appenzeller, ed.), Table 1,
# Kluwer Academic Publishers, Dordrecht.
# REMARK: following masses include whole systems (planet + moons)
mass_sun_cgs = YTQuantity(ytutils.physical_constants["mass_sun_cgs"])
mass_mercury_cgs = YTQuantity(ytutils.physical_constants["mass_mercury_cgs"])
mass_venus_cgs = YTQuantity(ytutils.physical_constants["mass_venus_cgs"])
mass_earth_cgs = YTQuantity(ytutils.physical_constants["mass_earth_cgs"])
mass_mars_cgs = YTQuantity(ytutils.physical_constants["mass_mars_cgs"])
mass_jupiter_cgs = YTQuantity(ytutils.physical_constants["mass_jupiter_cgs"])
mass_saturn_cgs = YTQuantity(ytutils.physical_constants["mass_saturn_cgs"])
mass_uranus_cgs = YTQuantity(ytutils.physical_constants["mass_uranus_cgs"])
mass_neptune_cgs = YTQuantity(ytutils.physical_constants["mass_neptune_cgs"])

# Other
sigma_thompson = YTQuantity(ytutils.physical_constants["sigma_thompson"])
Tcmb = YTQuantity(ytutils.physical_constants["Tcmb"])
stefan_boltzmann_constant_cgs = YTQuantity(ytutils.physical_constants["stefan_boltzmann_constant_cgs"])

end
