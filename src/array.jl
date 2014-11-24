module array

import Base: cbrt, convert, copy, eltype, hypot, maximum, minimum, ndims,
             show, size, sqrt, exp, log, log10, sin, cos, tan,
             expm1, log2, log1p, sinh, cosh, tanh, csc, sec, cot, csch,
             sinh, coth, sinpi, cospi, abs, abs2, asin, acos, atan, sum,
             cumsum, cummin, cummax, cumsum_kbn, diff, display, print,
             showarray, showerror

import SymPy: Sym
import PyCall: @pyimport, PyObject, pycall
@pyimport yt.units as units

IntOrRange = Union(Integer,Range,Range1,Array{Int,1})

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

function ^(u::YTUnit, v::Real)
    yt_unit = pycall(u.yt_unit["__pow__"], PyObject, v)
    YTUnit(yt_unit, yt_unit[:units], yt_unit[:units][:dimensions])
end

==(u::YTUnit, v::YTUnit) = ==(u.unit_symbol, v.unit_symbol)
!=(u::YTUnit, v::YTUnit) = !=(u.unit_symbol, v.unit_symbol)

show(io::IO, u::YTUnit) = show(io, u.unit_symbol)

# YTQuantity definition

type YTQuantity
    value::Float64
    units::YTUnit
    function YTQuantity(yt_quantity::PyObject)
        yt_units = YTUnit(yt_quantity["unit_quantity"],
                          yt_quantity[:units],
                          yt_quantity[:units][:dimensions])
        new(yt_quantity[:d][1], yt_units)
    end
    function YTQuantity(value::Float64, units::String; registry=nothing)
        unitary_quan = pycall(bare_quan, PyObject, 1.0, units, registry)
        yt_units = YTUnit(unitary_quan,
                          unitary_quan[:units],
                          unitary_quan[:units][:dimensions])
        new(convert(Float64, value), yt_units)
    end
end

YTQuantity(value::Real, units::String; args...) = YTQuantity(convert(Float64, value),
                                                             units; args...)
YTQuantity(ds, value::Real, units::String) = YTQuantity(value, units,
                                                        registry=ds.ds["unit_registry"])
YTQuantity(value::Real, units::Sym; args...) = YTQuantity(value, string(units); args...)
YTQuantity(value::Real, units::YTUnit) = YTQuantity(value, string(units.unit_symbol),
                                                    registry=units.yt_unit["units"]["registry"])
YTQuantity(value::Bool, units::String) = value
YTQuantity(value::Bool, units::Sym) = value
YTQuantity(value::Bool, units::YTUnit) = value
YTQuantity(value::Real) = YTQuantity(value, "dimensionless")

# YTArray definition

type YTArray <: AbstractArray
    value::Array{Float64}
    units::YTUnit
    function YTArray(yt_array::PyObject)
        yt_units = YTUnit(yt_array["unit_quantity"],
                          yt_array[:units],
                          yt_array[:units][:dimensions])
        new(yt_array[:d], yt_units)
    end
    function YTArray(value::Array{Float64}, units::String; registry=nothing)
        unitary_quan = pycall(bare_quan, PyObject, 1.0, units, registry)
        yt_units = YTUnit(unitary_quan,
                          unitary_quan[:units],
                          unitary_quan[:units][:dimensions])
        new(value, yt_units)
    end
end
YTArray(value::Array, units::String; args...) = YTArray(convert(Array{Float64}, value),
                                                        units; args...)
YTArray(ds, value::Array, units::String) = YTArray(value, units,
                                                   registry=ds.ds["unit_registry"])
YTArray(value::Array, units::Sym; args...) = YTArray(value, string(units); args...)
YTArray(value::Array, units::YTUnit) = YTArray(value, string(units.unit_symbol),
                                               registry=units.yt_unit["units"]["registry"])
YTArray(value::Real, units::String; args...) = YTQuantity(value, units; args...)
YTArray(ds, value::Real, units::String) = YTQuantity(value, units, registry=ds.ds["unit_registry"])
YTArray(value::Real, units::Sym; args...) = YTQuantity(value, units; args...)
YTArray(value::Real, units::YTUnit; args...) = YTQuantity(value, units; args...)
YTArray(value::BitArray, units::String) = value
YTArray(value::BitArray, units::Sym) = value
YTArray(value::BitArray, units::YTUnit) = value
YTArray(value::Array) = YTArray(value, "dimensionless")
YTArray(value::Real) = YTQuantity(value, "dimensionless")

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
copy(a::YTArray) = YTArray(a.value, a.units)

# Conversions

convert(::Type{YTArray}, o::PyObject) = YTArray(o)
convert(::Type{YTQuantity}, o::PyObject) = YTQuantity(o)
convert(::Type{Array{Float64}}, a::YTArray) = a.value
convert(::Type{Float64}, q::YTQuantity) = q.value
convert(::Type{PyObject}, a::YTArray) = pycall(bare_array, PyObject, a.value,
                                               string(a.units.unit_symbol),
                                               a.units.yt_unit["units"]["registry"])
convert(::Type{PyObject}, a::YTQuantity) = pycall(bare_quan, PyObject, a.value,
                                                  string(a.units.unit_symbol),
                                                  a.units.yt_unit["units"]["registry"])
# Indexing, ranges (slicing)

getindex(a::YTArray, i::Integer) = YTQuantity(a.value[i], a.units)
getindex(a::YTArray, idxs::Array{Int,1}) = YTArray(getindex(a.value, idxs), a.units)
getindex(a::YTArray, idxs::Ranges) = YTArray(getindex(a.value, idxs), a.units)

function setindex!(a::YTArray, x::Real, i::Integer)
    a.value[i] = convert(Float64, x)
end
function setindex!(a::YTArray, x::Array, idxs::Ranges)
    YTArray(setindex!(a.value, convert(Array{Float64}, x), idxs), a.units)
end
function setindex!(a::YTArray, x::Array, idxs::Array{Int,1})
    YTArray(setindex!(a.value, convert(Array{Float64}, x), idxs), a.units)
end
function setindex!(a::YTArray, x::Real, idxs::Ranges)
    YTArray(setindex!(a.value, convert(Float64, x), idxs), a.units)
end
function setindex!(a::YTArray, x::Real, idxs::Array{Int,1})
    YTArray(setindex!(a.value, convert(Float64, x), idxs), a.units)
end

# For grids
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange, k::IntOrRange)
    return YTArray(getindex(a.value, i, j, k), a.units)
end

# For images
function getindex(a::YTArray, i::IntOrRange, j::IntOrRange)
    return YTArray(getindex(a.value, i, j), a.units)
end

# Unit conversions

function in_units(a::YTObject, units::String)
    a.value*YTQuantity(pycall(a.units.yt_unit["in_units"], PyObject, units))
end

function in_cgs(a::YTObject)
    a.value*pycall(a.units.yt_unit["in_cgs"], YTQuantity)
end

function in_mks(a::YTObject)
    a.value*pycall(a.units.yt_unit["in_mks"], YTQuantity)
end

in_units(a::YTObject, units::Sym; args...) = in_units(a, string(units); args...)
in_units(a::YTObject, units::YTUnit; args...) = in_units(a, units.unit_symbol; args...)
in_units(a::YTObject, b::YTObject; args...) = in_units(a, b.units; args...)

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

sqrt(a::YTObject) = YTArray(sqrt(a.value), a.units^0.5)
cbrt(a::YTObject) = YTArray(cbrt(a.value), (a.units)^(1/3))

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
    #@eval ($op)(q::YTQuantity) = ($op)(q.value)
end

# Show

function showarray(io::IO, a::YTArray; kw...)
    println(io, "$(summary(a)) ($(a.units)):")
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

eltype(a::YTArray) = eltype(a.value)

sum(a::YTArray) = YTQuantity(sum(a.value), a.units)
sum(a::YTArray, dims) = YTQuantity(sum(a.value, dims), a.units)

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
    arr = convert(PyObject, a)
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
    arr = convert(PyObject, a)
    equ = pycall(arr["to_equivalent"], PyObject, unit, equiv; args...)
    array_or_quan(equ)
end

function list_equivalencies(a::YTObject)
    arr = convert(PyObject, a)
    arr[:list_equivalencies]()
end

function has_equivalent(a::YTObject, equiv::String)
    arr = convert(PyObject, a)
    arr[:has_equivalent](equiv)
end

# Ones and Zeros

function ones_like(a::YTArray)
    YTArray(ones(size(a)), a.units)
end

function zeros_like(a::YTArray)
    YTArray(zeros(size(a)), a.units)
end

end
