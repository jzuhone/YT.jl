using Base.Test
using YT

test_dir = dirname(@__FILE__)

file_to_read = "$(test_dir)/frbs.h5"

ds = load("enzo_tiny_cosmology/DD0046/DD0046")

slc = Slice(ds, "z", 0.0)
prj = Proj(ds, "density", "z")
cut = Cutting(ds, [0.4, 0.5, 0.3], "c")

frb1 = to_frb(slc, YTQuantity(500.,"kpc"), 800)
frb2 = to_frb(prj, (500.,"kpc"), 800)
frb3 = to_frb(cut, (500.,"kpc"), 800)
frb4 = to_frb(cut, YTQuantity(ds, 500.,"kpc"), 800)

a = frb1["density"]
b = from_hdf5(file_to_read, dataset_name="frb1")
@test all(a.value .== b.value)
@test a.units == b.units
@test a[1,50] == b[1,50]
@test a[1,50].units == b[1,50].units
@test a.value[1,50] == b.value[1,50]

a = frb2["density"]
b = from_hdf5(file_to_read, dataset_name="frb2")
@test all(a.value .== b.value)
@test a.units == b.units

a = frb3["density"]
b = from_hdf5(file_to_read, dataset_name="frb3")
@test all(a.value .== b.value)
@test a.units == b.units

c = frb4["density"]
@test all(a.value .== c.value)
@test a.units == c.units

show(STDOUT, frb3)

# Quick field name check

@test frb3["density"].value == frb3["gas","density"].value
