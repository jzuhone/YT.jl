using Base.Test
using jt

function run_container_tests(dc::DataContainer)
    max_jt = maximum(dc["density"]).value
    min_jt = minimum(dc["density"]).value
    sum_jt = sum(dc["density"]).value
    len_jt = length(dc["density"])
    min_yt, max_yt = dc.cont[:quantities][:extrema][:__call__]("density")
    sum_yt = dc.cont[:quantities][:total_quantity][:__call__]("density")
    len_yt = int(dc.cont[:quantities][:total_quantity][:__call__]("ones"))[1]
    @test_approx_eq max_jt max_yt
    @test_approx_eq min_jt min_yt
    @test_approx_eq sum_jt sum_yt
    @test len_jt == len_yt
end

ds = load("GasSloshing/sloshing_nomag2_hdf5_plt_cnt_0100")

# AllData

dd = AllData(ds)

run_container_tests(dd)

# Spheres

sp1 = Sphere(ds, "c", (100.,"kpc"))
sp2 = Sphere(ds, "max", (3.0856e22,"cm"))
sp3 = Sphere(ds, [3.0856e22,-1.0e23,0], (0.2,"unitary"))

run_container_tests(sp1)
run_container_tests(sp2)
run_container_tests(sp3)

# Regions

reg1 = Region(ds, "c", [-3.0856e23,-3.0856e23,-3.0856e23],
              [3.0856e23,3.0856e23,3.0856e23])
reg2 = Region(ds, "max", [-3.0856e23,-3.0856e24,-6.1712e23],
              [6.1712e23, 3.0856e23, 3.0856e24])

run_container_tests(reg1)
run_container_tests(reg2)

# Disks

dk1 = Disk(ds, "c", [1.0,0.5,0.2], 3.0856e23, 3.0856e23)
dk2 = Disk(ds, [-1.0,0.7,-0.3], [0.0,3.0856e22,3.0856e23], 4e22, 5e23)

run_container_tests(dk1)
run_container_tests(dk2)

# Rays

# Slices

slc1 = Slice(ds, "z", 4e23)
slc2 = Slice(ds, 1, 0.0)

# Projections

prj1 = Projection(ds, "density", "z")
prj2 = Projection(ds, "density", 0, weight_field="temperature")
prj3 = Projection(ds, "density", 1, data_source=sp1)

# Cutting Planes

# Cut Regions

# Grids

# Covering Grids
