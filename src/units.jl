module units

import ..yt_array: YTQuantity

using PyCall

@pyimport yt

# meter

fm = femtometer = YTQuantity(yt.units["fm"])
pm = picometer  = YTQuantity(yt.units["pm"])
nm = nanometer  = YTQuantity(yt.units["nm"])
um = micrometer = YTQuantity(yt.units["um"])
mm = millimeter = YTQuantity(yt.units["mm"])
cm = centimeter = YTQuantity(yt.units["cm"])
m  = meter      = YTQuantity(yt.units["m"])
km = kilometer  = YTQuantity(yt.units["km"])
Mm = Megameter  = YTQuantity(yt.units["Mm"])

# parsec

pc  = parsec = YTQuantity(yt.units["pc"])
kpc = kiloparsec = YTQuantity(yt.units["kpc"])
Mpc = mpc = megaparsec = YTQuantity(yt.units["Mpc"])
Gpc = gpc = Gigaparsec = YTQuantity(yt.units["Gpc"])

# gram

mg = milligram  = YTQuantity(yt.units["mg"])
g  = gram       = YTQuantity(yt.units["g"])
kg = kilogram   = YTQuantity(yt.units["kg"])

# second

fs   = femtoseconds = YTQuantity(yt.units["fs"])
ps   = picosecond   = YTQuantity(yt.units["ps"])
ns   = nanosecond   = YTQuantity(yt.units["ns"])
ms   = millisecond  = YTQuantity(yt.units["ms"])
s    = second       = YTQuantity(yt.units["s"])

# hour

hr = hour = YTQuantity(yt.units["hr"])

# day

day = YTQuantity(yt.units["day"])

# year

yr   = year                = YTQuantity(yt.units["yr"])
kyr  = kiloyear            = YTQuantity(yt.units["kyr"])
Myr  = Megayear = megayear = YTQuantity(yt.units["Myr"])
Gyr  = Gigayear = gigayear = YTQuantity(yt.units["Gyr"])

# Kelvin

degree_kelvin = Kelvin = YTQuantity(yt.units["Kelvin"])

#
# Misc CGS
#

dyne = dyn = YTQuantity(yt.units["dyne"])
erg = ergs = YTQuantity(yt.units["erg"])
electrostatic_unit = esu = YTQuantity(yt.units["esu"])
gauss = YTQuantity(yt.units["gauss"])

#
# Misc SI
#

J  = Joule = joule = YTQuantity(yt.units["J"])
W  = Watt  = watt = YTQuantity(yt.units["W"])
Hz = Hertz = hertz = YTQuantity(yt.units["Hz"])

#
# Imperial units
#

ft = foot = YTQuantity(yt.units["ft"])
mile = YTQuantity(yt.units["mile"])

#
# Solar units
#

Msun = solar_mass = YTQuantity(yt.units["Msun"])
msun = YTQuantity(yt.units["msun"])
Rsun = solar_radius = YTQuantity(yt.units["Rsun"])
rsun = YTQuantity(yt.units["rsun"])
Lsun = lsun = solar_luminosity = YTQuantity(yt.units["Lsun"])
Tsun = solar_temperature = YTQuantity(yt.units["Tsun"])
Zsun = solar_metallicity = YTQuantity(yt.units["Zsun"])

#
# Misc Astronomical units
#

AU = astronomical_unit = YTQuantity(yt.units["AU"])
au = YTQuantity(yt.units["au"])
ly = light_year = YTQuantity(yt.units["ly"])

#
# Physical units
#

eV  = electron_volt = YTQuantity(yt.units["eV"])
keV = kilo_electron_volt = YTQuantity(yt.units["keV"])
amu = atomic_mass_unit = YTQuantity(yt.units["amu"])
me  = electron_mass = YTQuantity(yt.units["me"])

#
# Degree units
#

deg    = degree         = YTQuantity(yt.units["degree"])
arcmin = arcminute      = YTQuantity(yt.units["arcmin"])
arcsec = arcsecond      = YTQuantity(yt.units["arcsec"])
rad    = radian         = YTQuantity(yt.units["radian"])
mas    = milliarcsecond = YTQuantity(yt.units["mas"])

end
