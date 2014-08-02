using Base.Test
using jt
using PyCall

@pyimport yt.funcs as yt_funcs

function test_container(dc::DataContainer, py_dc::PyObject)
    for field in ["density", "temperature", "velocity_magnitude"]
        a = dc[field]
        b = pycall(py_dc["__getitem__"], PyObject, field)
        @test all(a.value .== PyArray(b))
        @test a.units.unit_symbol == b[:units]
    end
end

function check_container(dc::DataContainer; args=[])
    cont_name = yt_funcs.camelcase_to_underscore(repr(typeof(dc)))
    py_dc = pycall(dc.ds.ds[cont_name], PyObject, args...)
    test_container(dc, py_dc)
end

ds = load("GasSloshing/sloshing_nomag2_hdf5_plt_cnt_0100")

# AllData

dd = AllData(ds)

check_container(dd)

# Spheres

args1 = "c", (100.,"kpc")
args2 = "max", (3.0856e22,"cm")
args3 = [3.0856e22,-1.0e23,0], (0.2,"unitary")

sp1 = Sphere(ds, args1...)
sp2 = Sphere(ds, args2...)
sp3 = Sphere(ds, args3...)

check_container(sp1, args=args1)
check_container(sp2, args=args2)
check_container(sp3, args=args3)

# Regions

args1 = "c", [-3.0856e23,-3.0856e23,-3.0856e23], [3.0856e23,3.0856e23,3.0856e23]
args2 = "max", [-3.0856e23,-3.0856e24,-6.1712e23], [6.1712e23, 3.0856e23, 3.0856e24]
reg1 = Region(ds, args1...)
reg2 = Region(ds, args2...)

check_container(reg1, args=args1)
check_container(reg2, args=args2)

# Disks

args1 = "c", [1.0,0.5,0.2], 3.0856e23, 3.0856e23
args2 = [-1.0,0.7,-0.3], [0.0,3.0856e22,3.0856e23], 4e22, 5e23
dk1 = Disk(ds, args1...)
dk2 = Disk(ds, args2...)

check_container(dk1, args=args1)
check_container(dk2, args=args2)

# Rays

args = [0.0,3.0856e22,3.0856e23], [1.0e24,-3.0e23,5.0e22]
ray = Ray(ds, args...)

check_container(ray, args=args)

# Slices

args1 = "z", 4e23
args2 = 1, 0.0
slc1 = Slice(ds, args1...)
slc2 = Slice(ds, args2...)

check_container(slc1, args=args1)
check_container(slc2, args=args2)

# Projections

#args1 = "density", "z"
#args2 = ["field"=>"density", "axis"=>0, "weight_field"=>"temperature"]
#args3 = "density", 1
#kwargs3 = ["data_source"=>sp1]
#prj1 = Projection(ds, args1...)
#prj2 = Projection(ds; args2...)
#prj3 = Projection(ds, args3...; kwargs3...)

# Cutting Planes

args1 = [1.0, 0.5, 0.3], "c"
args2 = [0.2, -0.3, -0.4], [3.0856e22, 3.0856e23, -1.0e23]
cp1 = Cutting(ds, args1...)
cp2 = Cutting(ds, args2...)

check_container(cp1, args=args1)
check_container(cp2, args=args2)

# Cut Regions

# Covering Grids

# Grids

grids = Grids(ds)
num_grids = length(grids)
pygrids = ds.ds[:index][:grids]

for i in 1:num_grids
    test_container(grids[i], pygrids[i])
end
