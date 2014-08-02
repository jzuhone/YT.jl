.. _data-containers:

Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer`` objects:
physically meaningful spatial objects that contain cells or particles with field data. ``jt``
implements a number of the data container objects available in ``yt``,
and attempts to match the API of these objects as closely as possible. All of these objects can
be created from a ``Dataset`` object, typically with some additional information supplied.

Supplying ``Length`` and ``Coordinate`` Arguments to Data Containers
--------------------------------------------------------------------

A general note will be helpful before diving into the various ``DataContainer`` objects that are
available. ``Length`` and ``Coordinate`` types have been defined for the various methods below for
creating different objects.

A ``Length``-type argument can be one of the following:

  * A ``Real`` number. If so, the assumed units are ``"code_length"``.
  * A ``(value, unit)`` tuple, e.g., ``(1.5,"Mpc")``.
  * A ``YTQuantity``.

A ``Coordinate``-type argument can be one of the following:

  * A ``String``, e.g., ``"max"`` (or ``"m"``), ``"center"`` (or ``"c"``).
  * An ``Array`` of ``Real`` numbers. If so, the assumed units are ``"code_length"``.
  * A ``YTArray``.

.. |yt_cont_docs| replace:: ``yt`` Documentation on data container objects
.. _yt_cont_docs: http://yt-project.org/docs/dev-3.0/analyzing/objects.html

.. note::

  All of the ``DataContainer`` objects take additional optional arguments,
  which are not documented here. Information on these can be found in the |yt_cont_docs|_.

Available Data Containers
-------------------------

.. _all_data:

All Data
++++++++

The simplest data container is one that represents all of the data in the ``Dataset``. It requires
no parameters to create, except the ``Dataset`` object:

.. code-block:: julia

  function AllData(ds::Dataset; args...)

Examples:

.. code-block:: jlcon

  julia> dd = jt.AllData(ds)

.. _sphere:

Sphere
++++++

A ``Sphere`` is an object with a ``center`` and a ``radius``.

.. code-block:: julia

  function Sphere(ds::Dataset, center::Coordinate, radius::Length; args...)

Examples:

.. code-block:: jlcon

  julia> sp = jt.Sphere(ds, "max", (100.,"kpc"))

.. code-block:: jlcon

  julia> R = jt.YTQuantity(200.,"kpc")

  julia> sp = jt.Sphere(ds, [0.0,0.0,0.0], R)

.. _region:

Region
++++++

A ``Region`` is a

.. code-block:: julia

  function Region(ds::Dataset, center::Coordinate, left_edge::Coordinate,
                    right_edge::Coordinate; args...)

Examples:

.. code-block:: jlcon

  julia> reg = jt.Region(ds, "c", [-3.0e23,-3.0e23,-3.0e23], [3.0e23,3.0e23, 3.0e23])

.. code-block:: jlcon

  julia> a = jt.YTArray([-0.5,-0.2,-0.3], "unitary")

  julia> b = jt.YTArray([0.4,0.1,0.4], "unitary")

  julia> reg = jt.Region(ds, [0.0,0.0,0.0], a, b)

.. _disk:

Disk
++++

.. code-block:: julia

  function Disk(ds::Dataset, center::Coordinate, normal::Array, radius::Length,
                  height::Length; args...)

.. code-block:: jlcon

  dk = jt.Disk(ds)

.. _ray:

Ray
+++

A ``Ray`` is a 1-dimensional object that starts at one point in space and ends at another.

.. code-block:: julia

  function Ray(ds::Dataset, start_point::Coordinate, end_point::Coordinate; args...)

.. _slice:

Slice
+++++

.. _proj:

Proj
++++

A ``Proj`` is an integral of a given quantity along a sight line.

.. _cut_region:

CutRegion
+++++++++

Accessing the Data Within Containers
------------------------------------

Data can be accessed from containers in ``Dict``-like fashion, the same way as in ``yt``:

.. code-block:: jlcon

  julia> sp["density"]

You can also specify a field names as a ``ftype, fname`` tuple, where the first string is the
field type. The ``"density"`` field has a field type of ``"gas"``:

.. code-block:: jlcon

  julia> sp["gas","density"]

whereas you could get at the original ``FLASH`` field like this:

.. code-block:: jlcon

  julia> sp["flash","dens"]

Field Parameters
----------------

