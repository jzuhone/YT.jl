# jt

`jt` is a Julia interface to the Python-based [`yt` analysis toolkit](http://yt-project.org). Currently,
`jt` is in a very experimental state, but most functions seem to
work. These include:

* Loading of `yt` datasets
* Some basic `yt` data objects, such as spheres, regions, covering grids,
  projections, slices, etc.
* Creating in-memory datasets (`load_uniform_grid`, `load_amr_grids`,
  etc.)
* Profile objects
* Slice, projection, profile, and phase plots
* Symbolic units, YTArrays, YTQuantities

To install `jt` just run:

    Pkg.clone("git://github.com/jzuhone/jt")

which will also install the following dependencies (if you don't already have them):

* [PyCall](http://github.com/stevengj/PyCall.jl)
* [PyPlot](http://github.com/stevengj/PyPlot.jl)
* [SymPy](http://github.com/jverzani/SymPy.jl)

As well, you need to have a working installation of `yt` 3.0, which is currently
in alpha state. In order to get the required version, issue this set
of commands:

	hg clone http://bitbucket.org/yt_analysis/yt
	cd yt
    hg up yt-3.0
	python setup.py install

If you already have a `yt` installation, change that last line to
`python setup.py develop`.

Once all of this is working, the `jt` module can be loaded from
within a Julia environment or script:

	using jt

More detailed documentation is forthcoming...

