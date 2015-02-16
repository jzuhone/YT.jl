# All this does is make sure that the plots run without errors

using Base.Test
using YT
using PyCall

ds = load("enzo_tiny_cosmology/DD0046/DD0046")

slc = SlicePlot(ds, "z", ["density","temperature"])
slc.set_width(0.3,"unitary")
slc.annotate_grids()
slc.save()

prj = ProjectionPlot(ds, "z", ["temperature"], weight_field="density")
prj.set_log("temperature", false)
prj.save()

rad = YTQuantity(0.5,"Mpc")
val, ctr = find_max(ds, "density")
sp = Sphere(ds, ctr, rad)
prj = ProjectionPlot(ds, "z", ["temperature"], weight_field="density", data_source=sp)
prj.set_log("temperature", false)
prj.save()
