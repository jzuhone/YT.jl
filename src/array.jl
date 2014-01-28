import Base.show
import Base.convert
import Base.sqrt
using SymPy
using PyCall
@pyimport yt.mods as ytmods
@pyimport yt

# Grab the classes for creating YTArrays and YTQuantities

ytarray_new = yt.units["yt_array"]["YTArray"]
ytquantity_new = yt.units["yt_array"]["YTQuantity"]

# YTArray definition

type YTArray
    ytarray::PyObject
    array::PyArray
    units::Sym
    dimensions::Sym
    function YTArray(ytarray::PyObject)
        new(ytarray, pycall(ytarray["ndarray_view"], PyArray), ytarray[:units], ytarray[:units][:dimensions])
    end
    function YTArray(array::Array, units::String)
        units_str = units
        if units_str == "dimensionless"
            units_str = ""
        end
        ytarray = pycall(ytarray_new, PyObject, array, units_str)
        new(ytarray, pycall(ytarray["ndarray_view"], PyArray), ytarray[:units], ytarray[:units][:dimensions])
    end
    YTArray(array::Array, units::Sym) = YTArray(array, units[:__str__]())
end

# YTQuantity definition

type YTQuantity
    ytquantity::PyObject
    quantity::Real
    units::Sym
    dimensions::Sym
    function YTQuantity(ytquantity::PyObject)
        new(ytquantity, ytquantity[:ndarray_view]()[1], ytquantity[:units], ytquantity[:units][:dimensions])
    end
    function YTQuantity(quantity::Real, units::String)
        units_str = units
        if units_str == "dimensionless"
            units_str = ""
        end
        ytquantity = pycall(ytquantity_new, PyObject, quantity, units_str)
        new(ytquantity, ytquantity[:ndarray_view]()[1], ytquantity[:units], ytquantity[:units][:dimensions])
    end
    YTQuantity(quantity::Real, units::Sym) = YTQuantity(quantity, units[:__str__]())
end

# Conversions

convert(::Type{YTArray}, o::PyObject) = YTArray(o)
convert(::Type{YTQuantity}, o::PyObject) = YTQuantity(o)
function convert(::Type{Array}, a::YTArray)
    a.ytarray[:ndarray_view]()
end
function convert(::Type{Real}, q::YTQuantity)
    q.quantity
end

# Indexing

function getindex(a::YTArray, i::Int)
    YTQuantity(a.array[i], a.units)
end
function getindex(a::YTArray, i::Int, j::Int, k::Int)
    YTQuantity(getindex(a.array, i, j, k), a.units)
end

# Unit conversions

function in_units(a::YTArray, units::String)
    m = match(r"sqrt\((.*?)\)", units)
    if m != nothing
        subunit = m.captures[1]
        units_str = replace(units, "sqrt($subunit)", "($subunit)**0.5")
    else
        units_str = units
    end
    YTArray(pycall(a.ytarray["in_units"], PyObject, units_str))
end
in_units(a::YTArray, units::Sym) = in_units(a, units[:__str__]())

function in_cgs(a::YTArray)
    pycall(a.ytarray["in_cgs"], YTArray)
end

function in_units(q::YTQuantity, units::String)
    m = match(r"sqrt\((.*?)\)", units)
    if m != nothing
        subunit = m.captures[1]
        units_str = replace(units, "sqrt($subunit)", "($subunit)**0.5")
    else
        units_str = units
    end
    YTQuantity(pycall(q.ytquantity["in_units"], PyObject, units_str))
end
in_units(q::YTQuantity, units::Sym) = in_units(q, units[:__str__]())

function in_cgs(q::YTQuantity)
    pycall(q.ytquantity["in_cgs"], YTQuantity)
end

# Basic arithmetic

function +(a::YTArray, b::YTArray)
    same_dims = a.dimensions[:__str__]() == b.dimensions[:__str__]()
    if !same_dims
        error("$a and $b are not the same dimensions!")
    end
    c = a.ytarray[:ndarray_view]() + in_units(b, a.units).ytarray[:ndarray_view]()
    return YTArray(c, a.units)
end

function .*(a::YTArray, b::YTArray)
    same_dims = a.dimensions[:__str__]() == b.dimensions[:__str__]()
    if same_dims
        c = a.ytarray[:ndarray_view]().*in_units(b, a.units).ytarray[:ndarray_view]()
        units = a.units*a.units
    else
        c = a.ytarray[:ndarray_view]().*b.ytarray[:ndarray_view]()
        units = a.units*b.units
    end
    if units[:__str__]() == "dimensionless"
        return c
    else
        return YTArray(c, units)
    end
end

function *(a::YTArray, b::Real)
    c = b*a.ytarray[:ndarray_view]()
    return YTArray(c, a.units)
end

-(a::YTArray) = *(-1.0, a)
*(a::Real, b::YTArray) = *(b, a)
/(a::YTArray, b::Real) = *(a, 1.0/b)

function /(a::Real, b::YTArray)
    c = a/b.ytarray[:ndarray_view]()
    units = "1/\($(b.units[:__str__]())\)"
    return YTArray(c, units)
end

-(a::YTArray, b::YTArray) = +(a,-b)
./(a::YTArray, b::YTArray) = .*(a,1.0/b)

function .*(a::YTArray, b::Array)
    c = b.*a.ytarray[:ndarray_view]()
    return YTArray(c, a.units)
end

.*(a::Array, b::YTArray) = .*(b, a)
./(a::YTArray, b::Array) = .*(a, 1.0/b)
./(a::Array, b::YTArray) = .*(a, 1.0/b)

function .^(a::YTArray, b::Real)
    c = a.ytarray[:ndarray_view]().^b
    units = a.units^b
    return YTArray(c, units)
end

function +(q::YTQuantity, p::YTQuantity)
    same_dims = q.dimensions[:__str__]() == p.dimensions[:__str__]()
    if !same_dims
        error("$q and $p are not the same dimensions!")
    end
    r = q.quantity + in_units(p, q.units).quantity
    return YTQuantity(r, q.units)
end

function *(q::YTQuantity, p::YTQuantity)
    same_dims = q.dimensions[:__str__]() == p.dimensions[:__str__]()
    if same_dims
        r = q.quantity*in_units(p, q.units).quantity
        units = q.units*q.units
    else
        r = q.quantity*p.quantity
        units = q.units*p.units
    end
    return YTQuantity(r, units)
end

function *(q::YTQuantity, p::Real)
    r = p*q.quantity
    return YTQuantity(r, q.units)
end

*(q::Real, p::YTQuantity) = *(p, q)
/(q::YTQuantity, p::Real) = *(q, 1.0/p)

function /(q::Real, p::YTQuantity)
    r = q/p.quantity
    units = "1/\($(p.units[:__str__]())\)"
    return YTQuantity(r, units)
end

function *(q::YTQuantity, p::Array)
    r = p*q.quantity
    return YTArray(r, q.units)
end

*(q::Array, p::YTQuantity) = *(p, q)
/(q::YTQuantity, p::Array) = *(q, 1.0/p)
/(q::Array, p::YTQuantity) = *(q, 1.0/p)
-(q::YTQuantity) = *(-1.0, q)

function *(q::YTQuantity, p::YTArray)
    same_dims = q.dimensions[:__str__]() == p.dimensions[:__str__]()
    if same_dims
        r = q.quantity*in_units(p, q.units).ytarray[:ndarray_view]()
        units = q.units*q.units
    else
        r = q.quantity*p.ytarray[:ndarray_view]()
        units = q.units*p.units
    end
    if units[:__str__]() == "dimensionless"
        return r
    else
        return YTArray(r, units)
    end
end

*(q::YTArray, p::YTQuantity) = *(p,q)
/(q::YTArray, p::YTQuantity) = *(q, 1.0/p)
/(q::YTQuantity, p::YTArray) = *(q, 1.0/p)

function ^(q::YTQuantity, p::Integer)
    r = q.quantity^p
    units = q.units^p
    return YTQuantity(r, units)
end

function ^(q::YTQuantity, p::Real)
    r = q.quantity^p
    units = q.units^p
    return YTQuantity(r, units)
end

-(q::YTQuantity, p::YTQuantity) = +(q,-p)
/(q::YTQuantity, p::YTQuantity) = *(q,1.0/p)

# Mathematical functions

function sqrt(q::YTQuantity)
    r = sqrt(q.quantity)
    units = "\($(q.units[:__str__]())\)**0.5"
    return YTArray(r, units)
end

function sqrt(a::YTArray)
    c = sqrt(a.ytarray[:ndarray_view]())
    units = "\($(a.units[:__str__]())\)**0.5"
    return YTArray(c, units)
end

# Show

function show(io::IO, a::YTArray)
    println(io,a.ytarray[:__repr__]())
end

function show(io::IO, q::YTQuantity)
    println(io,q.ytquantity[:__repr__]())
end
