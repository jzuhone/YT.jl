module YT

# Datasets, Indices

export Dataset
export print_stats, get_smallest_dx
export find_min, find_max, get_field_list
export get_derived_field_list

# YTArrays, YTQuantities, units

export YTArray, YTQuantity, YTUnit
export in_units, in_cgs, in_mks, from_hdf5, write_hdf5
export to_equivalent, list_equivalencies, has_equivalent
export convert_to_units, convert_to_cgs, convert_to_mks

# load

export load, load_uniform_grid, load_amr_grids, load_particles

# DataContainers

export DataContainer, CutRegion, Disk, Ray, Slice, Region, Point
export Sphere, AllData, Proj, CoveringGrid, Grids, Cutting, OrthoRay
export set_field_parameter, get_field_parameter, get_field_parameters
export has_field_parameter

# Fixed resolution

export FixedResolutionBuffer, to_frb

# Profiles

export YTProfile, add_fields, variance
export set_field_unit, set_x_unit, set_y_unit, set_z_unit

# Plotting

export SlicePlot, ProjectionPlot
export show_plot

# DatasetSeries

export DatasetSeries

# Other

export enable_plugins, ytcfg, quantities

import PyCall: @pyimport, PyError, pycall, PyObject, set!

include("../deps/yt_check.jl")

check_for_yt()

@pyimport yt
@pyimport yt.convenience as ytconv
@pyimport yt.frontends.stream.api as ytstream
@pyimport yt.config as ytconfig

if VERSION < v"0.4-"
    macro doc(args...)
        return esc(args[1].args[end])
    end
end

include("array.jl")
include("fixed_resolution.jl")
include("data_objects.jl")
include("physical_constants.jl")
include("dataset_series.jl")
include("plots.jl")
include("profiles.jl")

import .array: YTArray, YTQuantity, in_units, in_cgs, in_mks, YTUnit,
    from_hdf5, write_hdf5, to_equivalent, list_equivalencies,
    has_equivalent, convert_to_units, convert_to_mks, convert_to_cgs
import .data_objects: Dataset, Grids, Sphere, AllData, Proj, Slice,
    CoveringGrid, to_frb, print_stats, get_smallest_dx, Disk, Ray,
    Cutting, CutRegion, DataContainer, Region, has_field_parameter,
    set_field_parameter, get_field_parameter, get_field_parameters,
    Point, find_min, find_max, get_field_list, get_derived_field_list,
    OrthoRay
import .plots: SlicePlot, ProjectionPlot, show_plot
import .fixed_resolution: FixedResolutionBuffer
import .profiles: YTProfile, set_x_unit, set_y_unit, set_z_unit,
    set_field_unit, variance
import .dataset_series: DatasetSeries
import Base: show

@doc doc""" Enable the plugins defined in the plugin file.""" ->
enable_plugins = yt.enable_plugins

type YTConfig
    ytcfg::PyObject
end

function setindex!(ytcfg::YTConfig, value::String, section::String, param::String)
    set!(ytcfg.ytcfg, (section,param), value)
end

function getindex(ytcfg::YTConfig, section::String, param::String)
    pycall(ytcfg.ytcfg["get"], String, section, param)
end

show(ytcfg::YTConfig) = typeof(ytcfg)

@doc doc""" The yt configuration object.""" ->
ytcfg = YTConfig(ytconfig.ytcfg)

@doc doc""" `load` a `Dataset` object from the file `fn::ASCIIString`.""" ->
load(fn::ASCIIString; args...) = Dataset(ytconv.load(fn; args...))

# Stream datasets

function load_uniform_grid(data::Dict{Array{Float64},ASCIIString}, 
                           domain_dimensions::Array{Integer}; 
                           length_unit=nothing, bbox=nothing,
                           nprocs=1, sim_time=0.0, mass_unit=nothing,
                           time_unit=nothing, velocity_unit=nothing,
                           magnetic_unit=nothing, periodicity=(true, true, true), 
                           geometry="cartesian")
    ds = ytstream.load_uniform_grid(data, domain_dimensions; length_unit=length_unit,
                                    bbox=bbox, nprocs=nprocs, sim_time=sim_time,
                                    mass_unit=mass_unit, time_unit=time_unit,
                                    velocity_unit=velocity_unit, magnetic_unit=magnetic_unit,
                                    periodicity=periodicity, geometry=geometry)
    return Dataset(ds)
end

function load_amr_grids(data::Array, domain_dimensions::Array{Integer};
                        field_units=nothing, bbox=nothing, sim_time=0.0, 
                        length_unit=nothing, mass_unit=nothing, time_unit=nothing, 
                        velocity_unit=nothing, magnetic_unit=nothing, 
                        periodicity=(true, true, true), geometry="cartesian", refine_by=2)
    ds = ytstream.load_amr_grids(data, domain_dimensions; field_units=field_units,
                                 bbox=bbox, sim_time=sim_time, length_unit=length_unit,
                                 mass_unit=mass_unit, time_unit=time_unit,
                                 velocity_unit=velocity_unit, magnetic_unit=magnetic_unit,
                                 periodicity=periodicity, geometry=geometry, refine_by=refine_by)
    return Dataset(ds)
end

function load_particles(data::Dict{Array{Float64},ASCIIString}; length_unit=nothing, 
                        bbox=nothing, sim_time=0.0, mass_unit=nothing, time_unit=nothing, 
                        velocity_unit=nothing, magnetic_unit=nothing, periodicity=(true, true, true), 
                        n_ref=64, over_refine_factor=1, geometry="cartesian")
    ds = ytstream.load_particles(data; length_unit=length_unit, bbox=bbox, sim_time=sim_time,
                                 mass_unit=mass_unit, time_unit=time_unit, velocity_unit=velocity_unit,
                                 magnetic_unit=magnetic_unit, periodicity=periodicity, n_ref=n_ref,
                                 over_refine_factor=over_refine_factor, geometry=geometry)
    return Dataset(ds)
end

end
