module profiles

import PyCall: @pyimport, PyObject, pystring
import Base: show, getindex
import ..data_objects: DataContainer
import ..array: YTArray, convert_to_units
@pyimport yt.data_objects.profiles as prof

Field  = Union{ASCIIString,Tuple{ASCIIString,ASCIIString}}

@doc doc"""

      Bin data from a data container object into a profile. These can be in
      1D, 2D, or 3D.

      Arguments:

      * `data_source::DataContainer`: The object containing the data from which the profile is
        to be created.
      * `bin_fields`: An `Array` of field names over which the binning will occur. The number of
        fields decides whether or not this will be a 1D, 2D, or 3D profile. If a single field string is
        given, it is assumed to be 1D.
      * `fields`: A single field or `Array` of fields to be binned.
      * `n_bins`: A single integer or tuple of 2 or 3 integers, to determine the number of bins along
        each dimension.
      * `extrema::Dict{ASCIIString,Any}`: A dictionary of tuples (with the field names as the keys) that
        determine the maximum and minimum of the bin ranges, e.g. Dict("density"=>(1.0e-30, 1.0e-25)). If a
        field's extrema are not specified, the extrema of the field in the `data_source` are assumed. The
        extrema are assumed to be in the units of the field in the `units` argument unless it is not
        specified, otherwise they are in the field's default units.
      * `logs::Dict{ASCIIString,Bool}`: A dictionary (with the field names as the keys) that determines whether
        the bins are in logspace or linear space, e.g. Dict("radius"=>false). If not set, the `take_log`
        attribute for the field determines this.
      * `units`: A dictionary (with the field names as the keys) that determines the units
        of the field, e.g. Dict("density"=>"Msun/kpc^3"). If not set then the default units for the
        field are used.
      * `weight_field`: The field to weight the binned fields by when binning. Can be a field name or
        `nothing`, to produce an unweighted profile. `"cell_mass"` is the default.
      * `accumulation::Bool`: If `true`, the profile values for a bin n are the cumulative sum of all the
        values from bin 1 to n. If the profile is 2D or 3D, an `Array{Bool,1}` of values can be given to
        control the summation in each dimension independently.
      * `fractional::Bool`: If `true`, the profile values are divided by the sum of all of the values.

      Examples:

          julia> sp = YT.Sphere(ds, "max", (1.0,"Mpc"))
          julia> units=Dict("radius"=>"kpc")
          julia> logs=Dict("radius"=>false)
          julia> fields=Dict("density","temperature")
          julia> profile = YT.YTProfile(sp, "radius", fields, n_bins=100, units=units, logs=logs)
          julia> print(profile.x)
          julia> print(profile["density"])
      """ ->
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
    field_dict::Dict
    var_dict::Dict
    unit_dict::Dict
    function YTProfile(data_source::DataContainer, bin_fields, fields;
                       n_bins=64, extrema=nothing, logs=nothing,
                       units=nothing, weight_field="cell_mass",
                       accumulation=false, fractional=false)
        if (typeof(bin_fields) <: AbstractString) | (typeof(bin_fields) <: Tuple)
            bin_fields = [bin_fields]
        end
        if (typeof(fields) <: AbstractString) | (typeof(fields) <: Tuple)
            fields = [fields]
        end
        profile = prof.create_profile(data_source.cont, bin_fields, fields;
                                      n_bins=n_bins, extrema=extrema,
                                      logs=logs, units=units,
                                      weight_field=weight_field,
                                      accumulation=accumulation,
                                      fractional=fractional)
        ndims = length(bin_fields)
        if typeof(n_bins) <: Integer
            n_bins = fill(n_bins, ndims)
        end
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
            n_bins, x, x_bins, y, y_bins, z, z_bins, Dict(), Dict(), Dict())
    end
end

@doc doc"""
      Set the unit of the x-axis of the profile.

      Arguments:

      * `profile::YTProfile`: The profile to use.
      * `new_unit::ASCIIString`: The new unit.
      """ ->
function set_x_unit(profile::YTProfile, new_unit::ASCIIString)
    profile.profile[:set_x_unit](new_unit)
    profile.x = YTArray(profile.profile["x"])
    profile.x_bins = YTArray(profile.profile["x_bins"])
    return
end

@doc doc"""
      Set the unit of the y-axis of the profile.

      Arguments:

      * `profile::YTProfile`: The profile to use.
      * `new_unit::ASCIIString`: The new unit.
      """ ->
function set_y_unit(profile::YTProfile, new_unit::ASCIIString)
    profile.profile[:set_y_unit](new_unit)
    profile.y = YTArray(profile.profile["y"])
    profile.y_bins = YTArray(profile.profile["y_bins"])
    return
end

@doc doc"""
      Set the unit of the z-axis of the profile.

      Arguments:

      * `profile::YTProfile`: The profile to use.
      * `new_unit::ASCIIString`: The new unit.
      """ ->
function set_z_unit(profile::YTProfile, new_unit::ASCIIString)
    profile.profile[:set_z_unit](new_unit)
    profile.z = YTArray(profile.profile["z"])
    profile.z_bins = YTArray(profile.profile["z_bins"])
    return
end

@doc doc"""
      Set the unit of a field in the profile.

      Arguments:

      * `profile::YTProfile`: The profile to use.
      * `field::ASCIIString`: The name of the field to change the unit for.
      * `new_unit::ASCIIString`: The new unit.
      """ ->
function set_field_unit(profile::YTProfile, field::ASCIIString, new_unit::ASCIIString)
    profile.unit_dict[field] = new_unit
    return
end

function getindex(profile::YTProfile, field::ASCIIString)
    if !haskey(profile.field_dict, field)
        profile.field_dict[field] = YTArray(get(profile.profile, PyObject, field))
    end
    if !haskey(profile.unit_dict, field)
        profile.unit_dict[field] = profile.field_dict[field].units
    end
    convert_to_units(profile.field_dict[field], profile.unit_dict[field])
    profile.field_dict[field]
end

@doc doc"""
      Get the variance of a field from the `YTProfile`.
      """ ->
function variance(profile::YTProfile, field::ASCIIString)
    if !haskey(profile.var_dict, field)
        fd = profile.source.cont[:_determine_fields](field)[1]
        profile.var_dict[field] = YTArray(get(profile.profile["variance"],
                                          PyObject, fd))
    end
    if !haskey(profile.unit_dict, field)
        profile.unit_dict[field] = profile.var_dict[field].units
    end
    convert_to_units(profile.var_dict[field], profile.unit_dict[field])
    profile.var_dict[field]
end

function show(io::IO, profile::YTProfile)
    dims = length(profile.bin_fields)
    bin_fields = join(profile.bin_fields, ", ")
    n_bins = join(profile.n_bins, "x")
    println(io, "$(dims)-D YTProfile ($(n_bins) bins) over $(bin_fields).")
end

end
