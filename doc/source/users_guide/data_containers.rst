.. _data-containers:

Data Containers
===============

The most useful methods for ``Datasets`` are those that create ``DataContainer`` objects:
physically meaningful spatial objects that contain cells or particles with field data. ``YT``
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

  * A ``FloatingPoint`` number. If so, the assumed units are ``"code_length"``.
  * A ``(FloatingPoint, ASCIIString)`` tuple, e.g., ``(1.5, "Mpc")``.
  * A ``YTQuantity``.

A ``Center``-type argument is for the ``center`` of an object and can be one of the following:

  * An ``ASCIIString``, e.g., ``"max"`` (or ``"m"``), ``"center"`` (or ``"c"``),
    corresponding to the point with maximum density and the center of the domain, respectively.
  * A ``(ASCIIString, ASCIIString)`` tuple, e.g. ``("min", "temperature")``,
    or ``("max","velocity_x")``, corresponding to maxima and minima of specific fields.
  * An ``Array`` of ``FloatingPoint`` numbers. If so, the assumed units are ``"code_length"``.
  * A ``YTArray``.

.. |yt_cont_docs| replace:: ``yt`` Documentation on data container objects
.. _yt_cont_docs: http://yt-project.org/docs/3.0/analyzing/objects.html

.. |yt_fp_docs| replace:: ``yt`` Documentation on field parameters
.. _yt_fp_docs: http://yt-project.org/doc/analyzing/fields.html#field-parameters

.. note::

  While in the Julia REPL, you can find out information about the different ``DataContainer``\ s
  by checking its docstring with ``@doc AllData`` or using the help system with ``?``. To see
  how to call the constructor for a ``DataContainer``, use ``methods``, e.g. ``methods(Sphere)``.

Available Data Containers
-------------------------

.. _all_data:

All Data
++++++++

The simplest data container is one that represents all of the data in the ``Dataset``. It requires
no parameters to create, except the ``Dataset`` object:

.. code-block:: julia

  function AllData(ds::Dataset; field_parameters=nothing,
                   data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> dd = YT.AllData(ds)

.. _point:

Point
+++++

The ``Point`` data container represents the data at a single point in the computational domain,
located at a coordinate ``coord`` in units of ``code_length``:

.. code-block:: julia

  function Point(ds::Dataset, coord::Array{Float64,1}; 
                 field_parameters=nothing,
                 data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> p = YT.Point(ds, [3.0e22,0,-1.0e23])

.. _sphere:

Sphere
++++++

A ``Sphere`` is an object with a ``center`` and a ``radius``.

.. code-block:: julia

  function Sphere(ds::Dataset, center::Center, radius::Length; 
                  field_parameters=nothing,
                  data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> sp = YT.Sphere(ds, "max", (100.,"kpc"))

.. code-block:: jlcon

  julia> R = YT.YTQuantity(200.,"kpc")

  julia> sp = YT.Sphere(ds, [0.0,0.0,0.0], R)

.. _region:

Region
++++++

A ``Region`` is a rectangular prism with a ``left_edge``, a ``right_edge``, and a ``center``
(that can be anywhere in the domain). The edges can be ``YTArray``\ s,
or ``Array``\ s of ``Float64``\ s, in which case they will be assumed to be in units of
``code_length``.

.. code-block:: julia

  function Region(ds::Dataset, center::Center,
                  left_edge::Union(YTArray,Array{Float64,1}),
                  right_edge::Union(YTArray,Array{Float64,1}); 
                  field_parameters=nothing,
                  data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> reg = YT.Region(ds, "c", [-3.0e23,-3.0e23,-3.0e23], [3.0e23,3.0e23, 3.0e23])

.. code-block:: jlcon

  julia> a = YT.YTArray([-0.5,-0.2,-0.3], "unitary")

  julia> b = YT.YTArray([0.4,0.1,0.4], "unitary")

  julia> reg = YT.Region(ds, [0.0,0.0,0.0], a, b)

.. _disk:

Disk
++++

A ``Disk`` is a disk or cylinder-shaped region with the z-axis of the cylinder pointing along a
``normal`` vector, with a ``radius``, a ``center``, and a ``height``:

.. code-block:: julia

  function Disk(ds::Dataset, center::Center, normal::Array{Float64,1},
                radius::Length, height::Length; f
                field_parameters=nothing,
                data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> dk = YT.Disk(ds, "c", [1.0,0.2,-0.3], (100,"kpc"), (0.5,"Mpc"))

.. _ray:

Ray
+++

A ``Ray`` is a 1-dimensional object that starts at the ``start_point`` in ``code_length`` units
and ends at the ``end_point`` in ``code_length`` units.

.. code-block:: julia

  function Ray(ds::Dataset, start_point::Array{Float64,1},
               end_point::Array{Float64,1};
               field_parameters=nothing,
               data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> ray = Ray(ds, [0.0,0.0,0.0], [3.0e23,3.0e23,3.0e23])

.. _ortho_ray:

OrthoRay
++++++++

An ``OrthoRay`` is a 1-dimensional object along an ``axis``
through a coordinate pair ``coords`` which corresponds to the
point (in code units) on the other two axes which the ``OrthoRay``
goes through.

.. code-block:: julia

  function OrthoRay(ds::Dataset, axis::Integer, coords::(Float64,Float64),
                    field_parameters=nothing, data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> ortho_ray = OrthoRay(ds, 0, [1.0e23,-2.0e22])

.. _slice:

Slice
+++++

A ``Slice`` is a 2-dimensional slice perpendicular to an ``axis``, which can be either a
string ("x","y","z") or an integer (0,1,2), centered at some coordinate
``coord`` along that axis in ``code_length`` units.

.. code-block:: julia

  function Slice(ds::Dataset, axis::Union(Integer,String),
                 coord::FloatingPoint;
                 field_parameters=nothing,
                 data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> slc = YT.Slice(ds, 2, 0.0)

.. _proj:

Proj
++++

A ``Proj`` is an integral of a given ``field`` along a sight line corresponding to ``axis``.

.. code-block:: julia

  function Proj(ds::Dataset, field, axis::Union(Integer,String);
                weight_field=nothing, data_source=nothing,
                field_parameters=nothing, method=nothing)

The optional argument ``weight_field`` (a field name) allows the projection to be weighted.
The optional argument ``method`` selects the projection method type:
* "integrate" : integration along the axis
* "mip" : maximum intensity projection
* "sum" : same as "integrate", except that we don't multiply by the path length

.. warning::

  The "sum" option should only be used for uniform resolution grid
  datasets, as other datasets may result in unphysical images.

Examples:

.. code-block:: jlcon

  julia> prj = YT.Proj(ds, "density", "z")

.. code-block:: jlcon

  julia> sp = YT.Sphere(ds, "max", (100.,"kpc"))

  julia> prj = YT.Proj(ds, "temperature", 1, weight_field="density", data_source=sp)

.. _cutting:

Cutting
+++++++

A ``Cutting`` is a 2-dimensional slice perpendicular to an arbitrary ``normal`` vector centered
at some ``center`` coordinate.

.. code-block:: julia

  function Cutting(ds::Dataset, normal::Array{Float64,1}, center::Center;
                   field_parameters=nothing, data_source=nothing)

Examples:

.. code-block:: jlcon

  julia> ct = YT.Cutting(ds, [1.0,0.2,-0.3], "c")

.. code-block:: jlcon

  julia> ct = YT.Cutting(ds, [-1.0,3.0,-4.0], [3.0e23,1.0e23,0.0])

.. code-block:: jlcon

  julia> c = YT.YTArray([100.,100.,100], "kpc")

  julia> ct = YT.Cutting(ds, [1.0,1.0,1.0], c)

The ``normal`` vector will be normalized to unity if it isn't already.

.. _cut_region:

CutRegion
+++++++++

A ``CutRegion`` is a subset of another ``DataContainer`` ``dc``,
which is determined by an array of ``conditionals`` on fields in the container.

.. code-block:: julia

  function CutRegion(dc::DataContainer,
                     conditionals::Array{ASCIIString,1}
                     data_source=nothing,
                     field_parameters=nothing)

``conditionals`` is a list of conditionals that will be evaluated. In the namespace available,
these conditionals will have access to ‘obj’ which is a data object of unknown shape, and they
must generate a boolean array. For instance, ``conditionals = [“obj[‘temperature’] < 1e3”]``

Examples:

.. code-block:: jlcon

  julia> sp = YT.Sphere(ds, "max", (100.,"kpc"))

  julia> cr = YT.CutRegion(sp, ["obj['temperature'] > 4.0e7", "obj['temperature'] < 5.0e7"])

where it can be easily verified that this produces a ``DataContainer`` with ``"temperature"`` in
between those limits:

.. code-block:: jlcon

  julia> minimum(cr["temperature"])
  4.0000196e7 K

  julia> maximum(cr["temperature"])
  4.9999116e7 K

.. _covering_grid:

CoveringGrid
++++++++++++

A ``CoveringGrid`` is a 3D ``DataContainer`` of cells extracted at a fixed resolution.

.. code-block:: julia

  function CoveringGrid(ds::Dataset, level::Integer, left_edge::Array{Float64,1}, 
                        dims::Array{Int,1}; field_parameters=nothing)

``level`` is the refinement level at which to extract the data, ``left_edge`` is the left edge of
the grid in ``code_length`` units, and ``dims`` is the number of cells on a side.

Examples:

.. code-block:: jlcon

  julia> cg = YT.CoveringGrid(ds, 5, [-3.0856e23,-3.0856e23,-3.0856e23], [64,64,64])

The fields of this ``DataContainer`` are 3D ``YTArray``\ s:

.. code-block:: jlcon

  julia> cg["velocity_x"]
  64x64x64 YTArray (cm/s):
   [:, :, 1] =
   -9.45944e6  -9.22163e6  -8.97506e6  …       -4.54556e6       -5.2798e6
   -9.64798e6  -9.40576e6  -9.14971e6          -4.38682e6       -5.13215e6
   -9.82901e6  -9.57772e6  -9.30941e6          -4.25022e6       -5.00537e6
   -9.9932e6   -9.72978e6  -9.45173e6          -4.13942e6       -4.90191e6
   -1.01421e7  -9.86609e6  -9.57824e6          -4.04788e6       -4.81652e6
   -1.02767e7  -9.99092e6  -9.69512e6  …       -3.98365e6       -4.75448e6
   -1.03932e7  -1.01006e7  -9.79921e6          -3.9392e6        -4.71177e6
   -1.04856e7  -1.01875e7  -9.87844e6          -3.92483e6       -4.69586e6
   -1.05589e7  -1.02484e7  -9.92279e6          -3.93876e6       -4.70134e6
   -1.06159e7  -1.0293e7   -9.94764e6          -3.98234e6       -4.73101e6
   -1.06488e7  -1.03028e7  -9.94144e6  …       -4.05713e6       -4.79151e6
   -1.06532e7  -1.02881e7  -9.90535e6          -4.1667e6        -4.88172e6
   -1.06367e7  -1.0246e7   -9.84756e6          -4.30115e6       -4.99339e6
    ⋮                                  ⋱
   -1.07594e7  -1.00079e7  -9.23378e6          -2.4916e6        -2.63372e6
   -1.10205e7  -1.02792e7  -9.51947e6          -1.95956e6       -2.26497e6
   -1.12805e7  -1.05476e7  -9.79831e6          -1.95956e6       -2.26497e6
   -1.15351e7  -1.08149e7  -1.0073e7   …       -1.24862e6       -1.56333e6
   -1.17823e7  -1.10766e7  -1.03451e7          -1.24862e6       -1.56333e6
   -1.20202e7  -1.13275e7  -1.06126e7          -567435.0        -850258.0
   -1.22529e7  -1.15684e7  -1.08709e7          -567435.0        -850258.0
   -1.24835e7  -1.18055e7  -1.11232e7            26094.7        -200632.0
   -1.27079e7  -1.20408e7  -1.13734e7  …         26094.7        -200632.0
   -1.2922e7   -1.22686e7  -1.16157e7           537401.0         358841.0
   -1.31273e7  -1.24859e7  -1.1844e7            537401.0         358841.0
   -1.33282e7  -1.26955e7  -1.20595e7           973392.0         829474.0

   ...

.. _grids:

Grids
+++++

If your simulation is grid-based, you can also get at the data in the individual grids using the
``Grids`` object:

.. code-block:: julia

  function Grids(ds::Dataset)

``Grids`` objects are ``Array``\ s, so the ``length()`` can be determined and they can be indexed.
You can access the individual fields of a single ``Grid`` object as well:

.. code-block:: jlcon

  julia> grids = Grids(ds)
  [ FLASHGrid_0001 ([16 16 16]),
    FLASHGrid_0002 ([16 16 16]),
    FLASHGrid_0003 ([16 16 16]),
    FLASHGrid_0004 ([16 16 16]),
    ...
    FLASHGrid_1350 ([16 16 16]),
    FLASHGrid_1351 ([16 16 16]),
    FLASHGrid_1352 ([16 16 16]),
    FLASHGrid_1353 ([16 16 16]) ]

  julia> length(grids)
  1353

  julia> my_grid = grids[1000]
  FLASHGrid_1000 ([16 16 16])

  julia> my_grid["velocity_x"]
  16x16x16 YTArray (cm/s):
  [:, :, 1] =
       -1.2075387e7         -1.241014e7     …       -1.4580984e7
       -1.021574e7          -1.0516409e7            -1.2799518e7
       -8.3335155e6         -8.598048e6             -1.124706e7
       -6.415593e6          -6.70807e6              -9.730029e6
       -4.564453e6          -4.8659225e6            -8.137291e6
       -2.8466195e6         -3.1491e6       …       -6.434752e6
       -1.0172061875e6      -1.354249625e6          -4.6243535e6
        888777.875           529686.875             -2.786557e6
        3.043072e6           2.6330015e6            -957876.25
        5.1807975e6          4.7515225e6             861985.0
        7.287667e6           6.905605e6     …        2.82106475e6
        9.428427e6           9.098705e6              4.970872e6
        1.1547637e7          1.1276032e7             7.188712e6
        1.3600865e7          1.3346243e7             9.288022e6
        1.5679473e7          1.5354482e7             1.1403412e7
        1.7878244e7          1.7464842e7    …        1.3652711e7
  ...

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

Some complex fields rely on "field parameters" in their definitions. Field parameters can be
literally anything, including strings, integers, real numbers, ``YTArray``\ s,
etc. To set a field parameter for a particular ``DataContainer``, use ``set_field_parameter``:

.. code-block:: jlcon

  julia> sp = YT.Sphere(ds, "max", (100.,"kpc"))

  julia> bulk_velocity = YT.YTArray(ds, [100.,-200.,300.], "km/s")

  julia> YT.set_field_parameter(sp, "bulk_velocity", bulk_velocity)

Similarly, ``get_field_parameter`` returns a specific parameter based on its key:

.. code-block:: jlcon

  julia> YT.get_field_parameter(sp, "bulk_velocity")
  3-element YTArray (km/s):
    100.0
   -200.0
    300.0

``has_field_parameter`` can be used to check for the existence of a parameter:

.. code-block:: jlcon

  julia> YT.has_field_parameter(sp, "center")
  true

To get a dictionary containing all of the field parameters for a dataset,
use ``get_field_parameters``:

.. code-block:: jlcon

  julia> fp = YT.get_field_parameters(sp)

  julia> fp["center"]
  3-element YTArray (code_length):
   -1.08478e22
    3.61594e21
    3.61594e21

For more information about field parameters, consult the |yt_fp_docs|_.
