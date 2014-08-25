module data_objects

import PyCall: PyObject, PyDict
import Base: size, show, showarray, display, showerror
import ..array: YTArray, YTQuantity, in_units
import ..images: FixedResolutionBuffer

Center = Union(String,Array,YTArray)
Length = Union(Real,Tuple,YTQuantity)

# Dataset

type Dataset
    ds::PyObject
    parameters::PyDict
    domain_center::YTArray
    domain_left_edge::YTArray
    domain_right_edge::YTArray
    domain_width::YTArray
    domain_dimensions::Array
    dimensionality::Integer
    current_time::YTQuantity
    current_redshift::Real
    max_level::Integer
    function Dataset(ds::PyObject)
        new(ds,
            PyDict(ds["parameters"]::PyObject),
            YTArray(ds["domain_center"]),
            YTArray(ds["domain_left_edge"]),
            YTArray(ds["domain_right_edge"]),
            YTArray(ds["domain_width"]),
            ds[:domain_dimensions],
            ds[:dimensionality][1],
            YTQuantity(ds["current_time"]),
            ds[:current_redshift],
            ds[:max_level][1])
    end
end

function get_smallest_dx(ds::Dataset)
    pycall(ds.ds[:index]["get_smallest_dx"], YTArray)[1]
end

function print_stats(ds::Dataset)
    ds.ds[:print_stats]()
end

# Data containers

abstract DataContainer

# All Data

type AllData <: DataContainer
    cont::PyObject
    ds::Dataset
    field_dict::Dict
    function AllData(ds::Dataset; args...)
        new(ds.ds[:all_data](args...), ds, Dict())
    end
end

# Point

type Point <: DataContainer
    cont::PyObject
    ds::Dataset
    coord::Array
    field_dict::Dict
    function Point(ds::Dataset, coord::Array; args...)
        pt = ds.ds[:point](coord; args...)
        new(pt, ds, pt[:p], Dict())
    end
end

# Region

type Region <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    left_edge::YTArray
    right_edge::YTArray
    field_dict::Dict
    function Region(ds::Dataset, center::Center, left_edge::Union(Array,YTArray),
                    right_edge::Union(Array,YTArray); args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(left_edge) == YTArray
            le = in_units(YTArray(ds, left_edge.value,
                          repr(left_edge.units.unit_symbol)),
                          "code_length").value
        else
            le = left_edge
        end
        if typeof(right_edge) == YTArray
            re = in_units(YTArray(ds, right_edge.value,
                          repr(right_edge.units.unit_symbol)),
                          "code_length").value
        else
            re = right_edge
        end
        reg = ds.ds[:region](c, le, re; args...)
        new(reg, ds, YTArray(reg["center"]), YTArray(reg["left_edge"]),
            YTArray(reg["right_edge"]), Dict())
    end
end

# Disk

type Disk <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    normal::Array
    field_dict::Dict
    function Disk(ds::Dataset, center::Center, normal::Array,
                  radius::Length, height::Length; args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(radius) == YTQuantity
            r = convert(PyObject, radius)
        else
            r = radius
        end
        if typeof(height) == YTQuantity
            h = convert(PyObject, height)
        else
            h = height
        end
        dk = ds.ds[:disk](c, normal, r, h; args...)
        new(dk, ds, YTArray(dk["center"]), normal, Dict())
    end
end

# Ray

type Ray <: DataContainer
    cont::PyObject
    ds::Dataset
    start_point::YTArray
    end_point::YTArray
    field_dict::Dict
    function Ray(ds::Dataset, start_point::Array,
                 end_point::Array; args...)
        ray = ds.ds[:ray](start_point, end_point; args...)
        new(ray, ds, YTArray(ray["start_point"]),
            YTArray(ray["end_point"]), Dict())
    end
end

# CuttingPlane

type Cutting <: DataContainer
    cont::PyObject
    ds::Dataset
    normal::Array
    center::YTArray
    field_dict::Dict
    function Cutting(ds::Dataset, normal::Array,
                     center::Center; args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        cutting = ds.ds[:cutting](normal, c; args...)
        new(cutting, ds, cutting[:normal], YTArray(cutting["center"]), Dict())
    end
end

# Projection

type Proj <: DataContainer
    cont::PyObject
    ds::Dataset
    field
    axis::Integer
    weight_field
    data_source
    field_dict::Dict
    function Proj(ds::Dataset, field, axis::Union(Integer,String);
                  weight_field=nothing, data_source=nothing, args...)
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        prj = ds.ds[:proj](field, axis, weight_field=weight_field,
                           data_source=source; args...)
        new(prj, ds, field, prj["axis"], weight_field, data_source, Dict())
    end
end

# Slice

type Slice <: DataContainer
    cont::PyObject
    ds::Dataset
    axis::Integer
    coord::Real
    field_dict::Dict
    function Slice(ds::Dataset, axis::Union(Integer,String),
                   coord::Real; args...)
        slc = ds.ds[:slice](axis, coord; args...)
        new(slc, ds, slc["axis"], slc["coord"], Dict())
    end
end

function to_frb(cont::Union(Slice,Proj), width::Union(Length,(Length,Length)),
                nx::Union(Integer,(Integer,Integer)); center=nothing,
                height=nothing, args...)
    FixedResolutionBuffer(cont.ds, cont.cont[:to_frb](width, nx;
                                                      center=center,
                                                      height=height, args...))
end

# Sphere

type Sphere <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    radius::YTQuantity
    field_dict::Dict
    function Sphere(ds::Dataset, center::Center, radius::Length; args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(radius) == YTQuantity
            r = convert(PyObject, radius)
        else
            r = radius
        end
        sp = ds.ds[:sphere](c, r; args...)
        new(sp, ds, YTArray(sp["center"]),
            YTQuantity(sp["radius"]), Dict())
    end
end

# CutRegion

type CutRegion <: DataContainer
    cont::PyObject
    ds::Dataset
    conditions::Array
    field_dict::Dict
    function CutRegion(dc::DataContainer, conditions::Array; args...)
        cut_reg = dc.cont[:cut_region](conditions; args...)
        new(cut_reg, dc.ds, conditions, Dict())
    end
end

# Grids

type Grids <: AbstractArray
    grids::Array
    grid_dict::Dict
    function Grids(ds::Dataset)
        new(ds.ds[:index][:grids], Dict())
    end
    function Grids(grid_array::Array)
        new(grid_array, Dict())
    end
    function Grids(grid::PyObject)
        new([grid], Dict())
    end
    function Grids(nothing)
        new([], Dict())
    end
end

size(grids::Grids) = size(grids.grids)

# Grid

type Grid <: DataContainer
    cont::PyObject
    left_edge::YTArray
    right_edge::YTArray
    id::Integer
    level::Integer
    number_of_particles::Integer
    active_dimensions::Array
    Parent::Grids
    Children::Grids
    field_dict::Dict
end

# CoveringGrid

type CoveringGrid <: DataContainer
    cont::PyObject
    ds::Dataset
    left_edge::YTArray
    right_edge::YTArray
    level::Integer
    active_dimensions::Array
    field_dict::Dict
    function CoveringGrid(ds::Dataset, level::Integer, left_edge::Array,
                          dims::Array; args...)
        cg = ds.ds[:covering_grid](level, left_edge, dims; args...)
        new(cg, ds, YTArray(cg["left_edge"]), YTArray(cg["right_edge"]),
            level, cg[:ActiveDimensions], Dict())
    end
end

# Field parameters

function set_field_parameter(dc::DataContainer, key::String, value)
    v = convert(PyObject, value)
    dc.cont[:set_field_parameter](key, v)
end

function has_field_parameter(dc::DataContainer, key::String)
    dc.cont[:has_field_parameter](key)
end

function get_field_parameter(dc::DataContainer, key::String)
    v = pycall(dc.cont["get_field_parameter"], PyObject, key)
    if contains(v[:__repr__](), "YTArray")
        v = YTArray(v)
    else
        v = dc.cont[:get_field_parameter](key)
    end
    return v
end

function get_field_parameters(dc::DataContainer)
    fp = Dict()
    for k in collect(keys(dc.cont[:field_parameters]))
        fp[k] = get_field_parameter(dc, k)
    end
    return fp
end

# Indices

function getindex(dc::DataContainer, field::Union(String,Tuple))
    if !haskey(dc.field_dict, field)
        dc.field_dict[field] = YTArray(get(dc.cont, PyObject, field))
        dc.cont[:__delitem__](field)
    end
    return dc.field_dict[field]
end

getindex(dc::DataContainer, ftype::String,
         fname::String) = getindex(dc, (ftype, fname))

function getindex(grids::Grids, i::Int)
    if !haskey(grids.grid_dict, i)
        g = grids.grids[i]
        grids.grid_dict[i] = Grid(g,
                                  YTArray(g["LeftEdge"]),
                                  YTArray(g["RightEdge"]),
                                  g[:id][1],
                                  g[:Level][1],
                                  g[:NumberOfParticles][1],
                                  g[:ActiveDimensions],
                                  Grids(g[:Parent]),
                                  Grids(g[:Children]), Dict())
    end
    return grids.grid_dict[i]
end

getindex(grids::Grids, idxs::Ranges) = Grids(grids.grids[idxs])

# Show

show(io::IO, ds::Dataset) = print(io,ds.ds[:__repr__]())
show(io::IO, dc::DataContainer) = print(io,dc.cont[:__repr__]())

function showarray(io::IO, grids::Grids)
    num_grids = length(grids)
    if num_grids == 0
        print(io, "[]")
        return
    end
    if num_grids == 1
        print(io, "[ $(grids.grids[1][:__repr__]()) ]")
        return
    end
    n = num_grids > 8 ? 5 : num_grids
    println(io, "[ $(grids.grids[1][:__repr__]()),")
    for grid in grids.grids[2:n-1]
        println(io, "  $(grid[:__repr__]()),")
    end
    if num_grids > 8
        println(io, "  ...")
        for grid in grids.grids[num_grids-3:num_grids-1]
            println(io, "  $(grid[:__repr__]()),")
        end
    end
    print(io, "  $(grids.grids[end][:__repr__]()) ]")
end

show(io::IO, grids::Grids) = showarray(io, grids)
display(grids::Grids) = show(STDOUT, grids)

end
