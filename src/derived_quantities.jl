module derived_quantities

import PyCall: PyObject, pycall
import ..data_objects: DataContainer

type DerivedQuantities
    quantities::PyObject
    function DerivedQuantities(dc::DataContainer)
        new(dc.cont[:quantities])
    end
end

type DerivedQuantity
    quantity::PyObject
end

function getindex(q::DerivedQuantities, key::String)
    DerivedQuantity(pycall(q.quantities["__getitem__"], PyObject, key))
end

end
