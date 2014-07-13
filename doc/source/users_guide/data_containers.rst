Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer``s: physically
meaningful spatial objects that represent the cells or particles within


All Data
--------

The simplest data container is one that represents all of the data in the ``Dataset``. It requires
no parameters to create.

.. code-block:: julia

  dd = AllData(ds)

Spheres
-------

.. code-block:: julia

  sp = Sphere(ds)



Regions
-------

.. code-block:: julia

  reg = Region(ds)



Disks
-----

.. code-block:: julia

  dk = Disk(ds)

Slices
------

Projections
-----------


Cut Regions
-----------

