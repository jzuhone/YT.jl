module quantities

import PyCall: PyObject, pycall, pybuiltin, PyAny, @pyimport
import ..array: array_or_quan
import ..data_objects: DataContainer

@pyimport yt.data_objects.derived_quantities as dq
@pyimport yt.funcs as ytfuncs

# Quantities

isinstance = pybuiltin("isinstance")
PyTuple = pybuiltin("tuple")
PyList = pybuiltin("list")

function derived_quantity(dc::DataContainer, key::String, args...)
    q = pycall(dc.cont["quantities"]["__getitem__"], PyObject, key)
    a = pycall(q["__call__"], PyObject, args...)
    if pycall(isinstance, PyAny, a, PyTuple) || pycall(isinstance, PyAny, a, PyList)
        n = a[:__len__]()
        return [array_or_quan(pycall(a["__getitem__"], PyObject, i))
                for i in 0:n-1]
    else
        return array_or_quan(a)
    end
end

for key in keys(dq.derived_quantity_registry)
    quan = symbol(ytfuncs.camelcase_to_underscore(key))
    @eval ($quan)(dc::DataContainer, args...) = derived_quantity(dc, $key, args...)
end

end
