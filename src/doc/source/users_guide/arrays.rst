Arrays, Quantities, and Units
=============================

Whenever jt returns physical data, it is typically associated with certain units (e.g., density in grams per
cubic centimeter, temperature in Kelvin, and so on). jt exposes yt's ``YTArray``, ``YTQuantity``, and units
facilities so that unitful objects may be manipulated and operated on.

Arrays
------

If we grab the ``"density"`` field from a sphere, it will be returned as a ``YTArray`` in :math:`\rm{g}/\rm{cm}^3`:

.. code-block:: julia

    julia> sp = Sphere(ds, "c", (100.,"kpc"))
    YTSphere (sloshing_nomag2_hdf5_plt_cnt_0100): center=[ 0.  0.  0.] code_length, radius=100.0 kpc

    julia> sp["density"]
    YTArray [ 1.3086558386643183e-26, 1.28922012403754e-26, 1.3036428741306716e-26,  ...
	         1.6194386856326155e-26, 1.6152527924542866e-26, 1.595660076018442e-26 ] g/cm**3

A ``YTArray`` can be manipulated in many of the same ways that normal Julia arrays are, and the units are retained.

Examples:

Finding the maximum density:

.. code-block:: julia

    julia> maximum(sp["density"])
    9.256136409265674e-26 g/cm**3

Multiplying the temperature by a constant unitless number:

.. code-block:: julia

    julia> sp["temperature"]*5
    YTArray [ 4.41628e8, 4.4457548e8, 4.4363016e8,  ...
	         3.390078e8, 3.369208e8, 3.4209352e8 ] K

Multiplying element-wise one ``YTArray`` by another:

.. code-block:: julia

    julia> sp["density"].*sp["temperature"]
    YTArray [ 1.1558781214352911e-18, 1.1463113109392978e-18, 1.1566705936668994e-18,  ...
	         1.0980046921024092e-18, 1.0884245260718644e-18, 1.0917299442572327e-18 ] K*g/cm**3

However, attempting to perform an operation that doesn't make sense will throw an error. For example, suppose that
you tried to instead `add` ``"density"`` and ``"temperature"``, which aren't the same type of physical quantity:

.. code-block:: julia

    julia> sp["density"]+sp["temperature"]
    ERROR: Not in the same dimensions!
     in + at /Users/jzuhone/.julia/jt/src/yt_array.jl:68

Quantities
----------

A ``YTQuantity`` is just a scalar version of a ``YTArray``. They can be manipulated in the same way:

.. code-block:: julia

    julia>

Changing units
--------------

Occasionally you will want to change the units of an array or quantity to something more appropriate. Taking density
as the example, we can change it to units of solar masses per kiloparsec:

.. code-block:: julia

    julia> a = in_units(sp["density"], "Msun/kpc**3")
    YTArray [ 193361.43661723754, 190489.69785225237, 192620.74223809008,  ...
	         239281.3920328031, 238662.9022094481, 235767.96552301125 ] Msun/kpc**3

We can switch back to cgs units rather easily:

.. code-block:: julia

    julia> in_cgs(a)
    YTArray [ 1.3086558386643183e-26, 1.28922012403754e-26, 1.303642874130672e-26,  ...
	         1.6194386856326155e-26, 1.6152527924542868e-26, 1.595660076018442e-26 ] g/cm**3

Unit Objects
------------

Physical Constants
------------------

Some of yt's physical constants are represented in jt. They are available via the ``physical_constants``
module, and are unitful quantities which can be used with other quantities and arrays:

.. code-block:: julia

    julia> kb = jt.physical_constants.kboltz # Boltzmann constant
    1.3806488e-16 erg/K

    julia> kT = in_units(kb*sp["temperature"], "keV") # computing kT in kilo-electronvolts
    YTArray [ 7.611310547262892, 7.66210937707406, 7.645817103743251,  ...
	         5.842685798328886, 5.806717052886709, 5.895867148202309 ] keV
