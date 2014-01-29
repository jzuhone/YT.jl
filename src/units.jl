module units

import ..yt_array: YTQuantity

using PyCall

@pyimport yt

# Length

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


end
