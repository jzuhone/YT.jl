module jt

export load
export YTArray, YTQuantity, in_units, in_cgs
export Grids, Sphere, AllData
export physical_constants
export SlicePlot, show, annotate_grids, set_width, zoom, set_log

using PyCall
@pyimport yt.mods as ytmods
@pyimport yt

include("array.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("plots.jl")

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
