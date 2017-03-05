Installing YT
=============

YT version 0.4 requires Julia version 0.5 or later, and may be installed 
just like any other Julia package:

.. code-block:: jlcon

    julia> Pkg.add("YT")

This will also install `PyCall <http://github.com/stevengj/PyCall.jl>`_, 
if you don't have it installed already:

However, for YT to work, yt itself must be installed. YT version 0.4
requires yt version 3.3.1 or higher. The best ways to install yt are via
`pip <https://pip.pypa.io/>`_ or the 
`Anaconda Python Distribution <https://store.continuum.io/cshop/anaconda/>`_.

Once YT is installed, either

.. code-block:: jlcon

    julia> import YT

to use it as a library, or

.. code-block:: jlcon

    julia> using YT

to use it as an application, loading its methods into the current session's 
namespace.

Recommended Packages
--------------------

While not required, the following Julia packages are useful when working 
with data in YT:

* `IJulia <https://github.com/JuliaLang/IJulia.jl>`_ (Julia backend for 
  Jupyter)
* `Glob <https://github.com/vtjnash/Glob.jl>`_ (find pathnames matching 
  specified patterns, useful for constructing arrays of filenames)
