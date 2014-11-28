.. _arrays-quantities-units:

Arrays, Quantities, and Units
=============================

Whenever ``YT`` returns physical data, it is typically associated with certain units (e.g.,
density in grams per cubic centimeter, temperature in Kelvin, and so on). ``YT`` exposes the
``YTArray``, ``YTQuantity``, and units facilities from ``yt`` so that "unitful" objects may be
manipulated and operated on.

.. _arrays:

Arrays
------

If we grab the ``"density"`` field from a sphere, it will be returned as a ``YTArray`` in
:math:`\rm{g}/\rm{cm}^3`:

.. code-block:: jlcon

    julia> sp = YT.Sphere(ds, "c", (100.,"kpc"))
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

.. code-block:: jlcon

    julia> maximum(sp["density"])
    9.256136409265674e-26 g/cm**3

Multiplying the temperature by a constant unitless number:

.. code-block:: jlcon

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

.. code-block:: jlcon

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

.. code-block:: jlcon

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

.. code-block:: jlcon

    julia> sp["density"]+sp["temperature"]
    ERROR: The + operator for YTArrays with units
    (g/cm**3) and (K) is not well defined.
     in + at /Users/jzuhone/.julia/YT/src/array.jl:141

It is also possible to create a ``YTArray`` from a regular Julia ``Array``, like so:

.. code-block:: jlcon

    julia> a = YT.YTArray(randn(10), "erg")
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

.. code-block:: jlcon

    julia> a = YT.YTArray(ds, [1.0,1.0,1.0], "code_length")
    3-element YTArray (code_length):
     1.0
     1.0
     1.0

A ``YTArray`` can be saved to an `HDF5 <http://www.hdfgroup.org>`_ file for re-loading later. For this, one can use
``write_hdf5``:

.. code-block:: julia

    function write_hdf5(a::YTArray, filename::String; dataset_name=nothing, info=nothing)

where ``dataset_name`` is the name of the dataset to store the array in (defaults to ``"array_data"``), and ``info``
is an optional dictionary which can be stored as dataset attributes to provide additional information:

.. code-block:: jlcon

    julia> a = YT.YTArray(rand(10,10), "kpc/Myr")
    10x10 YTArray (kpc/Myr):
     0.8888545184475427   0.29464950894597686  …  0.4256777232565485
     0.7469690649893874   0.7553969983155757      0.8044874171101348
     0.583046720365916    0.3767748808429836      0.7449196090549277
     0.09988510481900925  0.8528910610569467      0.5702756152900481
     0.8016480624694218   0.803297393530946       0.04164033322639149
     0.21639598504942836  0.8902582922168041   …  0.3908148074495865
     0.3552211934011673   0.42675416182273995     0.03558079698568162
     0.4431574771660278   0.4837529146082904      0.22880655307572217
     0.7789837638416921   0.4639426067506691      0.14832697895106595
     0.6460553973501566   0.04338617942933576     0.6935626833634565

    julia> myinfo = Dict("field"=>"velocity_magnitude", "source"=>"galaxy cluster")

    julia> YT.write_hdf5(a, "my_file.h5", dataset_name="cluster", info=myinfo)

The data can be read back into a ``YTArray`` using ``from_hdf5``:

.. code-block:: julia

    function from_hdf5(filename::String; dataset_name=nothing)

.. code-block:: jlcon

    julia> b = YT.from_hdf5("my_file.h5", dataset_name="cluster")
    10x10 YTArray (kpc/Myr):
     0.8888545184475427   0.29464950894597686  …  0.4256777232565485
     0.7469690649893874   0.7553969983155757      0.8044874171101348
     0.583046720365916    0.3767748808429836      0.7449196090549277
     0.09988510481900925  0.8528910610569467      0.5702756152900481
     0.8016480624694218   0.803297393530946       0.04164033322639149
     0.21639598504942836  0.8902582922168041   …  0.3908148074495865
     0.3552211934011673   0.42675416182273995     0.03558079698568162
     0.4431574771660278   0.4837529146082904      0.22880655307572217
     0.7789837638416921   0.4639426067506691      0.14832697895106595
     0.6460553973501566   0.04338617942933576     0.6935626833634565

which is obviously the same array.

It may be useful to generate ``YTArray``\ s of ones or zeros similar to an existing ``YTArray``. This
can be done with ``ones`` and ``zeros``, in the same manner as the standard Julia ``Array``:

.. code-block:: jlcon

    julia> ones(sp["density"])
    325184-element YTArray (g/cm**3):
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     ⋮
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0
     1.0

    julia> zeros(sp["density"])
    325184-element YTArray (g/cm**3):
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     ⋮
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0
     0.0

.. _quantities:

Quantities
----------

A ``YTQuantity`` is just a scalar version of a ``YTArray``. They can be manipulated in the same way:

.. code-block:: jlcon

    julia> a = YT.YTQuantity(3.14159, "radian")
    3.14159 radian

    julia> b = YT.YTQuantity(12, "cm")
    12.0 cm

    julia> a/b
    0.26179916666666664 radian/cm

    julia> a\b
    3.8197218605865184 cm/radian

    julia> c = YT.YTQuantity(13,"m")
    13.0 m

    julia> b+c
    1312.0 cm

    julia> d = YT.YTQuantity(ds, 1.0, "code_length")
    1.0 code_length

.. _changing-units:

Changing Units
--------------

Occasionally you will want to change the units of an array or quantity to something more
appropriate. Taking density as the example, we can change it to units of solar masses per
kiloparsec:

.. code-block:: jlcon

    julia> a = YT.in_units(sp["density"], "Msun/kpc**3")
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

.. code-block:: jlcon

    julia> YT.in_cgs(a)
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

.. code-block:: jlcon

    julia> YT.in_mks(a)
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

Some physical constants are represented in ``YT``. They are available via the
``YT.physical_constants`` submodule, and are unitful quantities which can be used with other
quantities and arrays:

.. code-block:: jlcon

    julia> kb = YT.physical_constants.kboltz # Boltzmann constant
    1.3806488e-16 erg/K

    julia> kT = YT.in_units(kb*sp["temperature"], "keV") # computing kT in kilo-electronvolts
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

The physical constants implemented in ``YT.physical_constants`` are (in cgs units):

* ``G``: Newton's constant of gravitation
* ``kboltz``: Boltzmann's constant
* ``clight``: Speed of light in vacuum
* ``me``: mass of the electron
* ``mp``: mass of the proton
* ``qp``: charge of the proton
* ``hcgs``: Planck's constant
* ``sigma_thompson``: Thompson cross section
* ``amu_cgs``: Atomic mass unit
* ``Na``: Avogadro's number
* ``Tcmb``: Cosmic microwave background temperature
* ``stefan_boltzmann``: Stefan-Boltzmann constant

.. _equivalencies:

Equivalencies
-------------

"Some physical quantities are directly related to other unitful quantities by a constant, but otherwise do not 
have the same units. To facilitate conversions between these quantities, ``yt`` implements a system of unit 
equivalencies (inspired by the `AstroPy implementation <http://docs.astropy.org/en/latest/units/equivalencies.html>`_.
The possible unit equivalencies are

* ``"thermal"``: conversions between temperature and energy (:math:`E = k_BT`)
* ``"spectral"``: conversions between wavelength, frequency, and energy for photons 
  (:math:`E = h\nu = hc/\lambda`, :math:`c = \lambda\nu`)
* ``"mass_energy"``: conversions between mass and energy (:math:`E = mc^2`)
* ``"lorentz"``: conversions between velocity and Lorentz factor (:math:`\gamma = 1/\\sqrt{1-(v/c)^2}`)
* ``"schwarzschild"``: conversions between mass and Schwarzschild radius (:math:`R_S = 2GM/c^2`)
* ``"compton"``: conversions between mass and Compton wavelength (:math:`\lambda = h/mc`)

The following unit equivalencies only apply under conditions applicable for an ideal gas with a constant mean molecular 
weight :math:`\mu` and ratio of specific heats :math:`\gamma`:
      
* ``"number_density"``: conversions between density and number density (:math:`n = \rho/\mu{m_p}`)
* ``"sound_speed"``: conversions between temperature and sound speed for an ideal gas (:math:`c_s^2 = \gamma{k_BT}/\mu{m_p}`)

A ``YTArray`` or ``YTQuantity`` can be converted to an equivalent using the ``to_equivalent`` method, where the unit 
and the equivalence name are provided as arguments:

.. code-block:: jlcon

    julia> T = YTQuantity(1.0e8, "K")

    julia> to_equivalent(T, "keV", "thermal")
    8.617332401096501 keV

    julia> ds = load('IsolatedGalaxy/galaxy0030/galaxy0030')
    
    julia> dd = AllData(ds)
    
    julia> to_equivalent(dd["density"], "kpc**-3", "number_density")
    3644460-element YTArray (kpc**(-3)):
     1.441658495282944e58 
     1.445257323866133e58 
     1.4447291393781058e58
     1.4441308994269905e58
     1.443577677934973e58 
     1.4430142249749788e58
     1.442458957189366e58 
     1.441917652348286e58 
     1.4413998196984475e58
     1.440917014780153e58 
     ⋮
     3.126449826777384e62 
     4.590495737918272e62 
     7.282569464375485e62 
     1.1537277841059746e63
     1.7350057717608834e63
     2.4686488054537047e63
     3.3023848519686545e63
     4.668116783340724e63 
     3.2130275999617263e64

    julia> import YT.physical_constants: mp
    
    julia> to_equivalent(mp, "GeV", "mass_energy")
    0.9388966459173169 GeV
    
Some equivalencies take optional parameters, such as ``"sound_speed"``, which allows you to change
the mean molecular weight ``mu`` and ratio of specific heats ``gamma``:

.. code-block:: jlcon

    julia> kT = YTQuantity(4.0, "keV")
    
    julia> to_equivalent(kT, "km/s", "sound_speed", gamma=4./3., mu=0.5)
    1010.476390793905 km/s
    
To list the available equivalencies for a given array or quantity, use the ``list_equivalencies`` method:

.. code-block:: jlcon 

    julia> list_equivalencies(kT)
    spectral: length <-> rate <-> energy
    sound_speed (ideal gas): velocity <-> temperature <-> energy
    mass_energy: mass <-> energy
    thermal: temperature <-> energy

or to check if a specific equivalence exist for an array or quantity, use ``has_equivalent``:

.. code-block:: jlcon

    julia> has_equivalent(kT, "spectral")
    true
    
    julia> has_equivalent(dd["density"], "compton")
    false

