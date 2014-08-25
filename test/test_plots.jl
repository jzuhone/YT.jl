# All this does is make sure that the plots work without errors

using Base.Test
using YT
using PyCall

ds = load("GasSloshing/sloshing_nomag2_hdf5_plt_cnt_0100")

slc = SlicePlot(ds, "z", ["density","temperature"])
slc.set_width(500.,"kpc")
slc.annotate_grids()
slc.save()

prj = ProjectionPlot(ds, "z", ["temperature"], weight_field="density")
prj.set_log("temperature", false)
prj.save()
