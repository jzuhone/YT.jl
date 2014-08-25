module profiles

import PyCall: @pyimport, PyObject
import Base.show
import ..data_objects: DataContainer
import ..array: YTArray
@pyimport yt.data_objects.profiles as prof

type YTProfile
    profile::PyObject
    source::DataContainer
    bin_fields
    fields
    weight_field
    n_bins
    x
    x_bins
    y
    y_bins
    z
    z_bins
    function YTProfile(data_source::DataContainer, bin_fields, fields;
                       n_bins=64, extrema=nothing, logs=nothing,
                       units=nothing, weight_field="cell_mass",
                       accumulation=false, fractional=false)
        if (typeof(bin_fields) <: String) | (typeof(bin_fields) <: Tuple)
            bin_fields = [bin_fields]
        end
        if (typeof(fields) <: String) | (typeof(fields) <: Tuple)
            fields = [fields]
        end
        profile = prof.create_profile(data_source.cont, bin_fields, fields;
                                      n_bins=n_bins, extrema=extrema,
                                      logs=logs, units=units,
                                      weight_field=weight_field,
                                      accumulation=accumulation,
                                      fractional=fractional)
        ndims = length(bin_fields)
        x = YTArray(profile["x"])
        x_bins = YTArray(profile["x_bins"])
        if ndims >= 2
            y = YTArray(profile["y"])
            y_bins = YTArray(profile["y_bins"])
        else
            y = nothing
            y_bins = nothing
        end
        if ndims == 3
            z = YTArray(profile["z"])
            z_bins = YTArray(profile["z_bins"])
        else
            z = nothing
            z_bins = nothing
        end
        new(profile, data_source, bin_fields, fields, weight_field,
            n_bins, x, x_bins, y, y_bins, z, z_bins)
    end
end

function set_x_unit(profile::YTProfile, new_unit::String)
    profile.profile[:set_x_unit](new_unit)
    profile.x = YTArray(profile.profile["x"])
    profile.x_bins = YTArray(profile.profile["x_bins"])
    return
end
function set_y_unit(profile::YTProfile, new_unit::String)
    profile.profile[:set_y_unit](new_unit)
    profile.y = YTArray(profile.profile["y"])
    profile.y_bins = YTArray(profile.profile["y_bins"])
    return
end
function set_z_unit(profile::YTProfile, new_unit::String)
    profile.profile[:set_z_unit](new_unit)
    profile.z = YTArray(profile.profile["z"])
    profile.z_bins = YTArray(profile.profile["z_bins"])
    return
end

function set_field_unit(profile::YTProfile, field::String, new_unit::String)
    profile.profile[:set_field_unit](field, new_unit)
end

getindex(profile::YTProfile, key::String) = YTArray(get(profile.profile, PyObject, key))
getindex(profile::YTProfile, ftype::String, fname::String) = YTArray(get(profile.profile,
                                                                         PyObject, (ftype,fname)))

variance(profile::YTProfile, ftype::String, fname::String) = YTArray(get(profile.profile["variance"],
                                                                         PyObject, (ftype,fname)))
function variance(profile::YTProfile, key::String)
    field = profile.source.cont[:_determine_fields](key)
    variance(profile, field[1][1], field[1][2])
end

show(io::IO, profile::YTProfile) = print(io,profile.profile[:__repr__]())

end

