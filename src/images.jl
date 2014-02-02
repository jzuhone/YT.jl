module images

using PyCall

import ..yt_array: YTArray
import Base.show

# FixedResolutionBuffer

type FixedResolutionBuffer
    frb::PyObject
end

function getindex(frb::FixedResolutionBuffer, key::String)
    YTArray(get(frb.frb, PyObject, key))
end

function show(io::IO, frb::FixedResolutionBuffer)
    println(io,frb.frb[:__repr__]())
end

end
