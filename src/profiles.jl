module profiles

using PyCall
import Base.show
import ..data_objects: DataContainer
import ..array: YTArray, YTQuantity, in_units
@pyimport yt.data_objects.profiles as prof

abstract YTProfile

type Profile1D <: YTProfile
    profile::PyObject
    source::DataContainer
    x_field
    x::YTArray
    x_bins::YTArray
    weight_field
    function Profile1D(data_source::DataContainer, x_field, x_n::Integer,
                       x_min::Real, x_max::Real, x_log::Bool; weight_field=nothing)
        if weight_field != nothing
            weight = weight_field
        end
        profile = prof.Profile1D(data_source.cont, x_field, x_n, x_min, x_max,
                                 x_log, weight_field=weight)
        new(profile, data_source, x_field, YTArray(profile["x"]),
            YTArray(profile["x_bins"]), weight_field)
    end
end

type Profile2D <: YTProfile
    profile::PyObject
    source::DataContainer
    x_field
    y_field
    x::YTArray
    x_bins::YTArray
    y::YTArray
    y_bins::YTArray
    weight_field
    function Profile2D(data_source::DataContainer, x_field, x_n::Integer,
                       x_min::Real, x_max::Real, x_log::Bool, y_field,
                       y_n::Integer, y_min::Real, y_max::Real, y_log::Bool;
                       weight_field=nothing)
        if weight_field != nothing
            weight = weight_field
        end
        profile = prof.Profile2D(data_source.cont, x_field, x_n, x_min, x_max,
                                 x_log, y_field, y_n, y_min, y_max, y_log,
                                 weight_field=weight)
        new(profile, data_source, x_field, y_field, YTArray(profile["x"]),
            YTArray(profile["x_bins"]), YTArray(profile["y"]),
            YTArray(profile["y_bins"]), weight_field)
    end
end

type Profile3D <: YTProfile
    profile::PyObject
    source::DataContainer
    x_field
    y_field
    z_field
    x::YTArray
    x_bins::YTArray
    y::YTArray
    y_bins::YTArray
    z::YTArray
    z_bins::YTArray
    weight_field
    function Profile3D(data_source::DataContainer, x_field, x_n::Integer,
                       x_min::Real, x_max::Real, x_log::Bool, y_field,
                       y_n::Integer, y_min::Real, y_max::Real, y_log::Bool,
                       z_field, z_n::Integer, z_min::Real, z_max::Real,
                       z_log::Bool; weight_field=nothing)
        if weight_field != nothing
            weight = weight_field
        end
        profile = prof.Profile3D(data_source.cont, x_field, x_n, x_min, x_max,
                                 x_log, y_field, y_n, y_min, y_max, y_log,
                                 z_field, z_n, z_min, z_max, z_log, weight_field=weight)
        new(profile, data_source, x_field, y_field, z_field, YTArray(profile["x"]),
            YTArray(profile["x_bins"]), YTArray(profile["y"]),
            YTArray(profile["y_bins"]), YTArray(profile["z"]),
            YTArray(profile["z_bins"]), weight_field)
    end
end

function set_x_unit(profile::YTProfile, new_unit::String)
    profile.x = in_units(profile.x, new_unit)
    profile.x_bins = in_units(profile.x_bins, new_unit)
    return
end
function set_y_unit(profile::YTProfile, new_unit::String)
    profile.y = in_units(profile.y, new_unit)
    profile.y_bins = in_units(profile.y_bins, new_unit)
    return
end
function set_z_unit(profile::YTProfile, new_unit::String)
    profile.z = in_units(profile.z, new_unit)
    profile.z_bins = in_units(profile.z_bins, new_unit)
    return
end

function set_field_unit(profile::YTProfile, field::String, new_unit::String)
    profile.profile[:set_field_unit](field, new_unit)
end

getindex(profile::YTProfile, key::String) = YTArray(get(profile.profile, PyObject, key))
getindex(profile::YTProfile, ftype::String, fname::String) = YTArray(get(profile.profile,
                                                                         PyObject, (ftype,fname)))
variance(profile::YTProfile, key::String) = YTArray(get(profile.variance, PyObject, key))
variance(profile::YTProfile, ftype::String, fname::String) = YTArray(get(profile.variance,
                                                                         PyObject, (ftype,fname)))
add_fields(profile::YTProfile, fields) = profile.profile[:add_fields](fields)
show(io::IO, profile::YTProfile) = print(io,profile.profile[:__repr__]())

end

