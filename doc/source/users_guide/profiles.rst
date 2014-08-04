Profiles
========

``yt`` allows for data container objects to be binned up into profiles along some dimension defined
by a field. These can be in 1D, 2D, or 3D. ``jt`` reproduces this functionality via the
``YTProfile`` type:

.. code-block:: julia

   function YTProfile(data_source::DataContainer, bin_fields, fields;
                        n_bins=64, extrema=nothing, logs=nothing,
                        units=nothing, weight_field="cell_mass",
                        accumulation=false, fractional=false)

``YTProfile`` takes the following arguments:

  * ``data_source``: The ``DataContainer`` object containing the data from which the profile is
    to be created.
  * ``bin_fields``: An ``Array`` of field names over which the binning will occur. The number of
    fields decides whether or not this will be a 1D, 2D, or 3D profile. If a single field string is
    given, it assumed to be 1D.
  * ``fields``: A single field or list of fields to be binned.
  * ``n_bins``: A single integer or tuple of 2 or 3 integers, to determine the number of bins
    along each dimension.
  * ``extrema``: A dictionary of tuples (with the field names as the keys) that determine the
    maximum and minimum of the bin ranges, e.g. ["density"=>(1.0e-30, 1.0e-25)]. If a field's
    extrema are not specified, the extrema of the field in the ``data_source`` are assumed. The
    extrema are assumed to be in the units of the field in the ``units`` argument unless it is not
    specified, otherwise they are in the field's default units.
  * ``logs``: A dictionary of tuples (with the field names as the keys) that determine whether
    the bins are in logspace or linear space, e.g. ["radius"=>false]. If not set,
    the ``take_log`` attribute for the field determines this.
  * ``units``: A dictionary of tuples (with the field names as the keys) that determine the units
    of the field. If not set then the default units for the field are used.
  * ``weight_field``: The field to weight the binned fields by when binning. Can be a field name or
    ``nothing``, to produce an unweighted profile. ``"cell_mass"`` is the default.
  * ``accumulation``: If ``true``, the profile values for a bin n are the cumulative sum of all the
    values from bin 1 to n. If the profile is 2D or 3D, an ``Array`` of values can be given to
    control the summation in each dimension independently.
  * ``fractional``: If ``true``, the profile values are divided by the sum of all of the values.

For example, to construct a 1D radial profile from a ``Sphere``, with the bins in linear space
and with the units of the radius in kpc:

.. code-block:: jlcon

   julia> sp = jt.Sphere(ds, "max", (1.0,"Mpc"))

   julia> units=["radius"=>"kpc"]

   julia> logs=["radius"=>false]

   julia> profile = jt.YTProfile(sp, "radius", ["density","temperature"], units=units, logs=logs)