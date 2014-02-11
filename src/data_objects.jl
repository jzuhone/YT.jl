module data_objects

using PyCall
import Base: size, show
import ..yt_array: YTArray, YTQuantity
import ..utils: pyslice, Axis, RealOrArray, Length, StringOrArray
import ..images: FixedResolutionBuffer
import jt: yt

# Dataset

type DataSet
    ds::PyObject
    h::PyObject
    parameters::PyDict
    domain_center::YTArray
    domain_left_edge::YTArray
    domain_right_edge::YTArray
    domain_width::YTArray
    domain_dimensions::Array
    dimensionality::Integer
    current_time::YTQuantity
    current_redshift::Real
    field_list::Array
    derived_field_list::Array
    max_level::Integer
    function DataSet(ds::PyObject)
        new(ds, ds[:h],
            PyDict(ds[:h]["parameters"]::PyObject),
            YTArray(ds["domain_center"]),
            YTArray(ds["domain_left_edge"]),
            YTArray(ds["domain_right_edge"]),
            YTArray(ds["domain_width"]),
            ds[:domain_dimensions],
            ds[:dimensionality][1],
            YTQuantity(ds["current_time"]),
            ds[:current_redshift],
            ds[:h][:field_list],
            ds[:h][:derived_field_list],
            ds[:h][:max_level][1])
    end
end

function get_smallest_dx(ds::DataSet)
    pycall(ds.h["get_smallest_dx"], YTArray)[1]
end

function print_stats(ds::DataSet)
    ds.h[:print_stats]()
end

# Data containers

abstract DataContainer

# All Data

type AllData <: DataContainer
    cont::PyObject
    ds::DataSet
    function AllData(ds::DataSet; args...)
        new(ds.h[:all_data](args...))
    end
end

# Region

type Region <: DataContainer
    cont::PyObject
    ds::DataSet
    center::YTArray
    left_edge::YTArray
    right_edge::YTArray
    function Region(ds::DataSet, center::Union(StringOrArray,YTArray),
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
        reg = ds.h[:region](c, le, re; args...)
        new(reg, ds, YTArray(reg["center"]), YTArray(reg["left_edge"]),
            YTArray(reg["right_edge"]))
    end
end

# Disk

type Disk <: DataContainer
    cont::PyObject
    ds::DataSet
    center::YTArray
    normal::Array
    radius::YTQuantity
    height::YTQuantity
    function Disk(ds::DataSet, center::Union(StringOrArray,YTArray), normal::Array,
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
        dk = ds.h[:disk](c, normal, r, h; args...)
        new(dk, ds, YTArray(dk["center"]), normal, YTQuantity(sp["radius"]),
            YTQuantity(dk["height"]))
    end
end

# Ray

type Ray <: DataContainer
    cont::PyObject
    ds::DataSet
    start_point::YTArray
    end_point::YTArray
    function Ray(ds::DataSet, start_point::AbstractArray,
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
        ray = ds.h[:ray](sp, ep; args...)
        new(ray, ds, YTArray(ray["start_point"]), YTArray(ray["end_point"]))
    end
end

# Boolean

type Boolean <: DataContainer
    cont::PyObject
    ds::DataSet
    regions::Array
    function Boolean(ds::DataSet, regions::Array; args...)
        regs = [region.cont for region in regions]
        bool_reg = ds.h[:boolean](regs; args...)
        new(bool_reg, ds, regions)
    end
end

# CuttingPlane

type CuttingPlane <: DataContainer
    cont::PyObject
    ds::DataSet
    normal::Array
    center::StringOrArray
    function CuttingPlane(ds::DataSet, normal::Array,
                          center::Union(StringOrArray,YTArray); args...)
        if typeof(center) == YTArray
            c = convert(PyObject, center)
        else
            c = center
        end
        cutting = ds.h[:cutting](normal, c; args...)
        new(cutting, ds, normal, center)
    end
end

# Projection

type Projection <: DataContainer
    cont::PyObject
    ds::DataSet
    field::String
    axis::Axis
    weight_field
    center
    data_source
    function Projection(ds::DataSet, field::String, axis::Axis; weight_field=nothing,
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
        prj = pf.h[:proj](field, axis, weight_field=weight, center=c,
                          data_source=source; args...)
        new(prj, ds, field, axis, weight_field, center, data_source)
    end
end

# Slice

type Slice <: DataContainer
    cont::PyObject
    ds::DataSet
    axis::Axis
    center
    function Slice(ds::DataSet, axis::Axis, coord::Union(RealOrArray,YTQuantity,YTArray);
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
        slc = ds.h[:slice](axis, cd, center=c; args...)
        new(slc, ds, axis, center)
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
    ds::DataSet
    center::YTArray
    radius::YTQuantity
    function Sphere(ds::DataSet, center::Union(StringOrArray,YTArray),
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
        sp = ds.h[:sphere](c, r; args...)
        new(sp, ds, YTArray(sp["center"]), YTQuantity(sp["radius"]))
    end
end

# CutRegion

type CutRegion <: DataContainer
    cont::PyObject
    ds::DataSet
    conditions::Array
end

function cut_region(dc::DataContainer, conditions::Array)
    cut_reg = dc.cont[:cut_region](conditions)
    CutRegion(cut_reg, dc.ds, conditions)
end

# Grids

type Grids <: AbstractArray
    grids::Array
    function Grids(ds::DataSet)
        new(ds.h[:grids])
    end
    function Grids(grid_array::Array)
        new(grid_array)
    end
    function Grids(grid::PyObject)
        new([grid])
    end
    function Grids(nothing)
        new([])
    end
end

size(grids::Grids) = size(grids.grids)

# Grid

type Grid <: DataContainer
    cont::PyObject
    left_edge::YTArray
    right_edge::YTArray
    level::Integer
    number_of_particles::Integer
    active_dimensions::Array
    Parent::Grids
    Children::Grids
end

# GridCollection

type GridCollection <: DataContainer
    cont::PyObject
    ds::DataSet
    center::Array
    function GridCollection(ds::DataSet, center::Array, grid_list::Grids; args...)
        gds = ds.h[:grid_collection](center, grid_list.grids; args...)
        new(gds, center)
    end
end

# CoveringGrid

type CoveringGrid <: DataContainer
    cont::PyObject
    ds::DataSet
    left_edge::YTArray
    right_edge::YTArray
    level::Integer
    active_dimensions::Array
    function CoveringGrid(ds::DataSet, level::Integer, left_edge::Array,
                          dims::Array; args...)
        cg = ds.h[:covering_grid](level, left_edge, dims; args...)
        new(cg, ds, YTArray(cg["left_edge"]), YTArray(cg["right_edge"]),
            level, cg[:ActiveDimensions])
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

function getindex(dc::DataContainer, key::String)
    YTArray(get(dc.cont, PyObject, key))
end

function getindex(dc::DataContainer, ftype::String, fname::String)
    YTArray(get(dc.cont, PyObject, (ftype,fname)))
end

function getindex(grids::Grids, i::Int)
    g = grids.grids[i]
    Grid(g,
         YTArray(g["LeftEdge"]),
         YTArray(g["RightEdge"]),
         g[:Level][1],
         g[:NumberOfParticles][1],
         g[:ActiveDimensions],
         Grids(g[:Parent]),
         Grids(g[:Children]))
end

getindex(grids::Grids, idxs::Ranges) = Grids(grids.grids[idxs])

# Show

show(io::IO, ds::DataSet) = print(io,ds.ds[:__repr__]())
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
