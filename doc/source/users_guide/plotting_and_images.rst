.. _plotting-and-images:

.. |yt_plotting_docs| replace:: ``yt`` plotting documentation
.. _yt_plotting_docs: http://yt-project.org/doc

Plotting and Images
===================

.. _plots:

Plots
-----

``jt`` provides an interface to the most common plotting routines in ``yt``: ``SlicePlot``,
``ProjectionPlot``, ``ProfilePlot``, and ``PhasePlot``:

.. code-block:: julia

    function SlicePlot(ds::Dataset, axis, fields; center="c", args...)

    function ProjectionPlot(ds::Dataset, axis, fields; center="c", data_source=nothing, args...)

    function PhasePlot(dc::DataContainer, x_field, y_field, z_fields; args...)

    function ProfilePlot(dc::DataContainer, x_field, y_fields; args...)

Unlike other methods in ``jt``, these return the native ``yt`` Python-based objects. This is
mainly for convenience; it allows one to use all of the annotation and plot modification methods
that hang off these objects. The API for these objects is the same as it is in ``yt``,
which can be found in the |yt_plotting_docs|_.

We'll illustrate the plotting functionality with a ``SlicePlot`` as an example:

.. code-block:: jlcon

    julia> slc = jt.SlicePlot(ds, "z", ["density","temperature"], width=(500.,"kpc"))

.. image:: ../images/slice_density.png

.. image:: ../images/slice_temperature.png

which produces a ``SlicePlot`` ``PyObject`` of the ``fields`` "density" and "temperature",
along the "z" ``axis``. The ``SlicePlot`` object has available to it all of the methods for
annotating the plot that one would have access to in ``yt``. For example, one can annotate grids:

.. code-block:: jlcon

    julia> slc.annotate_grids()

.. image:: ../images/slice_density_grids.png

.. image:: ../images/slice_temperature_grids.png

or velocity vectors:

.. code-block:: jlcon

    julia> slc.annotate_velocity()

.. image:: ../images/slice_density_velocity.png

.. image:: ../images/slice_temperature_velocity.png

Logging can be set for specific fields:

.. code-block:: jlcon

    julia> slc.set_log("temperature", false)

.. image:: ../images/slice_temperature_linear.png

or the colormap can be changed:

.. code-block:: jlcon

    julia> slc.set_cmap("density", "kamae")

.. image:: ../images/slice_density_colormap.png

.. code-block:: jlcon

To save a plot:

.. code-block:: jlcon

    julia> slc.save("my_awesome_plot.png")
    
If one is in the `IJulia notebook <http://github.com/JuliaLang/IJulia.jl>`_, the ``show_plot``
method can be used to display the plot inline:

.. code-block:: jlcon

    julia> jt.show_plot(slc)

Similar options exist for the other plotting methods. The full set of options for these plots can
be found in the |yt_plotting_docs|_.

.. _images:

Images
------

To create a raw 2D image from a ``Slice`` or ``Proj`` object,
one can create a ``FixedResolutionBuffer`` object using the ``to_frb`` method:

.. code-block:: julia

    function to_frb(cont::Union(Slice,Proj), width::Union(Length,(Length,Length)),
                    nx::Union(Integer,(Integer,Integer)); args...)

where ``cont`` is the ``Slice`` or ``Proj`` object, ``width`` is the width of the plot,
and ``nx`` is the resolution of the plot. Both the ``width`` and the resolution ``nx`` can
either be a single value or a tuple of two values, depending on how you want to set the width and
height. This is an example of how to create a ``FixedResolutionBuffer`` from a ``Slice``:

.. code-block:: jlcon

    julia> slc = jt.Slice(ds, "z", 0.0)
    YTSlice (sloshing_nomag2_hdf5_plt_cnt_0100): axis=2, coord=0.0

    julia> frb = jt.to_frb(slc, (500.,"kpc"), 800)
    FixedResolutionBuffer (800x800):
        -7.714193952405812e23 code_length <= x < 7.714193952405812e23 code_length
        -7.714193952405812e23 code_length <= y < 7.714193952405812e23 code_length

which can be plotted with a plotting package such as
`PyPlot <http://github.com/stevengj/PyPlot.jl>`_ or `Winston <http://github.com/nolta/Winston.jl>`_:

.. code-block:: jlcon

    julia> using Winston

    julia> imagesc(frb["kT"].value)

which yields the following image:

.. image:: ../images/winston.png