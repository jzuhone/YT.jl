.. _data-containers:

Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer`` objects:
physically meaningful spatial objects that contain cells or particles with field data. ``jt``
implements a number of the data container objects available in ``yt``,
and attempts to match the API of these objects as closely as possible. All of these objects can
be created from a ``Dataset`` object, typically with some additional information supplied.

Supplying ``Length`` and ``Center`` Type Arguments to Data Containers
---------------------------------------------------------------------

A general note will be helpful before diving into the various ``DataContainer`` objects that are
available. Special ``Union`` types, ``Length`` and ``Center``, have been defined for the various
methods below for creating different objects.

A ``Length``-type argument is for length quantities such as ``radius`` or ``height`` and can be
one of the following:

  * A ``Real`` number. If so, the assumed units are ``"code_length"``.
  * A ``(value, unit)`` tuple, e.g., ``(1.5,"Mpc")``.
  * A ``YTQuantity``.

A ``Center``-type argument is for the ``center`` of an object and can be one of the following:

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

  function Sphere(ds::Dataset, center::Center, radius::Length; args...)

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

  function Region(ds::Dataset, left_edge::Union(YTArray,Array),
                    right_edge::Union(YTArray,Array); args...)

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

  function Disk(ds::Dataset, center::Center, normal::Array, radius::Length,
                  height::Length; args...)

.. code-block:: jlcon

  dk = jt.Disk(ds)

.. _ray:

Ray
+++

A ``Ray`` is a 1-dimensional object that starts at the ``start_point`` in ``code_length`` units
and ends at the ``end_point`` in ``code_length`` units.

.. code-block:: julia

  function Ray(ds::Dataset, start_point::Array, end_point::Array; args...)

Examples:

.. code-block:: jlcon

  julia> ray = Ray(ds, [0.0,0.0,0.0], [3.0e23,3.0e23,3.0e23])

.. _slice:

Slice
+++++

A ``Slice`` is a 2-dimensional slice perpendicular to an ``axis`` (which can be either a
string, ``"x"``,``"y"``,``"z"``, or an integer, 0,1,2) centered at some coordinate
``coord`` along that axis in ``code_length`` units.

.. code-block:: julia

  function Slice(ds::Dataset, axis::Union(Integer,String),
                   coord::Real; args...)

Examples:

.. code-block:: jlcon

  julia> slc = jt.Slice(ds, 2, 0.0)

.. _proj:

Proj
++++

A ``Proj`` is an integral of a given quantity along a sight line.

.. code-block:: julia

  function Proj(ds::Dataset, field, axis::Union(Integer,String);
                  weight_field=nothing, data_source=nothing, args...)

.. _cutting:

Cutting
+++++++

A ``Cutting`` is a 2-dimensional slice perpendicular to an arbitrary ``normal`` vector centered
at some ``center`` coordinate.

.. code-block:: julia

  function Cutting(ds::Dataset, normal::Array, center::Center; args...)

Examples:

.. code-block:: jlcon

  julia> ct = jt.Cutting(ds, [1.0,0.2,-0.3], "c")

.. code-block:: jlcon

  julia> ct = jt.Cutting(ds, [-1.0,3.0,-4.0], [3.0e23,1.0e23,0.0])

.. code-block:: jlcon

  julia> c = jt.YTArray([100.,100.,100], "kpc")
  
  julia> ct = jt.Cutting(ds, [1.0,1.0,1.0], c)

The ``normal`` vector will be normalized to unity if it isn't already.

.. _cut_region:

CutRegion
+++++++++

A ``CutRegion`` is a subset of another ``DataContainer`` ``dc``,
which is determined by an array of boolean ``conditions`` on fields in the container.

.. code-block:: julia

  function CutRegion(dc::DataContainer, conditions::Array)

Examples:

.. code-block:: jlcon

  julia>

.. _covering_grid:

CoveringGrid
++++++++++++

.. _grids:

Grids
+++++

.. _accessing_container_data:

Accessing the Data Within Containers
------------------------------------

Data can be accessed from containers in ``Dict``-like fashion, the same way as in ``yt``:

.. code-block:: jlcon

  julia> sp["density"]
  325405-element YTArray (g/cm**3):
   1.2992312619628604e-26
   1.2946242834614906e-26
   1.3086558386643183e-26
   1.28922012403754e-26
   1.3036428741306716e-26
   1.2999706649871096e-26
   1.3180126226317337e-26
   1.2829197138546694e-26
   1.297694215792844e-26
   1.2945722063157944e-26
   ⋮
   1.6265898946277187e-26
   1.6606648338733776e-26
   1.649533421018006e-26
   1.6093269371270004e-26
   1.64592576904618e-26
   1.606223724726208e-26
   1.6415200117053996e-26
   1.622938177378765e-26
   1.6194386856326155e-26
   1.595660076018442e-26

You can also specify a field names as a ``ftype, fname`` tuple, where the first string is the
field type. The ``"density"`` field has a field type of ``"gas"``:

.. code-block:: jlcon

  julia> sp["gas","density"]
  325405-element YTArray (g/cm**3):
   1.2992312619628604e-26
   1.2946242834614906e-26
   1.3086558386643183e-26
   1.28922012403754e-26
   1.3036428741306716e-26
   1.2999706649871096e-26
   1.3180126226317337e-26
   1.2829197138546694e-26
   1.297694215792844e-26
   1.2945722063157944e-26
   ⋮
   1.6265898946277187e-26
   1.6606648338733776e-26
   1.649533421018006e-26
   1.6093269371270004e-26
   1.64592576904618e-26
   1.606223724726208e-26
   1.6415200117053996e-26
   1.622938177378765e-26
   1.6194386856326155e-26
   1.595660076018442e-26

whereas you could get at the original FLASH field like this:

.. code-block:: jlcon

  julia> sp["flash","dens"]
  325405-element YTArray (code_mass/code_length**3):
   1.2992312619628604e-26
   1.2946242834614906e-26
   1.3086558386643183e-26
   1.28922012403754e-26
   1.3036428741306716e-26
   1.2999706649871096e-26
   1.3180126226317337e-26
   1.2829197138546694e-26
   1.297694215792844e-26
   1.2945722063157944e-26
   ⋮
   1.6265898946277187e-26
   1.6606648338733776e-26
   1.649533421018006e-26
   1.6093269371270004e-26
   1.64592576904618e-26
   1.606223724726208e-26
   1.6415200117053996e-26
   1.622938177378765e-26
   1.6194386856326155e-26
   1.595660076018442e-26

which in the case of FLASH datasets is trivial because code units are equivalent to cgs units.

.. _field_parameters:

Field Parameters
----------------

