Datasets
========

The most basic ``jt`` object is the ``Dataset``. This is a collection of volumetric data that may be stored on disk,
or created in-memory. To load a ``Dataset`` from disk, we use ``load``:

.. code-block:: julia

    julia> ds = load("sloshing_nomag2_hdf5_plt_cnt_0100")
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

Where you can see that the ``yt`` log is being outputted. The ``Dataset`` object ``ds`` now contains all of the basic metadata about the data stored in the file
``"sloshing_nomag2_hdf5_plt_cnt_0100"``. Attached to ``ds`` are several useful attributes, as well as a number of
methods for creating ```DataContainers``.

Parameters
----------

Each simulation ``Dataset`` normally has a number of runtime parameters associated with it. This is stored in a
dictionary:

.. code-block:: julia

    julia> ds.parameters
    ["min_particles_per_blk"=>1,"zmax"=>3.70272e24,"maxcondentr"=>1000.0,"usemassdiffusivity"=>0,
    ...

At this time, the parameters dictionary does not return unitful quantities.

Index
-----

The index is

``print_stats`` may be used to get a quick synopsis of the structure of the ``Dataset``. In this case,
it is a FLASH AMR ``Dataset``, so statistics regarding the grids and cells are printed:

.. code-block:: julia

    julia> print_stats(ds.index)
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