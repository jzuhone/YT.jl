module jt

export load, load_uniform_grid
export YTArray, YTQuantity, in_units, in_cgs, get_array
export Slice, Grids, Sphere, AllData, Projection, GridCollection, CoveringGrid
export physical_constants, units, to_frb
export SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot, show_plot, save_plot, call
export FixedResolutionBuffer

using PyCall
@pyimport yt.mods as ytmods
@pyimport yt

include("utils.jl")
include("array.jl")
include("images.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("units.jl")
include("plots.jl")

import .yt_array: YTArray, YTQuantity, in_units, in_cgs, get_array
import .data_objects: DataSet, Grids, Sphere, AllData, Projection, Slice,
    GridCollection, CoveringGrid, to_frb
import .plots: SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot, show_plot,
    save_plot, call
import .images: FixedResolutionBuffer

function load(fn::String; args...)
    ds = ytmods.load(fn; args...)
    return DataSet(ds)
end

function load_uniform_grid(data::Dict, domain_dimensions::Array; args...)
    ds = ytmods.load_uniform_grid(data, domain_dimensions; args...)
    return DataSet(ds)
end

end
