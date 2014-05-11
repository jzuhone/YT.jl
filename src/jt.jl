module jt

# Datasets, Indices

export Dataset, Index
export print_stats, get_smallest_dx

# YTArrays, YTQuantities, units

export YTArray, YTQuantity
export in_units, in_cgs

# load

export load, load_uniform_grid, load_amr_grids, load_particles

# DataContainers

export DataContainer, CutRegion, Disk, Ray, Slice
export Sphere, AllData, Projection, CoveringGrid, Grids, CuttingPlane
export cut_region

# Fixed resolution

export FixedResolutionBuffer, to_frb

# Plotting

export SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot
export show_plot

using PyCall
@pyimport yt

include("utils.jl")
include("yt_array.jl")
include("images.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("units.jl")
include("plots.jl")
include("profiles.jl")

import .yt_array: YTArray, YTQuantity, in_units, in_cgs
import .data_objects: Dataset, Grids, Sphere, AllData, Projection, Slice,
    CoveringGrid, to_frb, print_stats, get_smallest_dx, Disk, Ray,
    CuttingPlane, CutRegion, cut_region, DataContainer
import .plots: SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot, show_plot
import .images: FixedResolutionBuffer

load(fn::String; args...) = Dataset(yt.load(fn; args...))

# Stream datasets

function load_uniform_grid(data::Dict, domain_dimensions::Array; args...)
    ds = yt.load_uniform_grid(data, domain_dimensions; args...)
    return DataSet(ds)
end

function load_amr_grids(data::Dict, domain_dimensions::Array; args...)
    ds = yt.load_amr_grids(data, domain_dimensions; args...)
    return DataSet(ds)
end

function load_particles(data::Dict; args...)
    ds = yt.load_particles(data; args...)
    return DataSet(ds)
end

end
