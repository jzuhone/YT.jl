using Base.Test
using YT

ds = load("enzo_tiny_cosmology/DD0046/DD0046")

sp = Sphere(ds, "max", (0.25, "unitary"))

profile = YTProfile(sp, "radius", ["density","temperature"], weight_field="ones")

@test string(profile["density"].units) == "g/cm^3"
set_field_unit(profile, "density", "Msun/kpc^3")
@test string(profile["density"].units) == "Msun/kpc^3"

@test string(variance(profile, "density").units) == "Msun/kpc^3"

show(STDOUT, profile)

profile3 = YTProfile(sp, ["x","y","z"], "cell_mass", weight_field=nothing)

show(STDOUT, profile3)

set_x_unit(profile3, "kpc")
set_y_unit(profile3, "ly")
set_z_unit(profile3, "mile")

@test string(profile3.x.units) == "kpc"
@test string(profile3.y.units) == "ly"
@test string(profile3.z.units) == "mile"
