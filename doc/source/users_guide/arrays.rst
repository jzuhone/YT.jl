.. _arrays-quantities-units:

Arrays, Quantities, and Units
=============================

Whenever ``jt`` returns physical data, it is typically associated with certain units (e.g.,
density in grams per cubic centimeter, temperature in Kelvin, and so on). ``jt`` exposes the
``YTArray``, ``YTQuantity``, and units facilities from ``yt`` so that "unitful" objects may be
manipulated and operated on.

.. _arrays:

Arrays
------

If we grab the ``"density"`` field from a sphere, it will be returned as a ``YTArray`` in
:math:`\rm{g}/\rm{cm}^3`:

.. code-block:: julia

    julia> sp = jt.Sphere(ds, "c", (100.,"kpc"))
    YTSphere (sloshing_nomag2_hdf5_plt_cnt_0100): center=[ 0.  0.  0.] code_length,
    radius=100.0 kpc

    julia> sp["density"]
    325184-element YTArray (g/cm**3):
     1.3086558386643183e-26
     1.28922012403754e-26
     1.3036428741306716e-26
     1.2999706649871096e-26
     1.3180126226317337e-26
     1.2829197138546694e-26
     1.297694215792844e-26
     1.2945722063157944e-26
     1.3124175650316954e-26
     1.3088245501274466e-26
     ⋮
     1.6093269371270004e-26
     1.64592576904618e-26
     1.606223724726208e-26
     1.6415200117053996e-26
     1.635422055278283e-26
     1.622938177378765e-26
     1.5840914000284966e-26
     1.6194386856326155e-26
     1.6152527924542866e-26
     1.595660076018442e-26

A ``YTArray`` can be manipulated in many of the same ways that normal Julia arrays are, and the
units are retained. The following are some simple examples of this.

Finding the maximum density:

.. code-block:: julia

    julia> maximum(sp["density"])
    9.256136409265674e-26 g/cm**3

Multiplying the temperature by a constant unitless number:

.. code-block:: julia

    julia> sp["temperature"]*5
    325184-element YTArray (K):
     4.41628e8
     4.4457548e8
     4.4363016e8
     4.4104716e8
     4.4259016e8
     4.464104e8
     4.4553836e8
     4.429778e8
     4.4458e8
     4.4192136e8
     ⋮
     3.42009e8
     3.3811488e8
     3.3988892e8
     3.3605176e8
     3.341696e8
     3.410656e8
     3.4288464e8
     3.390078e8
     3.369208e8
     3.4209352e8

Adding two ``YTArrays``:

.. code-block:: julia

    julia> sp["velocity_magnitude"]+sp["sound_speed"]
    325184-element YTArray (cm/s):
     1.7494106880789694e8
     1.750480854794736e8
     1.7491905482683247e8
     1.7463744560410416e8
     1.7477896725137833e8
     1.7498621058854717e8
     1.7486426825557864e8
     1.7463176707801563e8
     1.7473392939487094e8
     1.7449670611457497e8
     ⋮
     1.4691744928089392e8
     1.448218647261667e8
     1.4619022766526273e8
     1.4414687202610317e8
     1.4354279490019822e8
     1.4629026827881128e8
     1.4767689116216296e8
     1.45570568978103e8
     1.4486893148240653e8
     1.471462895473701e8

Multiplying element-wise one ``YTArray`` by another:

.. code-block:: julia

    julia> sp["density"].*sp["temperature"]
    325184-element YTArray (K*g/cm**3):
     1.1558781214352911e-18
     1.1463113109392978e-18
     1.1566705936668994e-18
     1.1466967397517522e-18
     1.1666788350651973e-18
     1.145417405259497e-18
     1.1563451053716595e-18
     1.1469334957898334e-18
     1.1669492021235823e-18
     1.1567950503874187e-18
     ⋮
     1.1008085928797365e-18
     1.1130239877799136e-18
     1.0918752941511363e-18
     1.1032713780176403e-18
     1.0930166680870434e-18
     1.1070567664611898e-18
     1.0863212188517341e-18
     1.0980046921024092e-18
     1.0884245260718644e-18
     1.0917299442572327e-18

However, attempting to perform an operation that doesn't make sense will throw an error. For
example, suppose that you tried to instead `add` ``"density"`` and ``"temperature"``,
which aren't the same type of physical quantity:

.. code-block:: julia

    julia> sp["density"]+sp["temperature"]
    ERROR: The + operator for YTArrays with units (g/cm**3) and (K) is not well defined.
     in + at /Users/jzuhone/.julia/jt/src/array.jl:143

It is also possible to create a ``YTArray`` from a regular Julia ``Array``, like so:

.. code-block:: julia

    julia> a = YTArray(randn(10), "erg")
    10-element YTArray (erg):
     -0.14854525691731818
     -0.44315729646073715
     -1.8669284316708383
     -1.4228733016999084
     -0.0934020019569414
      0.029660552522097813
      0.4280709348298647
     -0.05755731738462625
      1.032874362011772
      0.17854214710697325

If your ``YTArray`` needs to know about code units associated with a specific dataset,
you'll have to create it with a ``Dataset`` object passed in:

.. code-block:: julia

    julia> a = YTArray(ds, [1.0,1.0,1.0], "code_length")
    3-element YTArray (code_length):
     1.0
     1.0
     1.0

.. _quantities:

Quantities
----------

A ``YTQuantity`` is just a scalar version of a ``YTArray``. They can be manipulated in the same way:

.. code-block:: julia

    julia> a = YTQuantity(3.14159, "radian")
    3.14159 radian

    julia> b = YTQuantity(12, "cm")
    12.0 cm

    julia> a/b
    0.26179916666666664 radian/cm

    julia> a\b
    3.8197218605865184 cm/radian

    julia> c = YTQuantity(13,"m")
    13.0 m

    julia> b+c
    1312.0 cm

    julia> d = YTQuantity(ds, 1.0, "code_length")
    1.0 code_length

.. _changing-units:

Changing Units
--------------

Occasionally you will want to change the units of an array or quantity to something more
appropriate. Taking density as the example, we can change it to units of solar masses per
kiloparsec:

.. code-block:: julia

    julia> a = jt.in_units(sp["density"], "Msun/kpc**3")
    325184-element YTArray (Msun/kpc**3):
     193361.43661723754
     190489.69785225237
     192620.74223809008
     192078.1521891412
     194743.95533346717
     189558.77596412544
     191741.79371078173
     191280.49883112026
     193917.25335152834
     193386.3647075119
     ⋮
     237787.32295826814
     243195.01114436015
     237328.8054548747
     242544.03512482112
     241643.02694502342
     239798.46209161723
     234058.62702232625
     239281.3920328031
     238662.9022094481
     235767.96552301125

We can switch back to cgs units rather easily:

.. code-block:: julia

    julia> jt.in_cgs(a)
    325184-element YTArray (g/cm**3):
     1.3086558386643183e-26
     1.28922012403754e-26
     1.303642874130672e-26
     1.2999706649871096e-26
     1.318012622631734e-26
     1.2829197138546696e-26
     1.297694215792844e-26
     1.2945722063157944e-26
     1.3124175650316954e-26
     1.308824550127447e-26
     ⋮
     1.6093269371270004e-26
     1.64592576904618e-26
     1.606223724726208e-26
     1.6415200117053996e-26
     1.6354220552782833e-26
     1.622938177378765e-26
     1.5840914000284966e-26
     1.6194386856326155e-26
     1.6152527924542868e-26
     1.595660076018442e-26

or to MKS units:

.. code-block:: julia

    julia> jt.in_mks(a)
    325184-element YTArray (kg/m**3):
     1.3086558386643184e-23
     1.2892201240375402e-23
     1.3036428741306718e-23
     1.2999706649871097e-23
     1.3180126226317338e-23
     1.2829197138546696e-23
     1.297694215792844e-23
     1.2945722063157945e-23
     1.3124175650316956e-23
     1.3088245501274467e-23
     ⋮
     1.6093269371270004e-23
     1.64592576904618e-23
     1.6062237247262084e-23
     1.6415200117053996e-23
     1.6354220552782833e-23
     1.6229381773787652e-23
     1.584091400028497e-23
     1.6194386856326155e-23
     1.6152527924542868e-23
     1.595660076018442e-23

.. _physical-constants:

Physical Constants
------------------

Some physical constants are represented in ``jt``. They are available via the
``jt.physical_constants`` submodule, and are unitful quantities which can be used with other
quantities and arrays:

.. code-block:: julia

    julia> kb = jt.physical_constants.kboltz # Boltzmann constant
    1.3806488e-16 erg/K

    julia> kT = jt.in_units(kb*sp["temperature"], "keV") # computing kT in kilo-electronvolts
    325184-element YTArray (keV):
     7.611310547262892
     7.66210937707406
     7.645817103743251
     7.601299964559187
     7.62789305234897
     7.6937336082128995
     7.6787042911187955
     7.634573897812892
     7.662187277758966
     7.616366508529263
     ⋮
     5.8944104743332275
     5.827296621433712
     5.857871606179393
     5.791739439787011
     5.759301043082916
     5.878151291558838
     5.909501836220619
     5.842685798328886
     5.806717052886709
     5.895867148202309