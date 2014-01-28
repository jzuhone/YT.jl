using PyCall
@pyimport yt.mods as ytmods
@pyimport yt
import Base.show

include("array.jl")

# Dataset

type DataSet
    ds::PyObject
    h::PyObject
    parameters::PyDict
    domain_left_edge::YTArray
    domain_right_edge::YTArray
    domain_width::YTArray
    domain_dimensions::Array{Int32,1}
end

# Data containers

abstract DataContainer

# Sphere

type Sphere <: DataContainer
    cont::PyObject
    ds::DataSet
    center
    radius

    function Sphere(ds::DataSet, center::String, radius::Real)
        sp = ds.h[:sphere](center, radius)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function Sphere(ds::DataSet, center::String, radius::(Real,String))
        sp = ds.h[:sphere](center, radius)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function Sphere(ds::DataSet, center::Array, radius::(Real,String))
        sp = ds.h[:sphere](center, radius)
        new(sp, ds, sp[:center], sp[:radius])
    end
    function sphere(ds::DataSet, center::Array, radius::Real)
        sp = ds.h[:sphere](center, radius)
        new(sp, ds, sp[:center], sp[:radius])
    end
end

# Grids

type Grid <: DataContainer
    cont::PyObject
    ds::DataSet
end

type Grids
    grids::Array
    ds::DataSet
    function Grids(ds::DataSet)
        new(ds.h[:grids], ds)
    end
end

# Indices

function getindex(dc::DataContainer, key::String)
    YTArray(get(dc.cont, PyObject, key))
end

function getindex(grids::Grids, i::Int)
    Grid(grids.grids[i], grids.ds)
end

# Show

function show(io::IO, ds::DataSet)
    println(io,ds.ds[:__repr__]())
end

function show(io::IO, dc::DataContainer)
    println(io,dc.cont[:__repr__]())
end

show(io::IO, grids::Grids) = show(io, grids.grids)
