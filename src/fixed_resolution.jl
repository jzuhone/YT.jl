module fixed_resolution

import PyCall: PyObject

import ..array: YTArray, YTQuantity
import Base.show

Field  = Union(ASCIIString,(ASCIIString,ASCIIString))

# FixedResolutionBuffer

type FixedResolutionBuffer
    frb::PyObject
    data::Dict
    buff_size::Tuple
    function FixedResolutionBuffer(ds, frb::PyObject)
        new(frb, Dict(), frb[:buff_size])
    end
end

function getindex(frb::FixedResolutionBuffer, field::Field)
    if !haskey(frb.data, field)
        frb.data[field] = YTArray(get(frb.frb, PyObject, field))
    end
    return frb.data[field]
end

getindex(frb::FixedResolutionBuffer, ftype::ASCIIString,
         fname::ASCIIString) = getindex(frb, (ftype, fname))

function show(io::IO, frb::FixedResolutionBuffer)
    println(io,"FixedResolutionBuffer ($(frb.buff_size[1])x$(frb.buff_size[2]))")
end

end
