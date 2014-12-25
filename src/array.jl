module array

import Base: convert, copy, eltype, hypot, maximum, minimum, ndims,
             show, size, sqrt, exp, log, log10, sin, cos, tan,
             expm1, log2, log1p, sinh, cosh, tanh, csc, sec, cot, csch,
             sinh, coth, sinpi, cospi, abs, abs2, asin, acos, atan, sum,
             cumsum, cummin, cummax, cumsum_kbn, diff, display, print,
             showarray, showerror, ones, zeros, eye, summary, linspace,
             sum_kbn, gradient, dims2string, mean, std, stdm, var, varm,
             median, middle, midpoints, quantile

import SymPy: Sym
import PyCall: @pyimport, PyObject, pycall, PyArray, pybuiltin, PyAny
@pyimport yt.units as units

if VERSION < v"0.4-"
    import YT: @doc
end

IntOrRange = Union(Integer,Ranges)

# Grab the classes for creating YTArrays and YTQuantities

bare_array = units.yt_array["YTArray"]
bare_quan = units.yt_array["YTQuantity"]

type YTUnit
    yt_unit::PyObject
    unit_symbol::Sym
    dimensions::Sym
end

function *(u::YTUnit, v::YTUnit)
    yt_unit = pycall(u.yt_unit["__mul__"], PyObject, v.yt_unit)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

function /(u::YTUnit, v::YTUnit)
    yt_unit = pycall(u.yt_unit["__div__"], PyObject, v.yt_unit)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

\(u::YTUnit, v::YTUnit) = /(v,u)

function /(u::Real, v::YTUnit)
    yt_unit = pycall(v.yt_unit["__rdiv__"], PyObject, u)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

function ^(u::YTUnit, v::Integer)
    yt_unit = pycall(u.yt_unit["__pow__"], PyObject, v)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

function ^(u::YTUnit, v::Rational)
    yt_unit = pycall(u.yt_unit["__pow__"], PyObject, v)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

function ^(u::YTUnit, v::FloatingPoint)
    yt_unit = pycall(u.yt_unit["__pow__"], PyObject, v)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

function ==(u::YTUnit, v::YTUnit) 
    pycall(u.yt_unit["units"]["__eq__"], PyAny, v.yt_unit["units"])
end

function !=(u::YTUnit, v::YTUnit)
    pycall(u.yt_unit["units"]["__neq__"], PyAny, v.yt_unit["units"])
end

show(io::IO, u::YTUnit) = show(io, u.unit_symbol)

# YTQuantity definition

type YTQuantity{T<:Real}
    value::T
    units::YTUnit
end

function YTQuantity{T<:Real}(value::T, units::String; registry=nothing)
    unitary_quan = pycall(bare_quan, PyObject, 1.0, units, registry)
    yt_units = YTUnit(unitary_quan,
                      unitary_quan[:units],
                      unitary_quan[:units][:dimensions])
    YTQuantity{T}(value, yt_units)
end

YTQuantity{T<:Real}(ds, value::T, units::String) = YTQuantity{T}(value, units,
                                                                 registry=ds.ds["unit_registry"])
YTQuantity{T<:Real}(value::T, units::Sym; registry=nothing) = YTQuantity(value, string(units); 
                                                                         registry=registry)
YTQuantity(value::Bool, units::String) = value
YTQuantity(value::Bool, units::Sym) = value
YTQuantity(value::Bool, units::YTUnit) = value
YTQuantity(value::Bool) = value
YTQuantity{T<:Real}(value::T) = YTQuantity(value, "dimensionless")

function YTQuantity(yt_quantity::PyObject)
    yt_units = YTUnit(yt_quantity["unit_quantity"],
                      yt_quantity[:units],
                      yt_quantity[:units][:dimensions])
    value = yt_quantity[:d][1]
    YTQuantity{typeof(value)}(value, yt_units)
end

# YTArray definition

type YTArray{T<:Real} <: AbstractArray
    value
    units::YTUnit
end

YTArray{T<:Real}(value::Array{T}, units::YTUnit) = YTArray{T}(value, units)
YTArray{T<:Real}(value::PyArray{T}, units::YTUnit) = YTArray{T}(value, units)

function YTArray{T<:Real}(value::Array{T}, units::String; registry=nothing)
    unitary_quan = pycall(bare_quan, PyObject, 1.0, units, registry)
    yt_units = YTUnit(unitary_quan,
                      unitary_quan[:units],
                      unitary_quan[:units][:dimensions])
    YTArray{T}(value, yt_units)
end

function YTArray{T<:Real}(value::PyArray{T}, units::String; registry=nothing)
    unitary_quan = pycall(bare_quan, PyObject, 1.0, units, registry)
    yt_units = YTUnit(unitary_quan,
                      unitary_quan[:units],
                      unitary_quan[:units][:dimensions])
    YTArray{T}(value, yt_units)
end

function YTArray(yt_array::PyObject)
    yt_units = YTUnit(yt_array["unit_quantity"],
                      yt_array[:units],
                      yt_array[:units][:dimensions])
    value = PyArray(yt_array["d"])
    YTArray{eltype(value)}(value, yt_units)
end

YTArray{T<:Real}(ds, value::Array{T}, units::String) = YTArray{T}(value, units, registry=ds.ds["unit_registry"])
YTArray{T<:Real}(value::Array{T}, units::Sym; registry=nothing) = YTArray{T}(value, string(units); registry=registry)
YTArray{T<:Real}(value::PyArray{T}, units::Sym; registry=nothing) = YTArray{T}(value, string(units); registry=registry)

YTArray(value::Real, units::String; registry=nothing) = YTQuantity(value, units; registry=registry)
YTArray(ds, value::Real, units::String) = YTQuantity(value, units, registry=ds.ds["unit_registry"])
YTArray(value::Real, units::Sym; registry=nothing) = YTQuantity(value, units; registry=registry)
YTArray(value::Real, units::YTUnit) = YTQuantity(value, units)

YTArray(value::BitArray, units::String) = value
YTArray(value::BitArray, units::Sym) = value
YTArray(value::BitArray, units::YTUnit) = value

YTArray{T<:Real}(value::Array{T}) = YTArray(value, "dimensionless")
YTArray(value::Real) = YTQuantity(value, "dimensionless")

YTArray(a::Array{YTQuantity}) = YTArray{typeof(a[1].value)}(convert(Array{typeof(a[1].value)},a), a[1].units)

eltype(a::YTArray) = eltype(a.value)

YTObject = Union(YTArray,YTQuantity)

function array_or_quan(a::PyObject)
    x = YTArray(a)
    if length(x) == 1
        return x[1]
    else
        return x
    end
end

type YTUnitOperationError <: Exception
    a::YTObject
    b::YTObject
    op::Function
end

function showerror(io::IO, e::YTUnitOperationError)
    println(io,"The $(e.op) operator for YTArrays with units ")
    print(io,"($(e.a.units)) and ($(e.b.units)) is not well defined.")
end

# Macros

macro array_same_units(a,b,op)
    quote
        if ($a.units.dimensions)==($b.units.dimensions)
            new_array = ($op)(($a.value),in_units($b,($a.units)).value)
            return YTArray(new_array, ($a.units))
        else
            throw(YTUnitOperationError($a,$b,$op))
        end
    end
end

macro array_mult_op(a,b,op1,op2)
    quote
        c = ($op1)(($a.value), ($b.value))
        units = ($op2)(($a.units), ($b.units))
        return YTArray(c, units)
    end
end

# Copy

copy(q::YTQuantity) = YTQuantity(q.value, q.units)
copy(a::YTArray) = YTArray(copy(a.value), a.units)

# Conversions

convert(::Type{YTArray}, o::PyObject) = YTArray(o)
convert(::Type{YTQuantity}, o::PyObject) = YTQuantity(o)
convert(::Type{Array}, a::YTArray) = a.value
convert(::Type{Float64}, q::YTQuantity) = q.value
convert(::Type{PyObject}, a::YTArray) = pycall(bare_array, PyObject, a.value,
                                               string(a.units.unit_symbol),
                                               a.units.yt_unit["units"]["registry"],
                                               dtype=lowercase(string(typeof(a[1].value))))
convert(::Type{PyObject}, a::YTQuantity) = pycall(bare_quan, PyObject, a.value,
                                                  string(a.units.unit_symbol),
                                                  a.units.yt_unit["units"]["registry"],
                                                  dtype=lowercase(string(typeof(a.value))))
convert(::Type{YTArray}, q::YTQuantity) = YTArray([q.value], q.units)
PyObject(a::YTObject) = convert(PyObject, a)

# Indexing, ranges (slicing)

getindex(a::YTArray, i::Integer) = YTQuantity(a.value[i], a.units)
getindex(a::YTArray, idxs::Array{Int,1}) = YTArray(getindex(a.value, idxs), a.units)
getindex(a::YTArray, idxs::Ranges) = YTArray(getindex(a.value, idxs), a.units)

function setindex!(a::YTArray, x::Real, i::Integer)
    a.value[i] = convert(eltype(a), x)
end
function setindex!(a::YTArray, x::Array, idxs::Ranges)
    YTArray(setindex!(a.value, convert(typeof(a.value), x), idxs), a.units)
end
function setindex!(a::YTArray, x::Array, idxs::Array{Int,1})
    YTArray(setindex!(a.value, convert(typeof(a.value), x), idxs), a.units)
end
function setindex!(a::YTArray, x::Real, idxs::Ranges)
    YTArray(setindex!(a.value, convert(eltype(a), x), idxs), a.units)
end
function setindex!(a::YTArray, x::Real, idxs::Array{Int,1})
    YTArray(setindex!(a.value, convert(eltype(a), x), idxs), a.units)
end

pyslice(i::Integer) = i
pyslice(i::UnitRange) = pycall(pybuiltin("slice"), PyObject, i.start-1, i.stop)
pyslice(i::StepRange) = pycall(pybuiltin("slice"), PyObject, i.start-1, i.stop, i.step)
 
# For grids
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    YTArray(getindex(a.value, i, j, k), a.units)
end
function getindex(a::PyArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    ii = pyslice(i)
    jj = pyslice(j)
    kk = pyslice(k)
    get(a.o, PyArray, (ii,jj,kk))
end

# For images
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange)
    YTArray(getindex(a.value, i, j), a.units)
end
function getindex(a::PyArray, i::IntOrRange, j::IntOrRange)
    ii = pyslice(i)
    jj = pyslice(j)
    get(a.o, PyArray, (ii,jj))
end

# Unit conversions


function in_units(a::YTObject, units::String)
    a.value*pycall(a.units.yt_unit["in_units"], YTQuantity, units)
end

function in_cgs(a::YTObject)
    a.value*pycall(a.units.yt_unit["in_cgs"], YTQuantity)
end

function in_mks(a::YTObject)
    a.value*pycall(a.units.yt_unit["in_mks"], YTQuantity)
end

function convert_to_units(a::YTObject, units::String)    
    new_unit = pycall(a.units.yt_unit["in_units"], YTQuantity, units)
    a.value *= new_unit.value
    a.units = new_unit.units
    return
end

function convert_to_cgs(a::YTObject)
    new_unit = pycall(a.units.yt_unit["in_cgs"], YTQuantity)
    a.value *= new_unit.value
    a.units = new_unit.units
    return
end

function convert_to_mks(a::YTObject)
    new_unit = pycall(a.units.yt_unit["in_mks"], YTQuantity)
    a.value *= new_unit.value
    a.units = new_unit.units
    return
end

convert_to_units(a::YTObject, units::Sym) = convert_to_units(a, string(units))
convert_to_units(a::YTObject, units::YTUnit) = convert_to_units(a, units.unit_symbol)
convert_to_units(a::YTObject, b::YTObject) = convert_to_units(a, b.units)

in_units(a::YTObject, units::Sym) = in_units(a, string(units))
in_units(a::YTObject, units::YTUnit) = in_units(a, units.unit_symbol)
in_units(a::YTObject, b::YTObject) = in_units(a, b.units)

# Arithmetic and comparisons

-(a::YTObject) = YTArray(-a.value, a.units)

# YTQuantity

for op = (:+, :-, :hypot, :(==), :(!=), :(>=), :(<=), :<, :>)
    @eval ($op)(a::YTQuantity,b::YTQuantity) = @array_same_units(a,b,($op))
end

for op = (:*, :/)
    @eval ($op)(a::YTQuantity,b::YTQuantity) = @array_mult_op(a,b,($op),($op))
end

*(a::YTQuantity, b::Real) = YTQuantity(b*a.value, a.units)
*(a::Real, b::YTQuantity) = *(b, a)
/(a::YTQuantity, b::Real) = *(a, 1.0/b)
\(a::YTQuantity, b::Real) = /(b,a)

/(a::Real, b::YTQuantity) = YTQuantity(a/b.value, 1/b.units)

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

# Sadly this is necessary
for op = (:+, :-, :*, :.*, :/, :./, :\, :.\, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::PyArray{Float64},b::Real) = ($op)(convert(Array{Float64}, a.o),b)
    @eval ($op)(a::Real,b::PyArray{Float64}) = ($op)(a,convert(Array{Float64}, b.o))
end

for op = (:*, :/, :\) 
    @eval ($op)(a::PyArray{Float64},b::YTQuantity) = ($op)(convert(Array{Float64}, a.o),b)
    @eval ($op)(a::YTQuantity,b::PyArray{Float64}) = ($op)(a,convert(Array{Float64}, b.o))
end

-(a::PyArray) = -1*a

for (op1, op2) in zip((:+, :-),(:.+,:.-))
    @eval ($op1)(a::PyArray,b::PyArray) = ($op2)(a,b)
    @eval ($op1)(a::Array,b::PyArray) = ($op2)(a,b)
    @eval ($op1)(a::PyArray,b::Array) = ($op2)(a,b)
end

# YTArray next

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTArray) = @array_same_units(a,b,($op))
end

for (op1, op2) in zip((:.*, :./),(:*,:/))
    @eval ($op1)(a::YTArray,b::YTArray) = @array_mult_op(a,b,($op1),($op2))
end

# YTArrays and Reals

*(a::YTArray, b::Real) = YTArray(b*a.value, a.units)
*(a::Real, b::YTArray) = *(b, a)
/(a::YTArray, b::Real) = *(a, 1.0/b)
.\(a::YTArray, b::Real) = ./(b,a)

./(a::Real, b::YTArray) = YTArray(a./b.value, 1.0/b.units)
\(a::Real, b::YTArray) = /(b,a)

.\(a::YTArray, b::YTArray) = ./(b, a)

# YTArrays and Arrays

.*(a::YTArray, b::Array) = YTArray(b.*a.value, a.units)
.*(a::Array, b::YTArray) = .*(b, a)
./(a::YTArray, b::Array) = .*(a, 1.0/b)
./(a::Array, b::YTArray) = .*(a, 1.0/b)
.\(a::YTArray, b::Array) = ./(b, a)
.\(a::Array, b::YTArray) = ./(b, a)

.^(a::YTArray, b::Real) = YTArray(a.value.^b, a.units^b)

# YTArrays and YTQuantities

for op = (:+, :-, :hypot, :.==, :.!=, :.>=, :.<=, :.<, :.>)
    @eval ($op)(a::YTArray,b::YTQuantity) = @array_same_units(a,b,($op))
end

for op = (:*, :/)
    @eval ($op)(a::YTArray,b::YTQuantity) = @array_mult_op(a,b,($op),($op))
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

for op = (:+, :-, :hypot)
    @eval ($op)(a::YTObject,b::Real) = @array_same_units(a,YTQuantity(b,"dimensionless"),($op))
    @eval ($op)(a::Real,b::YTObject) = ($op)(b,a)
    @eval ($op)(a::YTObject,b::Array) = @array_same_units(a,YTArray(b,"dimensionless"),($op))
    @eval ($op)(a::Array,b::YTObject) = ($op)(b,a)
end

# Mathematical functions

sqrt(a::YTObject) = YTArray(sqrt(a.value), (a.units)^(1//2))

maximum(a::YTArray) = YTQuantity(maximum(a.value), a.units)
minimum(a::YTArray) = YTQuantity(minimum(a.value), a.units)

hypot(a::YTObject, b::YTObject, c::YTObject) = hypot(hypot(a,b), c)

abs(a::YTObject) = YTArray(abs(a.value), a.units)
abs2(a::YTObject) = YTArray(abs2(a.value), a.units*a.units)

for op = (:exp, :log, :log2, :log10, :log1p, :expm1,
          :sin, :cos, :tan, :sec, :csc, :cot, :sinh,
          :cosh, :tanh, :coth, :sech, :csch, :sinpi,
          :cospi, :asin, :acos, :atan)
    @eval ($op)(a::YTObject) = ($op)(a.value)
end

# Show

summary(a::YTArray) = string(dims2string(size(a)), " YTArray ($(a.units)):")

function showarray(io::IO, a::YTArray; kw...)
    println(io, summary(a))
    showarray(io, a.value; header=false, limit=true)
end

function print(io::IO, a::YTArray)
    print(io, "$(a.value) $(a.units)")
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

size(a::YTArray) = size(a.value)
size(a::YTArray, n::Integer) = size(a.value, n)

ndims(a::YTArray) = ndims(a.value)

sum(a::YTArray) = YTQuantity(sum(a.value), a.units)
sum(a::YTArray, dims) = YTQuantity(sum(a.value, dims), a.units)

sum_kbn(a::YTArray) = YTArray(sum_kbn(a.value), a.units)

cumsum(a::YTArray) = YTArray(cumsum(a.value), a.units)
cumsum(a::YTArray, dim::Integer) = YTArray(cumsum(a.value, dim), a.units)

cumsum_kbn(a::YTArray) = YTArray(cumsum(a.value), a.units)
cumsum_kbn(a::YTArray, dim::Integer) = YTArray(cumsum(a.value, dim), a.units)

cummin(a::YTArray) = YTArray(cummin(a.value), a.units)
cummin(a::YTArray, dim::Integer) = YTArray(cummin(a.value, dim), a.units)

cummax(a::YTArray) = YTArray(cummax(a.value), a.units)
cummax(a::YTArray, dim::Integer) = YTArray(cummax(a.value, dim), a.units)

diff(a::YTArray) = YTArray(diff(a.value), a.units)
diff(a::YTArray, dim::Integer) = YTArray(diff(a.value, dim), a.units)

gradient(a::YTArray) = YTArray(gradient(a.value), a.units)
gradient(a::YTArray, b::YTObject) = YTArray(gradient(a.value, b.value), a.units/b.units)
gradient(a::YTArray, b::Real) = YTArray(gradient(a.value, b), a.units)

mean(a::YTArray) = YTQuantity(mean(a.value), a.units)
mean(a::YTArray, region) = YTQuantity(mean(a.value, region), a.units)

std(a::YTArray) = YTQuantity(std(a.value), a.units)
std(a::YTArray, region) = YTQuantity(std(a.value, region), a.units)

stdm(a::YTArray, m::YTQuantity) = YTQuantity(stdm(a, in_units(m,a.units).value), a.units)

var(a::YTArray) = YTQuantity(var(a.value), a.units)
var(a::YTArray, region) = YTQuantity(var(a.value, region), a.units)

varm(a::YTArray, m::YTQuantity) = YTQuantity(varm(a, in_units(m,a.units).value), a.units)

median(a::YTArray) = YTQuantity(median(a.value), a.units)
middle(a::YTArray) = YTQuantity(middle(a.value), a.units)

middle(a::YTQuantity) = YTQuantity(middle(a.value), a.units)
middle(a::YTQuantity, b::YTQuantity) = YTQuantity(middle(a.value, in_units(b, a.units).value), a.units)

midpoints(a::YTArray) = YTArray(midpoints(a.value), a.units)

quantile(a::YTArray,q::AbstractArray) = YTArray(quantile(a.value, q), a.units)
quantile(a::YTArray,q::Number) = YTArray(quantile(a.value, q), a.units)

# To/from HDF5

@doc doc"""
      Write a `YTArray` to an HDF5 file.

      Parameters:

      * `a::YTArray`: The `YTArray` to write to the file.
      * `filename::ASCIIString`: The file to write to.
      * `dataset_name::ASCIIString`: The name of the HDF5 dataset to
        write the data into.
      * `info::Dict{ASCIIString,Any}`: A dictionary of keys and values
        to write to the file, associated with this array, that will be
        stored in the dataset attributes.

      Examples:

          julia> using YT
          julia> a = YTArray(rand(10), "cm/s")
          juila> write_hdf5(a, "my_file.h5", dataset_name="velocity")
      """ ->
function write_hdf5(a::YTArray, filename::ASCIIString; dataset_name=nothing, info=nothing)
    arr = PyObject(a)
    arr[:write_hdf5](filename; dataset_name=dataset_name, info=info)
end

@doc doc"""
      Read a `YTArray` from an HDF5 file.

      Parameters:

      * `filename::ASCIIString`: The file to read from.
      * `dataset_name::ASCIIString`: The name of the HDF5 dataset to
        read the data from.

      Examples:

          julia> using YT
          juila> v = from_hdf5("my_file.h5", dataset_name="velocity")
      """ ->
function from_hdf5(filename::ASCIIString; dataset_name=nothing)
    YTArray(pycall(bare_array["from_hdf5"], PyObject, filename; dataset_name=dataset_name))
end

# Unit equivalencies

function to_equivalent(a::YTObject, unit::String, equiv::String; args...)
    arr = PyObject(a)
    equ = pycall(arr["to_equivalent"], PyObject, unit, equiv; args...)
    array_or_quan(equ)
end

function list_equivalencies(a::YTObject)
    arr = PyObject(a)
    arr[:list_equivalencies]()
end

function has_equivalent(a::YTObject, equiv::String)
    arr = PyObject(a)
    arr[:has_equivalent](equiv)
end

# Ones, Zeros, etc.

ones(a::YTArray) = YTArray(ones(a.value), a.units)
zeros(a::YTArray) = YTArray(zeros(a.value), a.units)
eye(a::YTArray) = YTArray(eye(a.value), a.units)

linspace(start::YTQuantity, stop::YTQuantity, n::Integer) = 
    YTArray(linspace(in_units(start, stop.units).value,stop.value,n), start.units)
linspace(start::YTQuantity, stop::YTQuantity) = 
    YTArray(linspace(in_units(start, stop.units).value,stop.value), start.units)

end
