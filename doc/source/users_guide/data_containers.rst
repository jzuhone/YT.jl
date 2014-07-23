.. _data-containers:

Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer`` objects:
physically meaningful spatial objects that represent the cells or particles within


.. _all-data:

All Data
--------

The simplest data container is one that represents all of the data in the ``Dataset``. It requires
no parameters to create.

.. code-block:: julia

  dd = AllData(ds)

.. _spheres:

Spheres
-------

.. code-block:: julia

  sp = Sphere(ds)


.. _regions:

Regions
-------

.. code-block:: julia

  reg = Region(ds)

.. _disks:

Disks
-----

.. code-block:: julia

  dk = Disk(ds)

.. _slices:

Slices
------

.. _projections:

Projections
-----------

.. _cut-regions:

Cut Regions
-----------

