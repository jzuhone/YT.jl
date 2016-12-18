__precompile__()
module unit_systems

import PyCall: PyObject, pystring
import Base: show, getindex

type UnitSystem
    us::PyObject
    constants::PyObject
    function UnitSystem(us::PyObject)
        new(us, us[:constants])
    end
end

function getindex(us::UnitSystem, dimension::String)
    pystring(get(us.us, PyObject, dimension))
end

show(io::IO, us::UnitSystem) = print(io, pystring(us.us))

end
