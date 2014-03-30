Datasets
========

The most basic ``jt`` object is the ``Dataset``. This is a collection of volumetric data that may be stored on disk,
or created in-memory. To load a ``Dataset`` from disk, we use ``load``:

.. code-block:: julia

    ds = load("sloshing_nomag2_hdf5_plt_cnt_0100")

The ``Dataset`` object ``ds`` now contains all of the basic metadata about the data stored in the file
``"sloshing_nomag2_hdf5_plt_cnt_0100"``.

