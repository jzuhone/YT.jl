module quantities

import PyCall: PyObject, pycall, pybuiltin, PyAny, @pyimport, pyisinstance, PyVector
import ..array: array_or_quan
import ..data_objects: DataContainer

@pyimport yt.data_objects.derived_quantities as dq
@pyimport yt.funcs as ytfuncs

# Quantities

PyTuple = pybuiltin("tuple")
PyList = pybuiltin("list")

function derived_quantity(dc::DataContainer, key::String, args...)
    q = get(dc.cont["quantities"], key)
    a = pycall(q["__call__"], PyObject, args...)
    if pyisinstance(a, PyTuple) || pyisinstance(a, PyList)
        a = PyVector{PyObject}(a)
        return tuple([array_or_quan(v) for v in a]...)
    else
        return array_or_quan(a)
    end
end

for key in keys(dq.derived_quantity_registry)
    quan = symbol(ytfuncs.camelcase_to_underscore(key))
    @eval ($quan)(dc::DataContainer, args...) = derived_quantity(dc, $key, args...)
end

end
