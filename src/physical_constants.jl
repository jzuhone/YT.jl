__precompile__()
module physical_constants

import YT.array: YTQuantity

import PyCall: pyimport_conda, PyNULL

pc_list = ["G", "kboltz", "clight", "qp", "hcgs", "me", "mp", "amu_cgs", "m_pl",
           "l_pl", "t_pl", "E_pl", "T_pl", "q_pl", "mu_0", "eps_0", "Tcmb",
           "sigma_thompson", "stefan_boltzmann_constant_cgs", "mass_sun_cgs",
           "mass_mercury_cgs", "mass_venus_cgs", "mass_earth_cgs", "mass_mars_cgs",
           "mass_jupiter_cgs", "mass_saturn_cgs", "mass_uranus_cgs", "mass_neptune_cgs"]

const ytpc = PyNULL()

function __init__()

    copy!(ytpc, pyimport_conda("yt.utilities.physical_constants", "yt"))

    for pc in pc_list
        c = Symbol(pc)
        @eval global $c = YTQuantity(ytpc[$pc])
    end

    global hbar = 0.5*hcgs/pi
    global mh = mp
    global Na = 1 / amu_cgs
    global k_e = 1.0/(4*pi*eps_0)

end

end
