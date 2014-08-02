.. _data-containers:

Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer`` objects:
physically meaningful spatial objects that contain cells or particles with field data. ``jt``
implements a number of the data container objects available in ``yt``,
and attempts to match the API of these objects as closely as possible. All of these objects can
be created from a ``Dataset`` object, typically with some additional information supplied.

Supplying ``Length`` and ``Coordinate`` Arguments to Data Containers
------------------------------------------------------------

A general note will be helpful before diving into the various ``DataContainer`` objects that are
available.

Available Data Containers
-------------------------

.. _all-data:

All Data
++++++++

The simplest data container is one that represents all of the data in the ``Dataset``. It requires
no parameters to create, except the ``Dataset`` object:

.. code-block:: jlcon

  dd = jt.AllData(ds)

.. _spheres:

Spheres
+++++++

To create a ``Sphere``, a ``center`` and a ``radius`` should be supplied.


.. code-block:: jlcon

  sp = jt.Sphere(ds)


.. _regions:

Regions
+++++++

.. code-block:: jlcon

  reg = jt.Region(ds)

.. _disks:

Disks
+++++

.. code-block:: jlcon

  dk = jt.Disk(ds)

.. _slices:

Slices
++++++

.. _projections:

Projections
+++++++++++

``Projections`` are integrals of a given quantity along a sight line

.. _cut-regions:

Cut Regions
+++++++++++

Accessing the Data Within Containers
------------------------------------


