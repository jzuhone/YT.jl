module array

import Base: cbrt, convert, copy, eltype, hypot, maximum, minimum, ndims,
             show, size, sqrt, exp, log, log10, sin, cos, tan,
             expm1, log2, log1p, sinh, cosh, tanh, csc, sec, cot, csch,
             sinh, coth, sinpi, cospi, abs, abs2, asin, acos, atan, sum,
             cumsum, cummin, cummax, cumsum_kbn, diff, display, print,
             showarray, showerror

import SymPy: Sym
using PyCall
import ..utils: IntOrRange, RealOrArray
@pyimport yt.units as units

# Grab the classes for creating YTArrays and YTQuantities

bare_array = units.yt_array["YTArray"]
bare_quan = units.yt_array["YTQuantity"]

# YTQuantity definition

type YTQuantity
    yt_quantity::PyObject
    value::Real
    units::Sym
    dimensions::String
    function YTQuantity(yt_quantity::PyObject)
        new(yt_quantity, yt_quantity[:ndarray_view]()[1],
            yt_quantity[:units], yt_quantity[:units][:dimensions][:__str__]())
    end
    function YTQuantity(value::Real, units::String)
        yt_quantity = pycall(bare_quan, PyObject, value, units)
        new(yt_quantity, yt_quantity[:ndarray_view]()[1],
            yt_quantity[:units], yt_quantity[:units][:dimensions][:__str__]())
    end
    function YTQuantity(ds, value::Real, units::String)
        yt_quantity = pycall(ds.ds["quan"], PyObject, value, units)
        new(yt_quantity, yt_quantity[:ndarray_view]()[1],
            yt_quantity[:units], yt_quantity[:units][:dimensions][:__str__]())
    end
    YTQuantity(value::Real, units::Sym) = YTQuantity(value, units[:__str__]())
    YTQuantity(value::Real, q::YTQuantity) = YTQuantity(value, q.units)
end

# YTArray definition

type YTArray <: AbstractArray
    array::Array
    unit_quantity::YTQuantity
    units::Sym
    dimensions::String
    function YTArray(yt_array::PyObject)
        unit_quantity = YTQuantity(yt_array["unit_quantity"])
        new(yt_array[:ndarray_view](),
            unit_quantity, yt_array[:units], yt_array[:units][:dimensions][:__str__]())
    end
    function YTArray(array::AbstractArray, units::String)
        unit_quantity = YTQuantity(1.0, units)
        new(array, unit_quantity, unit_quantity.units, unit_quantity.units[:dimensions][:__str__]())
    end
    function YTArray(ds, array::AbstractArray, units::String)
        unit_quantity = YTQuantity(ds, 1.0, units)
        new(array, unit_quantity, unit_quantity.units, unit_quantity.units[:dimensions][:__str__]())
    end
    YTArray(array::AbstractArray, units::Sym) = YTArray(array, units[:__str__]())
    YTArray(array::AbstractArray, q::YTQuantity) = YTArray(array, q.units)
end

YTObject = Union(YTArray,YTQuantity)

type YTUnitOperationError <: Exception
    a::YTObject
    b::YTObject
    op::Function
end

function showerror(io::IO, e::YTUnitOperationError)
    print(io,"The $(e.op) operator for YTArrays with units " *
    "($(e.a.units)) and ($(e.b.units)) is not well defined.")
end

# Macros

macro array_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            new_array = ($op)(($a.array),in_units($b,($a.units)).array)
            if iseltype(new_array,Bool)
                return new_array
            else
                return YTArray(new_array, ($a.units))
            end
        else
            throw(YTUnitOperationError($a,$b,$op))
        end
    end
end

macro array_mult_op(a,b,op1,op2)
    quote
        same_dims = ($a.dimensions) == ($b.dimensions)
        if same_dims
            c = ($op1)(($a.array), in_units($b, ($a.units)).array)
            units = ($op2)(($a.units), ($a.units))
        else
            c = ($op1)(($a.array), ($b.array))
            units = ($op2)(($a.units), ($b.units))
        end
        return YTArray(c, units)
    end
end

macro quantity_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            new_value = ($op)(($a.value),in_units($b,($a.units)).value)
            if iseltype(new_value,Bool)
                return new_value
            else
                return YTQuantity(new_value, ($a.units))
            end
        else
            throw(YTUnitOperationError($a,$b,$op))
        end
    end
end

macro quantity_mult_op(a,b,op)
    quote
        same_dims = ($a.dimensions) == ($b.dimensions)
        if same_dims
            c = ($op)(($a.value), in_units($b, ($a.units)).value)
            units = ($op)(($a.units), ($a.units))
        else
            c = ($op)(($a.value), ($b.value))
            units = ($op)(($a.units), ($b.units))
        end
        return YTQuantity(c, units)
    end
end

macro arr_quan_same_units(a,b,op)
    quote
        if ($a.dimensions)==($b.dimensions)
            new_array = ($op)(($a.array),in_units($b,($a.units)).value)
            if iseltype(new_array,Bool)
                return new_array
            else
                return YTArray(new_array, ($a.units))
            end
        else
            throw(YTUnitOperationError($a,$b,$op))
        end
    end
end

macro arr_quan_mult_op(a,b,op)
    quote
        same_dims = ($a.dimensions) == ($b.dimensions)
        if same_dims
            c = ($op)(($a.array), in_units($b, ($a.units)).value)
            units = ($op)(($a.units), ($a.units))
        else
            c = ($op)(($a.array), ($b.value))
            units = ($op)(($a.units), ($b.units))
        end
        return YTArray(c, units)
    end
end

# Copy

copy(q::YTQuantity) = YTQuantity(q.value, q.units)
copy(a::YTArray) = YTArray(a.array, a.units)

# Conversions

convert(::Type{YTArray}, o::PyObject) = YTArray(o)
convert(::Type{YTQuantity}, o::PyObject) = YTQuantity(o)
convert(::Type{Array}, a::YTArray) = a.array
convert(::Type{Real}, q::YTQuantity) = q.value
convert(::Type{PyObject}, a::YTArray) = pycall(bare_array, PyObject, a.array, a.units[:__str__]())
convert(::Type{PyObject}, a::YTQuantity) = pycall(bare_quan, PyObject, a.value, a.units[:__str__]())

# Indexing, ranges (slicing)

getindex(a::YTArray, i::Int) = YTQuantity(a.array[i], a.units)
getindex(a::YTArray, idxs::Array{Int,1}) = YTArray(getindex(a.array, idxs), a.units)
getindex(a::YTArray, idxs::Ranges) = YTArray(getindex(a.array, idxs), a.units)

function setindex!(a::YTArray, x::Real, i::Int)
    a.array[i] = x
end
function setindex!(a::YTArray, x::RealOrArray, idxs::Ranges)
    YTArray(setindex!(a.array, x, idxs), a.units)
end
function setindex!(a::YTArray, x::RealOrArray, idxs::Array{Int,1})
    YTArray(setindex!(a.array, x, idxs), a.units)
end

# For grids
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    num_items = length(i)*length(j)*length(k)
    if num_items == 1
        return YTQuantity(getindex(a.array, i, j, k), a.units)
    else
        return YTArray(getindex(a.array, i, j, k), a.units)
    end
end

# For images
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
    YTQuantity(pycall(q.yt_quantity["in_units"], PyObject, units))
end
in_units(q::YTQuantity, units::Sym) = in_units(q, units[:__str__]())
in_units(q::YTQuantity, p::YTQuantity) = in_units(q, p.units)

function in_cgs(q::YTQuantity)
    pycall(q.yt_quantity["in_cgs"], YTQuantity)
end

function in_units(a::YTArray, units::String)
    q = in_units(a.unit_quantity, units)
    YTArray(a.array*q.value, q.units)
end
in_units(a::YTArray, units::Sym) = in_units(a, units[:__str__]())
in_units(a::YTArray, b::YTQuantity) = in_units(a, b.units)
in_units(a::YTArray, b::YTArray) = in_units(a, b.units)

function in_cgs(a::YTArray)
    q = in_cgs(a.unit_quantity)
    YTArray(a.array*q.value, q.units)
end

# Arithmetic and comparisons

# YTQuantity

for op = (:+, :-, :hypot, :(==), :(!=), :(>=), :(<=), :<, :>)
    @eval ($op)(a::YTQuantity,b::YTQuantity) = @quantity_same_units(a,b,($op))
end

for op = (:*, :/)
    @eval ($op)(a::YTQuantity,b::YTQuantity) = @quantity_mult_op(a,b,($op))
end

-(a::YTQuantity) = YTQuantity(-a.value, a.units)

*(a::YTQuantity, b::Real) = YTQuantity(b*a.value, a.units)
*(a::Real, b::YTQuantity) = *(b, a)
/(a::YTQuantity, b::Real) = *(a, 1.0/b)
\(a::YTQuantity, b::Real) = /(b,a)

/(a::Real, b::YTQuantity) = YTQuantity(a/b.value, "1/\($(b.units[:__str__]())\)")

\(a::Real, b::YTQuantity) = /(b,a)

^(a::YTQuantity, b::Integer) = YTQuantity(a.value^b, a.units^b)
^(a::YTQuantity, b::Real) = YTQuantity(a.value^b, a.units^b)

\(a::YTQuantity, b::YTQuantity) = /(b,a)

# YTQuantities and Arrays

*(a::YTQuantity, b::Array) = YTArray(b*a.value, a.units)
*(a::Array, b::YTQuantity) = *(b, a)
./(a::YTQuantity, b::Array) = *(a, 1.0./b)
/(a::Array, b::YTQuantity) = *(a, 1.0/b)
\(a::YTQuantity, b::Array) = /(b,a)
.\(a::Array, b::YTQuantity) = /(b,a)

# YTArray next

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTArray) = @array_same_units(a,b,($op))
end

for (op1, op2) in zip((:.*, :./),(:*,:/))
    @eval ($op1)(a::YTArray,b::YTArray) = @array_mult_op(a,b,($op1),($op2))
end

-(a::YTArray) = YTArray(-a.array, a.units)

# YTArrays and Reals

*(a::YTArray, b::Real) = YTArray(b*a.array, a.units)
*(a::Real, b::YTArray) = *(b, a)
/(a::YTArray, b::Real) = *(a, 1.0/b)
.\(a::YTArray, b::Real) = ./(b,a)

./(a::Real, b::YTArray) = YTArray(a./b.array, 1.0/b.unit_quantity)
\(a::Real, b::YTArray) = /(b,a)

.\(a::YTArray, b::YTArray) = ./(b, a)

# YTArrays and Arrays

.*(a::YTArray, b::Array) = YTArray(b.*a.array, a.units)
.*(a::Array, b::YTArray) = .*(b, a)
./(a::YTArray, b::Array) = .*(a, 1.0/b)
./(a::Array, b::YTArray) = .*(a, 1.0/b)
.\(a::YTArray, b::Array) = ./(b, a)
.\(a::Array, b::YTArray) = ./(b, a)

.^(a::YTArray, b::Real) = YTArray(a.array.^b, a.units^b)

# YTArrays and YTQuantities

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTQuantity) = @arr_quan_same_units(a,b,($op))
end

for op = (:*, :/)
    @eval ($op)(a::YTArray,b::YTQuantity) = @arr_quan_mult_op(a,b,($op))
end

+(a::YTQuantity, b::YTArray) = +(b,a)
-(a::YTQuantity, b::YTArray) = -(-(b,a))

*(a::YTQuantity, b::YTArray) = *(b,a)
./(a::YTQuantity, b::YTArray) = *(a, 1.0./b)
.\(a::YTArray, b::YTQuantity) = ./(b,a)
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

function showarray(io::IO, a::YTArray; kw...)
    println(io, "$(summary(a)) ($(a.units)):")
    showarray(io, a.array; header=false, limit=true)
end

function print(io::IO, a::YTArray)
    print(io, "$(a.array) $(a.units)")
end

function print(a::YTArray)
    print(STDOUT,a)
end

function print(io::IO, q::YTQuantity)
    print(io, "$(q.value) $(q.units)")
end

function print(q::YTQuantity)
    print(STDOUT,q)
end

display(a::YTArray) = show(STDOUT, a)
show(io::IO, q::YTQuantity) = print(io, "$(q.value) $(q.units)")

# Array methods

size(a::YTArray) = size(a.array)
size(a::YTArray, n::Integer) = size(a.array, n)

ndims(a::YTArray) = ndims(a.array)

eltype(a::YTArray) = eltype(a.array)

sum(a::YTArray) = sum(a.array)*a.unit_quantity
sum(a::YTArray, dims) = sum(a.array, dims)*a.unit_quantity

cumsum(a::YTArray) = cumsum(a.array)*a.unit_quantity
cumsum(a::YTArray, dim::Integer) = cumsum(a.array, dim)*a.unit_quantity

cumsum_kbn(a::YTArray) = cumsum(a.array)*a.unit_quantity
cumsum_kbn(a::YTArray, dim::Integer) = cumsum(a.array, dim)*a.unit_quantity

cummin(a::YTArray) = cummin(a.array)*a.unit_quantity
cummin(a::YTArray, dim::Integer) = cummin(a.array, dim)*a.unit_quantity

cummax(a::YTArray) = cummax(a.array)*a.unit_quantity
cummax(a::YTArray, dim::Integer) = cummax(a.array, dim)*a.unit_quantity

diff(a::YTArray) = diff(a.array)*a.unit_quantity
diff(a::YTArray, dim::Integer) = diff(a.array, dim)*a.unit_quantity

end
