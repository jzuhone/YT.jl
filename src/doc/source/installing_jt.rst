Installing ``jt``
=================

``jt`` may be installed just like any other Julia package:

.. code-block:: julia

    Pkg.add("jt")

This will also install the following dependencies:

* PyCall
* PyPlot
* SymPy
* IJulia

However, for ``jt`` to work, ``yt`` itself must be installed. The best way to install ``yt`` is by using Anaconda.

Once ``jt`` is installed, running

.. code-block:: julia

    using jt

will load it into the namespace.