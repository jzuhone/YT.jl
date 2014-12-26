module derived_quantities

import ..array: YTArray, YTQuantity
import ..data_objects: DataContainer, get_field_info

in_parallel = nprocs() > 1

Field = Union(ASCIIString,(ASCIIString,ASCIIString))

if in_parallel
    function preduce(f,d)
        dd = distribute(d.value)
        m = map(fetch, [(@spawnat p f(localpart(dd))) for p=procs(dd)])
        YTQuantity(f(m), d.units)
    end
else
    preduce(f,d) = f(d)
end

function total_quantity(dc::DataContainer, field::Field)
    preduce(sum, dc[field])
end

function extrema(dc::DataContainer, field::Field)
    preduce(minimum, dc[field]), preduce(maximum, dc[field])
end

function weighted_average_quantity(dc::DataContainer, field::Field, weight::Field)
    preduce(sum, dc[field]*dc[weight])/preduce(sum, dc[weight])
end

function weighted_average_quantity(dc::DataContainer, fields::Array, weight::Field)
    [weighted_average_quantity(dc, field, weight) for field in fields]
end

function min_location(dc::DataContainer, field::Field)
    minf, mini = findmin(dc[field])
    mpos = [dc[string(ax)][mini] for ax in "xyz"]
    minf, mini, mpos[1], mpos[2], mpos[3]
end

function max_location(dc::DataContainer, field::Field)
    maxf, maxi = findmax(dc[field])
    mpos = [dc[string(ax)][maxi] for ax in "xyz"]
    maxf, maxi, mpos[1], mpos[2], mpos[3]
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