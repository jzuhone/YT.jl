Installing ``jt``
=================

``jt`` may be installed just like any other Julia package:

.. code-block:: julia

    julia> Pkg.add("jt")

This will also install the following dependencies:

* `PyCall <http://github.com/stevengj/PyCall.jl>`_
* `PyPlot <http://github.com/stevengj/PyPlot.jl>`_
* `SymPy <http://github.com/jverzani/SymPy.jl>`_
* `IJulia <http://github.com/JuliaLang/IJulia.jl>`_

However, for ``jt`` to work, ``yt`` itself must be installed. The best way to install ``yt`` is by using Anaconda.

Once ``jt`` is installed, running

.. code-block:: julia

    julia> using jt

will load the ``jt`` modules.