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

To create a ``Sphere``, a ``center`` and a ``radius`` should be supplied.

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

.. code-block:: jlcon

  reg = jt.Region(ds)

.. _disk:

Disks
+++++

.. code-block:: jlcon

  dk = jt.Disk(ds)

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

Field Parameters
----------------

