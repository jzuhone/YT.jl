using Base.Test
import YT
using PyCall

@pyimport test_containers
cont_dict = test_containers.cont_dict

ds = YT.load("enzo_tiny_cosmology/DD0046/DD0046")

YT.print_stats(ds)
YT.get_field_list(ds)
YT.get_derived_field_list(ds)
show(ds)

test_dir = Pkg.dir("YT") * "/test"

file_to_read = "$(test_dir)/containers.h5"

for key in keys(cont_dict)
    cont_name = cont_dict[key][1]
    cont_args = cont_dict[key][2]
    cont_kwargs = cont_dict[key][3]
    kwargs = Dict()
    for k in keys(cont_kwargs)
        kwargs[convert(Symbol, k)] = cont_kwargs[k]
    end
    cont = getfield(YT, convert(Symbol, cont_name))
    c = cont(ds, cont_args...; kwargs...)
    a = c["density"]
    b = YT.from_hdf5(file_to_read, dataset_name=key)
    @test all(a.value .== b.value)
    @test a.units.unit_symbol == b.units.unit_symbol

# Special handling

# Projection with source

sp1 = YT.Sphere(ds, cont_dict["sp1"][2]...)
prj = YT.Proj(ds, "density", 1, data_source=sp1)
a = prj["density"]
b = YT.from_hdf5(file_to_read, dataset_name="prj3")
@test all(a.value .== b.value)
@test a.units.unit_symbol == b.units.unit_symbol

# Cut region

conditions = ["obj['kT'] > 0.5"]
sp2 = YT.Sphere(ds, cont_dict["sp2"][2]...)
cr = YT.CutRegion(sp2, conditions)
a = cr["density"]
b = YT.from_hdf5(file_to_read, dataset_name="cr")
@test all(a.value .== b.value)
@test a.units.unit_symbol == b.units.unit_symbol
kT = YT.YTQuantity(0.5, "keV")
@test all(cr["kT"] .> kT)

# Grids

grids = YT.Grids(ds)
num_grids = length(grids)

for i in 1:num_grids
    a = grids[i]["density"]
    b = YT.from_hdf5(file_to_read, dataset_name=@sprintf("grid_%04d", i))
    @test all(a.value .== b.value)
    @test a.units.unit_symbol == b.units.unit_symbol
end

show(grids)

# Find minima and maxima

dd = YT.AllData(ds)

vmin, cmin = YT.find_min(ds, "density")
vmax, cmax = YT.find_max(ds, "density")

@test vmin == minimum(dd["density"])
@test vmax == maximum(dd["density"])

end

