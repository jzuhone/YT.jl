module jt

export load
export YTArray, YTQuantity, in_units, in_cgs
export Grids, Sphere, AllData
export physical_constants, units
export SlicePlot, ProjectionPlot, show_plot, save_plot, call

using PyCall
@pyimport yt.mods as ytmods
@pyimport yt

include("utils.jl")
include("array.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("units.jl")
include("plots.jl")

import .yt_array: YTArray, YTQuantity, in_units, in_cgs
import .data_objects: DataSet, Grids, Sphere, AllData
import .plots: SlicePlot, ProjectionPlot, show_plot, save_plot, call

function load(fn::String; args...)
    ds = ytmods.load(fn; args...)
    return DataSet(ds, ds[:h],
                   PyDict(ds[:h]["parameters"]::PyObject),
                   YTArray(ds["domain_center"]),
                   YTArray(ds["domain_left_edge"]),
                   YTArray(ds["domain_right_edge"]),
                   YTArray(ds["domain_width"]),
                   ds[:domain_dimensions],
                   ds[:dimensionality][1],
                   YTQuantity(ds["current_time"]),
                   ds[:current_redshift])
end

end
