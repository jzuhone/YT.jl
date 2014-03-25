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

In order to use `jt`, you will need to have the following Julia packages installed:

* [PyCall](http://github.com/stevengj/PyCall.jl)
* [PyPlot](http://github.com/stevengj/PyPlot.jl)
* [SymPy](http://github.com/jverzani/SymPy.jl)

You can install these by calling `Pkg.add` on each of them. 

As well, you need to have a working installation of `yt` 3.0, which is currently
in alpha state. In order to get the required version, issue this set
of commands:

	hg clone http://bitbucket.org/yt_analysis/yt
	cd yt
	hg up experimental
	python setup.py install

If you already have a `yt` installation, change that last line to
`python setup.py develop`.

Once all of this is working, the `jt` module can be loaded from
within a Julia environment or script:

	using jt

More detailed documentation is forthcoming...

