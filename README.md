# YT

[![Build Status](https://travis-ci.org/jzuhone/YT.jl.svg?branch=master)](https://travis-ci.org/jzuhone/YT.jl) [![Coverage Status](https://coveralls.io/repos/jzuhone/YT.jl/badge.png)](https://coveralls.io/r/jzuhone/YT.jl)

`YT` is a Julia interface to the Python-based [`yt` analysis toolkit](http://yt-project.org). `YT`
exposes a number of functionalities from `yt`. These include:

* Loading of `yt` datasets
* Some basic `yt` data objects, such as spheres, regions, covering grids,
  projections, slices, etc.
* Creating in-memory datasets (`load_uniform_grid`, `load_amr_grids`,
  etc.)
* Profile objects
* Slice and projection plots
* Symbolic units, YTArrays, YTQuantities

`YT` version 0.2 can be installed in Julia version 0.4 or higher. To install it, just run:

    Pkg.add("YT")

which will also install the following dependencies (if you don't already have them):

* [PyCall](http://github.com/stevengj/PyCall.jl)
* [PyPlot](http://github.com/stevengj/PyPlot.jl)
* [SymPy](http://github.com/jverzani/SymPy.jl)

However, for `YT` to work, `yt` itself must be installed. `YT` version 0.2 requires `yt` version 3.1 or higher.
The best ways to install `yt` are via the [install script](http://yt-project.org/#getyt) or via the
[Anaconda Python Distribution](https://store.continuum.io/cshop/anaconda).

Once ``YT`` is installed, either

    julia> import YT

to use it as a library, or

    julia> using YT

to use it as an application, loading its methods into the current session's namespace.

## Documentation

For more documentation, please visit [http://www.jzuhone.com/yt_julia](http://www.jzuhone.com/yt_julia).

