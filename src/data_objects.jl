module data_objects

using PyCall
import Base: size, show
import ..array: YTArray, YTQuantity
import ..utils: Axis, RealOrArray, Length, StringOrArray, Field
import ..images: FixedResolutionBuffer

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

# Region

type Region <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    left_edge::YTArray
    right_edge::YTArray
    field_dict::Dict
    function Region(ds::Dataset, center::Union(StringOrArray,YTArray),
                    left_edge::AbstractArray, right_edge::AbstractArray; args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(left_edge) == YTArray
            le = convert(PyObject, left_edge)
        else
            le = left_edge
        end
        if typeof(right_edge) == YTArray
            re = convert(PyObject, right_edge)
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
    function Disk(ds::Dataset, center::Union(StringOrArray,YTArray), normal::Array,
                  radius::Union(Length,YTQuantity),
                  height::Union(Length,YTQuantity); args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(radius) == YTQuantity
            r = radius.ytquantity
        else
            r = radius
        end
        if typeof(height) == YTQuantity
            h = height.ytquantity
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
    function Ray(ds::Dataset, start_point::AbstractArray,
                 end_point::AbstractArray; args...)
        if typeof(start_point) == YTArray
            sp = convert(PyObject, start_point)
        else
            sp = start_point
        end
        if typeof(end_point) == YTArray
            ep = convert(PyObject, end_point)
        else
            ep = end_point
        end
        ray = ds.ds[:ray](sp, ep; args...)
        new(ray, ds, YTArray(ray["start_point"]),
            YTArray(ray["end_point"]), Dict())
    end
end

# CuttingPlane

type CuttingPlane <: DataContainer
    cont::PyObject
    ds::Dataset
    normal::Array
    center::StringOrArray
    field_dict::Dict
    function CuttingPlane(ds::Dataset, normal::Array,
                          center::Union(StringOrArray,YTArray); args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        cutting = ds.ds[:cutting](normal, c; args...)
        new(cutting, ds, normal, center, Dict())
    end
end

# Projection

type Projection <: DataContainer
    cont::PyObject
    ds::Dataset
    field::String
    axis::Axis
    weight_field
    center
    data_source
    field_dict::Dict
    function Projection(ds::Dataset, field::String, axis::Axis; weight_field=nothing,
                        center=nothing, data_source=nothing, args...)
        if weight_field != nothing
            weight = weight_field
        else
            weight = pybuiltin("None")
        end
        if center == nothing
            c = pybuiltin("None")
        elseif typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = nothing
        end
        if data_source != nothing
            source = data_source.cont
        else
            source = pybuiltin("None")
        end
        prj = ds.ds[:proj](field, axis, weight_field=weight, center=c,
                           data_source=source; args...)
        new(prj, ds, field, axis, weight_field, center,
            data_source, Dict())
    end
end

# Slice

type Slice <: DataContainer
    cont::PyObject
    ds::Dataset
    axis::Axis
    center
    field_dict::Dict
    function Slice(ds::Dataset, axis::Axis, coord::Union(RealOrArray,YTQuantity,YTArray);
                   center=nothing, args...)
        if typeof(coord) == YTArray
            cd = convert(PyObject, coord)
        elseif typeof(coord) == YTQuantity
            cd = coord.quantity
        else
            cd = coord
        end
        if center == nothing
            c = pybuiltin("None")
        elseif typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        slc = ds.ds[:slice](axis, cd, center=c; args...)
        new(slc, ds, axis, center, Dict())
    end
end

SliceOrProj = Union(Slice,Projection)
Resolution = Union(Integer,(Integer,Integer))

function to_frb(obj::SliceOrProj, width::Length, nx::Resolution; args...)
    FixedResolutionBuffer(obj.cont[:to_frb](width, nx; args...))
end

# Sphere

type Sphere <: DataContainer
    cont::PyObject
    ds::Dataset
    center::YTArray
    radius::YTQuantity
    field_dict::Dict
    function Sphere(ds::Dataset, center::Union(StringOrArray,YTArray),
                    radius::Union(Length,YTQuantity); args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        if typeof(radius) == YTQuantity
            r = radius.ytquantity
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
end

function cut_region(dc::DataContainer, conditions::Array)
    cut_reg = dc.cont[:cut_region](conditions)
    CutRegion(cut_reg, dc.ds, conditions, Dict())
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
    dc.cont[:set_field_parameter](key, value)
end

function has_field_parameter(dc::DataContainer, key::String)
    dc.cont[:has_field_parameter](key)
end

function get_field_parameter(dc::DataContainer, key::String)
    dc.cont[:get_field_parameter](key)
end

# Indices

function getindex(dc::DataContainer, key::Field)
    if !haskey(dc.field_dict, key)
        dc.field_dict[key] = YTArray(get(dc.cont, PyObject, key))
        dc.cont[:__delitem__](key)
    end
    return dc.field_dict[key]
end

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

function show(io::IO, grids::Grids)
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

end
