.. _datasets:

.. |glob_package| replace:: Glob.jl package
.. _glob_package: https://github.com/vtjnash/Glob.jl

Datasets
========

The most basic ``YT`` object is the ``Dataset``. This is a collection of volumetric data that may
be stored on disk, or created in-memory. To load a ``Dataset`` from disk, we use ``load``:

.. code-block:: jlcon

    julia> ds = YT.load("sloshing_nomag2_hdf5_plt_cnt_0100")
    yt : [WARNING  ] 2014-03-31 23:46:27,765 integer runtime parameter checkpointfilenumber overwrites a simulation scalar of the same name
    yt : [WARNING  ] 2014-03-31 23:46:27,765 integer runtime parameter plotfilenumber overwrites a simulation scalar of the same name
    yt : [INFO     ] 2014-03-31 23:46:27,768 Parameters: current_time              = 7.89058001997e+16
    yt : [INFO     ] 2014-03-31 23:46:27,768 Parameters: domain_dimensions         = [16 16 16]
    yt : [INFO     ] 2014-03-31 23:46:27,769 Parameters: domain_left_edge          = [ -3.70272000e+24  -3.70272000e+24  -3.70272000e+24]
    yt : [INFO     ] 2014-03-31 23:46:27,770 Parameters: domain_right_edge         = [  3.70272000e+24   3.70272000e+24   3.70272000e+24]
    yt : [INFO     ] 2014-03-31 23:46:27,770 Parameters: cosmological_simulation   = 0.0
    yt : [INFO     ] 2014-03-31 23:46:28,340 Loading field plugins.
    yt : [INFO     ] 2014-03-31 23:46:28,340 Loaded angular_momentum (8 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,340 Loaded astro (14 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,340 Loaded cosmology (20 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,341 Loaded fluid (55 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,341 Loaded fluid_vector (87 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,342 Loaded geometric (102 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,342 Loaded local (102 new fields)
    yt : [INFO     ] 2014-03-31 23:46:28,342 Loaded magnetic_field (108 new fields)
    "sloshing_nomag2_hdf5_plt_cnt_0100"

where you can see that the ``yt`` log has been outputted. The ``Dataset`` object ``ds`` now
contains all of the basic metadata about the data stored in the file
``"sloshing_nomag2_hdf5_plt_cnt_0100"``. Attached to ``ds`` are several useful attributes, as well
as a number of methods for creating ``DataContainers``.

.. _parameters:

Parameters
----------

Each simulation ``Dataset`` normally has a number of runtime parameters associated with it. This
is stored in the ``parameters`` dictionary:

.. code-block:: jlcon

    julia> collect(keys(ds.parameters))
    293-element Array{Any,1}:
     "min_particles_per_blk"
     "zmax"
     "maxcondentr"
     "usemassdiffusivity"
     "saturatedconduction"
     "zmin"
     ⋮
     "flux_correct"
     "nxb"
     "plotfilenumber"
     "log_file"
     "e_modification"
     "order"

    julia> ds.parameters["nxb"]
    0-dimensional Array{Int32,0}:
     16

.. _dataset-methods:

Methods
-------

``print_stats`` may be used to get a quick synopsis of the structure of the ``Dataset``. In this case,
it is a FLASH AMR dataset, so statistics regarding the grids and cells are printed:

.. code-block:: jlcon

    julia> YT.print_stats(ds)
    level	# grids	       # cells	     # cells^3
    ----------------------------------------------
      0	         1	          4096	            15
      1	         8	         32768	            31
      2	        64	        262144	            63
      3	       512	       2097152	           127
      4	       256	       1048576	           101
      5	       256	       1048576	           101
      6	       256	       1048576	           101
    ----------------------------------------------
     	      1353	       5541888


    t = 7.89058002e+16 = 7.89058002e+16 s = 2.50037393e+09 years

    Smallest Cell:
	        Width: 2.344e-03 Mpc
	        Width: 2.344e+03 pc
	        Width: 4.834e+08 AU
	        Width: 7.232e+21 cm

``get_smallest_dx`` returns the length scale of the smallest cell or SPH smoothing length:

.. code-block:: jlcon

    julia> YT.get_smallest_dx(ds)
    7.231875e21 code_length

``get_field_list`` can be used to obtain the list of on-disk fields:

.. code-block:: jlcon

    julia> YT.get_field_list(ds)
    12-element Array{Any,1}:
     ("flash","dens")
     ("flash","temp")
     ("flash","pres")
     ("flash","gpot")
     ("flash","divb")
     ("flash","velx")
     ("flash","vely")
     ("flash","velz")
     ("flash","magx")
     ("flash","magy")
     ("flash","magz")
     ("flash","magp")

and ``get_derived_field_list`` returns a list of all of the fields that can be generated:

.. code-block:: jlcon

    julia> YT.get_derived_field_list(ds)
    120-element Array{Any,1}:
     ("flash","dens")
     ("flash","divb")
     ("flash","gpot")
     ("flash","magp")
     ("flash","magx")
     ("flash","magy")
     ("flash","magz")
     ("flash","pres")
     ("flash","temp")
     ("flash","velx")
     ⋮
     ("index","radius")
     ("index","spherical_phi")
     ("index","spherical_r")
     ("index","spherical_theta")
     ("index","virial_radius_fraction")
     ("index","x")
     ("index","y")
     ("index","z")
     ("index","zeros")

``find_min`` and ``find_max`` are used to find the minimum or maximum of a field. They return
the field value and the point of the extremum:

.. code-block:: jlcon

    julia> v, p = YT.find_min(ds, "temperature")
    yt : [INFO     ] 2014-11-19 11:51:56,612 Min Value is 9.48720e+05 at
    -3673792499999999619235840.0000000000000000 3673792500000000156106752.0000000000000000
    -3673792499999999619235840.0000000000000000

    julia> v
    948720.25 K

    julia> p
    3-element YTArray (code_length):
     -3.6737924999999996e24
      3.6737925e24
     -3.6737924999999996e24

.. note::

    These methods apply to ``Dataset``\ s loaded from disk files and to ``Dataset``\ s created
    from generic in-memory data. For details on how to create the latter,
    see `In-Memory Datasets <in_memory_datasets.html>`_.
    
Dataset Series
--------------

If you have a time-series set of ``Dataset``\ s, you can construct a ``DatasetSeries`` object
to iterate over them:

.. code-block:: julia

    function DatasetSeries(fns::Array{ASCIIString,1}))
    
where ``fns`` is an ``Array`` of strings corresponding to the filenames of the datasets to be
loaded. Such a list of filenames could be generated using the |glob_package|_. Once a 
``DatasetSeries`` object is created, it can be iterated over, such as in this script:

.. code-block:: julia

    using YT
    using Glob
    fns = sort(glob("sloshing_low_res_hdf5_plt_cnt_0*"))
    
    time = YTQuantity[]
    max_dens = YTQuantity[]
    
    ts = DatasetSeries(fns)
    
    for ds in ts
        append!(time, [ds.current_time])
        sp = Sphere(ds, "c", (100.,"kpc"))
        append!(max_dens, [maximum(sp["density"])])
    end
           
    time = YTArray(time)
    max_dens = YTArray(max_dens)

