module yt_array

import Base: cbrt, convert, copy, eltype, hypot, maximum, minimum, ndims,
             similar, show, size, sqrt, exp, log, log10, sin, cos, tan,
             expm1, log2, log1p, sinh, cosh, tanh, csc, sec, cot, csch,
             sinh, coth, sinpi, cospi, abs, abs2, asin, acos, atan

using SymPy
using PyCall
#@pyimport yt
import ..utils: pyslice, IntOrRange, RealOrArray
import jt: yt

# Grab the classes for creating YTArrays and YTQuantities

ytarray_new = yt.units["yt_array"]["YTArray"]
ytquantity_new = yt.units["yt_array"]["YTQuantity"]

# YTQuantity definition

type YTQuantity
    ytquantity::PyObject
    value::Real
    units::Sym
    dimensions::String
    function YTQuantity(ytquantity::PyObject)
        new(ytquantity, ytquantity[:ndarray_view]()[1],
            ytquantity[:units], ytquantity[:units][:dimensions][:__str__]())
    end
    function YTQuantity(value::Real, units::String)
        ytquantity = pycall(ytquantity_new, PyObject, value, units)
        new(ytquantity, ytquantity[:ndarray_view]()[1],
            ytquantity[:units], ytquantity[:units][:dimensions][:__str__]())
    end
    YTQuantity(value::Real, units::Sym) = YTQuantity(value, units[:__str__]())
    YTQuantity(value::Real, q::YTQuantity) = YTQuantity(value, q.units)
end

# YTArray definition

type YTArray <: AbstractArray
    array::AbstractArray
    quantity::YTQuantity
    units::Sym
    dimensions::String
    function YTArray(ytarray::PyObject)
        quantity = YTQuantity(1.0, ytarray[:units])
        new(pycall(ytarray["ndarray_view"], PyArray),
            quantity, ytarray[:units], ytarray[:units][:dimensions][:__str__]())
    end
    function YTArray(array::AbstractArray, units::String)
        quantity = YTQuantity(1.0, units)
        new(array, quantity, quantity.units, quantity.units[:dimensions][:__str__]())
    end
    YTArray(array::AbstractArray, units::Sym) = YTArray(array, units[:__str__]())
    YTArray(array::AbstractArray, q::YTQuantity) = YTArray(array, q.units)
end

YTObject = Union(YTArray,YTQuantity)

# Macros

macro array_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            return YTArray(($op)(get_array($a),in_units($b,($a.units)).array), ($a.units))
        else
            error("Not in the same dimensions!")
        end
    end
end

macro quantity_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            return YTQuantity(($op)(($a.value),in_units($b,($a.units)).value), ($a.units))
        else
            error("Not in the same dimensions!")
        end
    end
end

macro arr_quan_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            return YTArray(($op)(get_array($a),in_units($b,($a.units)).value), ($a.units))
        else
            error("Not in the same dimensions!")
        end
    end
end

# Helper functions
function get_array(a::YTArray)
    if typeof(a.array) <: PyArray
        return copy(a.array)
    else
        return a.array
    end
end

# Copy

copy(q::YTQuantity) = YTQuantity(q.value, q)
copy(a::YTArray) = YTArray(get_array(a), a.units)

# Conversions

convert(::Type{YTArray}, o::PyObject) = YTArray(o)
convert(::Type{YTQuantity}, o::PyObject) = YTQuantity(o)
convert(::Type{Array}, a::YTArray) = get_array(a)
convert(::Type{Real}, q::YTQuantity) = q.value
convert(::Type{PyObject}, a::YTArray) = pycall(ytarray_new, PyObject, a.array, a.units[:__str__]())
convert(::Type{PyObject}, a::YTQuantity) = pycall(ytquantity_new, PyObject, a.value, a.units[:__str__]())

# Indexing, ranges (slicing)

getindex(a::YTArray, i::Int) = YTQuantity(a.array[i], a.units)
# Hack to PyArray to conserve memory
getindex(a::PyArray, idxs::Ranges) = pycall(a.o["__getitem__"], PyArray, pyslice(idxs))
getindex(a::YTArray, idxs::Ranges) = YTArray(getindex(a.array, idxs), a.units)

function setindex!(a::YTArray, x::Real, i::Int)
    a.array[i] = x
end
# Hack to PyArray to conserve memory
function setindex!(a::PyArray, x::RealOrArray, idxs::Ranges)
    pycall(a.o["__setitem__"], PyArray, pyslice(idxs), x)
end
function setindex!(a::YTArray, x::RealOrArray, idxs::Ranges)
    YTArray(setindex!(a.array, x, idxs), a.units)
end

# For grids
# Hack to PyArray to conserve memory
function getindex(a::PyArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    pycall(a.o["__getitem__"], PyArray, (pyslice(i), pyslice(j), pyslice(k),))
end
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    num_items = length(i)*length(j)*length(k)
    if num_items == 1
        return YTQuantity(getindex(a.array, i, j, k), a.units)
    else
        return YTArray(getindex(a.array, i, j, k), a.units)
    end
end

# For images
# Hack to PyArray to conserve memory
function getindex(a::PyArray, i::Integer, j::Ranges)
    pycall(a.o["__getitem__"], PyArray, (i-1, pyslice(j),))
end
function getindex(a::PyArray, i::Ranges, j::Integer)
    pycall(a.o["__getitem__"], PyArray, (pyslice(i), j-1,))
end
function getindex(a::PyArray, i::Ranges, j::Ranges)
    pycall(a.o["__getitem__"], PyArray, (pyslice(i), pyslice(j),))
end
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange)
    num_items = length(i)*length(j)
    if num_items == 1
        return YTQuantity(getindex(a.array, i, j), a.units)
    else
        return YTArray(getindex(a.array, i, j), a.units)
    end
end

# Unit conversions

function in_units(q::YTQuantity, units::String)
    YTQuantity(pycall(q.ytquantity["in_units"], PyObject, units))
end
in_units(q::YTQuantity, units::Sym) = in_units(q, units[:__str__]())
in_units(q::YTQuantity, p::YTQuantity) = in_units(q, p.units)

function in_cgs(q::YTQuantity)
    pycall(q.ytquantity["in_cgs"], YTQuantity)
end

function in_units(a::YTArray, units::String)
    q = in_units(a.quantity, units)
    YTArray(get_array(a)*q.value, q.units)
end
in_units(a::YTArray, units::Sym) = in_units(a, units[:__str__]())
in_units(a::YTArray, b::YTQuantity) = in_units(a, b.units)
in_units(a::YTArray, b::YTArray) = in_units(a, b.units)

function in_cgs(a::YTArray)
    q = in_cgs(a.quantity)
    YTArray(get_array(a)*q.value, q.units)
end

# Arithmetic and comparisons

# YTQuantity

for op = (:+, :-, :hypot, :(==), :(!=), :(>=), :(<=), :<, :>)
    @eval ($op)(a::YTQuantity,b::YTQuantity) = @quantity_same_units(a,b,($op))
end

-(a::YTQuantity) = YTQuantity(-a.value, a.units)

function *(a::YTQuantity, b::YTQuantity)
    same_dims = a.dimensions == b.dimensions
    if same_dims
        c = a.value*in_units(b, a).value
        units = a.units*a.units
    else
        c = a.value*b.value
        units = a.units*b.units
    end
    return YTQuantity(c, units)
end

*(a::YTQuantity, b::Real) = YTQuantity(b*a.value, a.units)
*(a::Real, b::YTQuantity) = *(b, a)
/(a::YTQuantity, b::Real) = *(a, 1.0/b)
\(a::YTQuantity, b::Real) = /(b,a)

/(a::Real, b::YTQuantity) = YTQuantity(a/b.value, "1/\($(b.units[:__str__]())\)")

\(a::Real, b::YTQuantity) = /(b,a)

^(a::YTQuantity, b::Integer) = YTQuantity(a.value^b, a.units^b)
^(a::YTQuantity, b::Real) = YTQuantity(a.value^b, a.units^b)

/(a::YTQuantity, b::YTQuantity) = *(a,1.0/b)
\(a::YTQuantity, b::YTQuantity) = /(b,a)

# YTQuantities and Arrays

*(a::YTQuantity, b::Array) = YTArray(b*a.value, a.units)
*(a::Array, b::YTQuantity) = *(b, a)
/(a::YTQuantity, b::Array) = *(a, 1.0/b)
/(a::Array, b::YTQuantity) = *(a, 1.0/b)
\(a::YTQuantity, b::Array) = /(b,a)
\(a::Array, b::YTQuantity) = /(b,a)

*(a::YTQuantity, b::PyArray) = YTArray(copy(b)*a.value, a.units)
*(a::PyArray, b::YTQuantity) = *(b, a)
/(a::YTQuantity, b::PyArray) = *(a, 1.0/b)
/(a::PyArray, b::YTQuantity) = *(a, 1.0/b)
\(a::YTQuantity, b::PyArray) = /(b,a)
\(a::PyArray, b::YTQuantity) = /(b,a)

# YTArray next

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTArray) = @array_same_units(a,b,($op))
end

-(a::YTArray) = YTArray(-a.array, a.units)

function .*(a::YTArray, b::YTArray)
    same_dims = a.dimensions == b.dimensions
    if same_dims
        c = get_array(a).*in_units(b, a.units).array
        units = a.units*a.units
    else
        c = get_array(a).*get_array(b)
        units = a.units*b.units
    end
    return YTArray(c, units)
end

# YTArrays and Reals

*(a::YTArray, b::Real) = YTArray(b*get_array(a), a.units)
*(a::Real, b::YTArray) = *(b, a)
/(a::YTArray, b::Real) = *(a, 1.0/b)
\(a::YTArray, b::Real) = /(b,a)

/(a::Real, b::YTArray) = YTArray(a/get_array(b), 1.0/b.quantity)
\(a::Real, b::YTArray) = /(b,a)

./(a::YTArray, b::YTArray) = .*(a,1.0/b)
.\(a::YTArray, b::YTArray) = ./(b, a)

# YTArrays and Arrays

.*(a::YTArray, b::Array) = YTArray(b.*get_array(a), a.units)
.*(a::Array, b::YTArray) = .*(b, a)
./(a::YTArray, b::Array) = .*(a, 1.0/b)
./(a::Array, b::YTArray) = .*(a, 1.0/b)
.\(a::YTArray, b::Array) = ./(b, a)
.\(a::Array, b::YTArray) = ./(b, a)

.^(a::YTArray, b::Real) = YTArray(get_array(a).^b, a.units^b)

# YTArrays and YTQuantities

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTQuantity) = @arr_quan_same_units(a,b,($op))
end

+(a::YTQuantity, b::YTArray) = +(b,a)
-(a::YTQuantity, b::YTArray) = -(-(b,a))

function *(a::YTQuantity, b::YTArray)
    same_dims = a.dimensions == b.dimensions
    if same_dims
        c = a.value*in_units(b, a.units).array
        units = a.units*a.units
    else
        c = a.value*get_array(b)
        units = a.units*b.units
    end
    return YTArray(c, units)
end

*(a::YTArray, b::YTQuantity) = *(b,a)
/(a::YTArray, b::YTQuantity) = *(a, 1.0/b)
/(a::YTQuantity, b::YTArray) = *(a, 1.0/b)
\(a::YTArray, b::YTQuantity) = /(b,a)
\(a::YTQuantity, b::YTArray) = /(b,a)

.==(a::YTQuantity, b::YTArray) = .==(b,a)
.!=(a::YTQuantity, b::YTArray) = .!=(b,a)
.>=(a::YTQuantity, b::YTArray) = .<=(b,a)
.<=(a::YTQuantity, b::YTArray) = .>=(b,a)
.>(a::YTQuantity, b::YTArray) = .<(b,a)
.<(a::YTQuantity, b::YTArray) = .>(b,a)

# Mathematical functions

sqrt(a::YTQuantity) = YTQuantity(sqrt(a.value), "sqrt\($(a.units[:__str__]())\)")
sqrt(a::YTArray) = YTArray(sqrt(a.array), "sqrt\($(a.units[:__str__]())\)")

cbrt(a::YTQuantity) = YTQuantity(cbrt(a.value), (a.units)^(1/3))
cbrt(a::YTArray) = YTArray(cbrt(a.array), (a.units)^(1/3))

maximum(a::YTArray) = YTQuantity(maximum(a.array), a.units)
minimum(a::YTArray) = YTQuantity(minimum(a.array), a.units)

hypot(a::YTArray, b::YTArray, c::YTArray) = hypot(hypot(a,b), c)
hypot(a::YTQuantity, b::YTQuantity, c::YTQuantity) = hypot(hypot(a,b), c)

abs(a::YTArray) = YTArray(abs(a.array), a.units)
abs(q::YTQuantity) = YTQuantity(abs(q.value), q.units)
abs2(a::YTArray) = YTArray(abs2(a.array), a.units*a.units)
abs2(q::YTQuantity) = YTQuantity(abs2(q.value), q.units*q.units)

for op = (:exp, :log, :log2, :log10, :log1p, :expm1,
          :sin, :cos, :tan, :sec, :csc, :cot, :sinh,
          :cosh, :tanh, :coth, :sech, :csch, :sinpi,
          :cospi, :asin, :acos, :atan)
    @eval ($op)(a::YTArray) = ($op)(a.array)
    @eval ($op)(q::YTQuantity) = ($op)(q.value)
end

# Show

function show_helper1d(io::IO, a::AbstractArray)
    num_cells = length(a)
    n = num_cells > 6 ? 4 : num_cells
    print(io, "[ $(a[1]),")
    for x in a[2:n-1]
        print(io, " $(x),")
    end
    if num_cells > 6
        println(io, "  ...")
        print(io, "\t")
        for x in a[num_cells-2:num_cells-1]
            print(io, " $x,")
        end
    end
    print(io, " $(a[end]) ]")
end

function show_helper2d(io::IO, a::AbstractArray)
    nx,ny = size(a)
    print(io, "[")
    show_helper1d(io, a[1,:])
    println(io, ",")
    n = nx > 6 ? 4 : nx
    for i in 2:n-1
        print(io, "   ")
        show_helper1d(io, a[i,:])
        println(io, ",")
    end
    if nx > 6
        println(io,"   ...")
        for i in n-2:n-1
            print(io, "   ")
            show_helper1d(io, a[i,:])
            println(io, ",")
        end
    end
    print(io, "   ")
    show_helper1d(io, a[end,:])
    print(io, "]")
end

function show_helper3d(io::IO, a::AbstractArray)
    nx,ny,nz = size(a)
    print(io, "[")
    show_helper2d(io, a[1,:,:])
    println(io, ",")
    n = nx > 6 ? 4 : nx
    for i in 2:n-1
        print(io, "   ")
        show_helper2d(io, a[i,:,:])
        println(io, ",")
    end
    if nx > 6
        println(io,"   ...")
        for i in n-2:n-1
            print(io, "   ")
            show_helper2d(io, a[i,:,:])
            println(io, ",")
        end
    end
    print(io, "   ")
    show_helper2d(io, a[end,:,:])
    print(io, "]")
end

function show(io::IO, a::YTArray)
    num_cells = length(a)
    if num_cells == 0
        println(io, "YTArray [] $(a.units)")
        return
    end
    if num_cells == 1
        println(io, "YTArray [ $(a.array[1]) ] $(a.units)")
        return
    end
    nd = ndims(a)
    print(io, "YTArray ")
    if nd == 1
        show_helper1d(io, a.array)
    elseif nd == 2
        show_helper2d(io, a.array)
    elseif nd == 3
        show_helper3d(io, a.array)
    end
    print(io, " $(a.units)")
end

show(io::IO, q::YTQuantity) = print(io,"$(q.value) $(q.units)")

# Array methods

size(a::YTArray) = size(a.array)
size(a::YTArray, n::Integer) = size(a.array, n)

ndims(a::YTArray) = ndims(a.array)

eltype(a::YTArray) = eltype(a.array)

end
