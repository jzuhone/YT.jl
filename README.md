# jt

`jt` is a Julia interface to the Python-based [`yt` analysis toolkit](http://yt-project.org). `jt`
exposes a number of functionalities from `yt`. These include:

* Loading of `yt` datasets
* Some basic `yt` data objects, such as spheres, regions, covering grids,
  projections, slices, etc.
* Creating in-memory datasets (`load_uniform_grid`, `load_amr_grids`,
  etc.)
* Profile objects
* Slice and projection plots
* Symbolic units, YTArrays, YTQuantities

`jt` can be installed in Julia version 0.3 or higher. To install it, just run:

    Pkg.clone("git://github.com/jzuhone/jt")

which will also install the following dependencies (if you don't already have them):

* [PyCall](http://github.com/stevengj/PyCall.jl)
* [PyPlot](http://github.com/stevengj/PyPlot.jl)
* [SymPy](http://github.com/jverzani/SymPy.jl)
* [IJulia](http://github.com/JuliaLang/IJulia.jl)

However, for `jt` to work, `yt` itself must be installed. `jt` requires `yt` version 3.0 or higher.
The best ways to install `yt` are via the [install script](http://yt-project.org/#getyt) or via the
[Anaconda Python Distribution](https://store.continuum.io/cshop/anaconda).

Once ``jt`` is installed, either

    julia> import jt

to use it as a library, or

    julia> using jt

to use it as an application, loading its methods into the current session's namespace.

