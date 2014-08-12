using Base.Test
using YT
using PyCall

ds = load("GasSloshing/sloshing_nomag2_hdf5_plt_cnt_0100")

slc = Slice(ds, "z", 0.0)
prj = Proj(ds, "density", "z")

py_slc = ds.ds[:slice]("z", 0.0)
py_prj = ds.ds[:proj]("density", "z")

frb1 = to_frb(slc, (500.,"kpc"), 800)
frb2 = to_frb(prj, (500.,"kpc"), 800)

pyfrb1 = pycall(py_slc["to_frb"], PyObject, (500.,"kpc"), 800)
pyfrb2 = pycall(py_prj["to_frb"], PyObject, (500.,"kpc"), 800)

a = frb1["density"]
b = pycall(pyfrb1["__getitem__"], PyObject, "density")
@test all(a.value .== PyArray(b))
@test a.units.unit_symbol == b[:units]

a = frb2["density"]
b = pycall(pyfrb2["__getitem__"], PyObject, "density")
@test all(a.value .== PyArray(b))
@test a.units.unit_symbol == b[:units]
