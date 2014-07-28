module jt

# Datasets, Indices

export Dataset
export print_stats, get_smallest_dx

# YTArrays, YTQuantities, units

export YTArray, YTQuantity
export in_units, in_cgs, in_mks

# load

export load, load_uniform_grid, load_amr_grids, load_particles

# DataContainers

export DataContainer, CutRegion, Disk, Ray, Slice, Region
export Sphere, AllData, Projection, CoveringGrid, Grids, CuttingPlane
export cut_region

# Fixed resolution

export FixedResolutionBuffer, to_frb

# Profiles

export Profile1D, Profile2D, Profile3D, add_fields
export set_field_unit, set_x_unit, set_y_unit, set_z_unit

# Plotting

export SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot
export show_plot

using PyCall
@pyimport yt.convenience as ytconv
@pyimport yt.frontends.stream.api as ytstream

include("utils.jl")
include("array.jl")
include("images.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("plots.jl")
include("profiles.jl")

import .array: YTArray, YTQuantity, in_units, in_cgs, in_mks
import .data_objects: Dataset, Grids, Sphere, AllData, Projection, Slice,
    CoveringGrid, to_frb, print_stats, get_smallest_dx, Disk, Ray,
    CuttingPlane, CutRegion, cut_region, DataContainer, Region
import .plots: SlicePlot, ProjectionPlot, PhasePlot, ProfilePlot, show_plot
import .images: FixedResolutionBuffer
import .profiles: Profile1D, Profile2D, Profile3D, add_fields, set_x_unit,
    set_y_unit, set_z_unit, set_field_unit

load(fn::String; args...) = Dataset(ytconv.load(fn; args...))

# Stream datasets

function load_uniform_grid(data::Dict, domain_dimensions::Array; args...)
    ds = ytstream.load_uniform_grid(data, domain_dimensions; args...)
    return DataSet(ds)
end

function load_amr_grids(data::Dict, domain_dimensions::Array; args...)
    ds = ytstream.load_amr_grids(data, domain_dimensions; args...)
    return DataSet(ds)
end

function load_particles(data::Dict; args...)
    ds = ytstream.load_particles(data; args...)
    return DataSet(ds)
end

end
