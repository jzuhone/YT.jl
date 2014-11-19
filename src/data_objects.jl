module data_objects

import PyCall: PyObject, PyDict, pycall, pybuiltin, PyAny
import Base: size, show, showarray, display, showerror
import ..array: YTArray, YTQuantity, in_units, array_or_quan
import ..fixed_resolution: FixedResolutionBuffer

Center = Union(String,Array{Real,3},YTArray)
Length = Union(Real,(Real,String),YTQuantity)

# Dataset

type Dataset
    ds::PyObject
    parameters::PyDict
    domain_center::YTArray
    domain_left_edge::YTArray
    domain_right_edge::YTArray
    domain_width::YTArray
    domain_dimensions::Array{Integer,3}
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

function find_min(ds::Dataset, field)
    v, c = pycall(ds.ds["find_min"], (PyObject, PyObject), field)
    return YTQuantity(v), YTArray(c)
end

function find_max(ds::Dataset, field)
    v, c = pycall(ds.ds["find_max"], (PyObject, PyObject), field)
    return YTQuantity(v), YTArray(c)
end

function get_field_list(ds::Dataset)
    ds.ds[:field_list]
end

function get_derived_field_list(ds::Dataset)
    ds.ds[:derived_field_list]
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
    coord::Array{Real,3}
    field_dict::Dict
    function Point(ds::Dataset, coord::Array{Real,3}; args...)
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
    function Region(ds::Dataset, center::Center,
                    left_edge::Union(Array{Real,3},YTArray),
                    right_edge::Union(Array{Real,3},YTArray);
                    data_source=nothing, args...)
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
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        reg = ds.ds[:region](c, le, re; data_source=source, args...)
        new(reg, ds, YTArray(reg["center"]), YTArray(reg["left_edge"]),
            YTArray(reg["right_edge"]), Dict())
    end
end

# Disk

type Disk <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    normal::Array{Real,3}
    field_dict::Dict
    function Disk(ds::Dataset, center::Center, normal::Array{Real,3},
                  radius::Length, height::Length; data_source=nothing,
                  args...)
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
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        dk = ds.ds[:disk](c, normal, r, h; data_source=source, args...)
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
    function Ray(ds::Dataset, start_point::Array{Real,3},
                 end_point::Array{Real,3}; data_source=nothing, args...)
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        ray = ds.ds[:ray](start_point, end_point; data_source=source, args...)
        new(ray, ds, YTArray(ray["start_point"]),
            YTArray(ray["end_point"]), Dict())
    end
end

# Cutting

type Cutting <: DataContainer
    cont::PyObject
    ds::Dataset
    normal::Array{Real,3}
    center::YTArray
    field_dict::Dict
    function Cutting(ds::Dataset, normal::Array{Real,3},
                     center::Center; data_source=nothing, args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        cutting = ds.ds[:cutting](normal, c; data_source=source, args...)
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
        new(prj, ds, field, prj["axis"], weight_field, Dict())
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
                   coord::Real; data_source=nothing, args...)
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        slc = ds.ds[:slice](axis, coord; data_source=source, args...)
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
    function Sphere(ds::Dataset, center::Center, radius::Length;
                    data_source=nothing, args...)
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
        if data_source != nothing
            source = data_source.cont
        else
            source = nothing
        end
        sp = ds.ds[:sphere](c, r; data_source=source, args...)
        new(sp, ds, YTArray(sp["center"]),
            YTQuantity(sp["radius"]), Dict())
    end
end

# CutRegion

type CutRegion <: DataContainer
    cont::PyObject
    ds::Dataset
    conditions::Array{String}
    field_dict::Dict
    function CutRegion(dc::DataContainer, conditions::Array{String}; args...)
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
    active_dimensions::Array{Integer,3}
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
    active_dimensions::Array{Integer,3}
    field_dict::Dict
    function CoveringGrid(ds::Dataset, level::Integer, left_edge::Array{Real,3},
                          dims::Array{Integer,3}; args...)
        cg = ds.ds[:covering_grid](level, left_edge, dims; args...)
        new(cg, ds, YTArray(cg["left_edge"]), YTArray(cg["right_edge"]),
            level, cg[:ActiveDimensions], Dict())
    end
end

# Quantities

isinstance = pybuiltin("isinstance")
PyTuple = pybuiltin("tuple")
PyList = pybuiltin("list")

function quantities(dc::DataContainer, key::String, args...)
    q = pycall(dc.cont["quantities"]["__getitem__"], PyObject, key)
    a = pycall(q["__call__"], PyObject, args...)
    if pycall(isinstance, PyAny, a, PyTuple) || pycall(isinstance, PyAny, a, PyList)
        n = a[:__len__]()
        return [array_or_quan(pycall(a["__getitem__"], PyObject, i))
                for i in 0:n-1]
    else
        return array_or_quan(a)
    end
end

function list_quantities(dc::DataContainer)
    dc.cont["quantities"][:keys]()
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

function getindex(grids::Grids, i::Integer)
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
