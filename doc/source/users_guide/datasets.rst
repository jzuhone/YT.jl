.. _datasets:

Datasets
========

The most basic ``jt`` object is the ``Dataset``. This is a collection of volumetric data that may
be stored on disk, or created in-memory. To load a ``Dataset`` from disk, we use ``load``:

.. code-block:: jlcon

    julia> ds = jt.load("sloshing_nomag2_hdf5_plt_cnt_0100")
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

    julia> jt.print_stats(ds)
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

    julia> jt.get_smallest_dx(ds)
    7.231875e21 code_length

.. note::

    These methods apply to ``Dataset``\ s loaded from disk files and to ``Dataset``\ s created
    from generic in-memory data. For details on how to create the latter,
    see `In-Memory Datasets <in_memory_datasets.html>`_.