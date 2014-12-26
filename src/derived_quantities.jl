module derived_quantities

import ..array: YTArray, YTQuantity
import ..data_objects: DataContainer, get_field_info

Field = Union(ASCIIString,(ASCIIString,ASCIIString))

function total_quantity(dc::DataContainer, field::Field)
    sum(dc[field])
end

function extrema(dc::DataContainer, field::Field)
    minimum(dc[field]), maximum(dc[field])
end

function weighted_average_quantity(dc::DataContainer, field::Field, weight::Field)
    sum(dc[field]*dc[weight])/sum(dc[weight])
end

function weighted_average_quantity(dc::DataContainer, fields::Array, weight::Field)
    [weighted_average_quantity(dc, field, weight) for field in fields]
end

for dq = (:total_quantity, :extrema)
    @eval ($dq)(dc::DataContainer, fields::Array) = [($dq)(dc, field) for field in fields]
end

function total_mass(dc::DataContainer)
    fields = []
    if get_field_info(dc.ds, ("gas","cell_mass")) != nothing
        append!(fields, [("gas","cell_mass")])
    end
    if get_field_info(dc.ds, ("all","particle_mass")) != nothing
        append!(fields, [("all","particle_mass")])
    end
    q = total_quantity(dc, fields)
    if length(q) == 2
        return q[1], q[2]
    else
        return q[1]
    end
end

end