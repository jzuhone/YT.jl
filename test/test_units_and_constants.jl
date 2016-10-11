import YT

import PyCall: @pyimport

@pyimport yt.units.unit_lookup_table as lut

pc = YT.physical_constants
u = YT.unit_symbols

pc.G
pc.kboltz
pc.clight
pc.qp
pc.hcgs
pc.hbar
pc.me
pc.mp
pc.mh
pc.amu_cgs
pc.Na
pc.m_pl
pc.l_pl
pc.t_pl
pc.E_pl
pc.T_pl
pc.q_pl
pc.mu_0
pc.eps_0
pc.k_e
pc.mass_sun_cgs
pc.mass_mercury_cgs
pc.mass_venus_cgs
pc.mass_earth_cgs
pc.mass_mars_cgs
pc.mass_jupiter_cgs
pc.mass_saturn_cgs
pc.mass_uranus_cgs
pc.mass_neptune_cgs
pc.sigma_thompson
pc.Tcmb
pc.stefan_boltzmann_constant_cgs

base_units = collect(keys(lut.default_unit_symbol_lut))
prefixes = collect(keys(lut.unit_prefixes))
prefixable_units = lut.prefixable_units

for unit in base_units
    uu = symbol(unit)
    getfield(u, uu)
    if unit in lut.prefixable_units
        for prefix in prefixes
            pu = string(prefix*unit)
            if pu != "as"
                uu = symbol(pu)
                getfield(u, uu)
            end
        end
    end
end
