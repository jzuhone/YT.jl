module derived_quantities

import PyCall: PyObject

import ..array: YTArray, YTQuantity
import ..data_objects: DataContainer, get_field_info
import ..utilities: ensure_array

if VERSION < v"0.4-"
    import YT: @doc
end

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

function creduce(f, chunks, fields)
    qs = []
    for field in fields
        sto = []
        for chunk in chunks
            arr = YTArray(get(chunk, PyObject, field))
            append!(sto, [f(arr)])
        end
        append!(qs, [f(sto)])
    end
    if length(qs) == 1
        return qs[1]
    else
        return qs
    end
end

function prepare_chunks(dc, fields)
    fields = ensure_array(fields)
    chunks = []
    for chunk in dc.cont[:chunks](fields, "io")
        append!(chunks, [chunk])
    end
    fields, chunks
end

function total_quantity(dc::DataContainer, fields)
    fields, chunks = prepare_chunks(dc, fields)
    creduce(sum, chunks, fields)
end

function extrema(dc::DataContainer, fields)
    fields, chunks = prepare_chunks(dc, fields)
    mini = creduce(minimum, chunks, fields)
    maxi = creduce(maximum, chunks, fields)
    if length(fields) == 1
        return (mi, mx)
    else
        return [(mi,mx) for (mi,mx) in zip(mini,maxi)]
    end
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

function center_of_mass(dc::DataContainer; use_gas=true, use_particles=false)
    x = YTQuantity(dc.ds, 0.0, "code_length*code_mass")
    y = YTQuantity(dc.ds, 0.0, "code_length*code_mass")
    z = YTQuantity(dc.ds, 0.0, "code_length*code_mass")
    w = YTQuantity(dc.ds, 0.0, "code_mass")
    if use_gas & (get_field_info(dc.ds, ("gas","cell_mass")) != nothing)
        x += preduce(sum, dc["cell_mass"].*dc["x"])
        y += preduce(sum, dc["cell_mass"].*dc["y"])
        z += preduce(sum, dc["cell_mass"].*dc["z"])
        w += preduce(sum, dc["cell_mass"])
    end
    if use_particles & (get_field_info(dc.ds, ("all","particle_mass")) != nothing)
        x += preduce(sum, dc["particle_mass"].*dc["particle_position_x"])
        y += preduce(sum, dc["particle_mass"].*dc["particle_position_y"])
        z += preduce(sum, dc["particle_mass"].*dc["particle_position_z"])
        w += preduce(sum, dc["particle_mass"])
    end
    YTArray([x,y,z])/w
end

end