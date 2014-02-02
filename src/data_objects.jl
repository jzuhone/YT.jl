module data_objects

using PyCall
@pyimport yt
import Base: size, show
import ..yt_array: YTArray, YTQuantity
import ..utils: pyslice, Axis, RealOrArray
import ..images: FixedResolutionBuffer

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

    function Region(ds::DataSet, center::Array, left_edge::Array,
                    right_edge::Array; args...)
        reg = ds.h[:region](center, left_edge, right_edge; args...)
        new(reg, ds, YTArray(reg["center"]), YTArray(reg["left_edge"]),
            YTArray(reg["right_edge"]))
    end
    function Region(ds::DataSet, center::String, left_edge::Array,
                    right_edge::Array; args...)
        reg = ds.h[:region](center, left_edge, right_edge; args...)
        new(reg, ds, YTArray(reg["center"]), YTArray(reg["left_edge"]),
            YTArray(reg["right_edge"]))
    end

end

# Disk

# Ray

# Boolean

# CuttingPlane

# FieldCuts

# Projection

type Projection <: DataContainer
    cont::PyObject
    ds::DataSet
    field::String
    axis::Axis
    weight_field
    center
    data_source
    function Projection(ds::DataSet, field::String, axis::Axis, weight_field=nothing,
                        center=nothing, data_source=nothing; args...)
        if weight_field != nothing
            weight = weight_field
        else
            weight = pybuiltin("None")
        end
        if center != nothing
            c = center
        else
            c = pybuiltin("None")
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
    function Slice(ds::DataSet, axis::Axis, coord::RealOrArray, center=nothing; args...)
        if center != nothing
            c = center
        else
            c = pybuiltin("None")
        end
        slc = ds.h[:slice](axis, coord, center=c; args...)
        new(slc, ds, axis, center)
    end
end

SliceOrProj = Union(Slice,Projection)
Resolution = Union(Integer,(Integer,Integer))

function to_frb(obj::SliceOrProj, width::(Real,String), nx::Resolution; args...)
    FixedResolutionBuffer(obj.cont[:to_frb](width, nx; args...))
end

# Sphere

type Sphere <: DataContainer
    cont::PyObject
    ds::DataSet
    center::YTArray
    radius::YTQuantity

    function Sphere(ds::DataSet, center::String, radius::Real; args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, YTArray(sp["center"]), YTQuantity(sp["radius"]))
    end
    function Sphere(ds::DataSet, center::String, radius::(Real,String); args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, YTArray(sp["center"]), YTQuantity(sp["radius"]))
    end
    function Sphere(ds::DataSet, center::Array, radius::(Real,String); args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, YTArray(sp["center"]), YTQuantity(sp["radius"]))
    end
    function sphere(ds::DataSet, center::Array, radius::Real; args...)
        sp = ds.h[:sphere](center, radius; args...)
        new(sp, ds, YTArray(sp["center"]), YTQuantity(sp["radius"]))
    end
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

function getindex(grids::Grids, idxs::Ranges)
    Grids(grids.grids[idxs])
end

# Show

function show(io::IO, ds::DataSet)
    print(io,ds.ds[:__repr__]())
end

function show(io::IO, dc::DataContainer)
    print(io,dc.cont[:__repr__]())
end

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
