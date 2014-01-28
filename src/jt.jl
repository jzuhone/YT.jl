module jt

export load, YTArray, YTQuantity, Grids, Sphere, AllData, in_units, in_cgs
export physical_constants

using PyCall
@pyimport yt.mods as ytmods
@pyimport yt

include("array.jl")
include("data_objects.jl")
include("physical_constants.jl")

function load(fn::String)
    ds = ytmods.load(fn)
    return DataSet(ds, ds[:h],
                   PyDict(ds[:h]["parameters"]::PyObject),
                   YTArray(ds["domain_left_edge"]),
                   YTArray(ds["domain_right_edge"]),
                   YTArray(ds["domain_width"]),
                   ds[:domain_dimensions])
end

end
