module fixed_resolution

import PyCall: PyObject

import ..array: YTArray, YTQuantity
import Base.show

# FixedResolutionBuffer

type FixedResolutionBuffer
    frb::PyObject
    limits::Dict
    buff_size::Tuple
    function FixedResolutionBuffer(ds, frb::PyObject)
        limits = frb[:limits]
        for k in keys(limits)
            if limits[k] != nothing
                limits[k] = (YTQuantity(ds, limits[k][1][1],"code_length"),
                             YTQuantity(ds, limits[k][end][1],"code_length"))
            end
        end
        new(frb, limits, frb[:buff_size])
    end
end

function getindex(frb::FixedResolutionBuffer, key::String)
    YTArray(get(frb.frb, PyObject, key))
end

function getindex(frb::FixedResolutionBuffer, ftype::String, fname::String)
    YTArray(get(frb.frb, PyObject, (ftype,fname)))
end

function show(io::IO, frb::FixedResolutionBuffer)
    println(io,"FixedResolutionBuffer ($(frb.buff_size[1])x$(frb.buff_size[2])):")
    for k in keys(frb.limits)
        if frb.limits[k] != nothing
            a = frb.limits[k][1]
            b = frb.limits[k][2]
            println(io,"    $(a.value) code_length <= $k < $(b.value) code_length")
        end
    end
end

end
