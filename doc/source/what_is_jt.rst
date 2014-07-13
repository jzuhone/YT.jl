What is jt?
===========

``jt`` is a Julia interface to ``yt``. ``yt`` is a Python package for the analysis and
visualization of volumetric simulation data. For more information about yt,
check out http://yt-project.org.

What jt Does
------------

``jt`` exposes a number of the essential features of ``yt`` from within a Julia environment. These
include:

* Datasets
* Data objects (e.g., spheres, rectangular regions, slices, projections, profiles, etc.)
* Unit-aware quantities and arrays
* Simple visualization tools (e.g., ``SlicePlot``, ``ProjectionPlot``, ``ProfilePlot``, etc.)

``jt`` enables the end-user to "ask" physically-motivated questions of volumetric data and work
with the "answers" from within a Julia environment.

What jt Doesn't Do (and Probably Won't)
---------------------------------------

``jt`` is not intended to be a full exposure of everything ``yt`` does. ``yt`` boasts many
features, and exposing all of them would be somewhat redundant, especially those features that
don't involve a lot of additional coding on the part of the end-user. Some of these features
include:

* Analysis modules (e.g., particle trajectories, two-point functions, halo finders, simulated observations, etc.)
* Initial conditions generation
* Volume rendering
* Utilities for cosmology, image writing, generating streamlines, clump finding, etc.

``yt`` does a great job at handling these tasks already, and so if you are looking to use these
features, working with ``yt`` directly from within a Python environment is the way to go. The
purpose of ``jt`` is to expose the basic data loading and examining features of ``yt``, as well
as a few handy visualization tools, so that those who want to take advantage of the strengths
of both Julia and ``yt`` strengths can do so.

.. note::

    This documentation does not exhaustively cover the API of the Python methods of ``yt`` that may
    be accessed via ``jt``. For that, consulting the `yt Documentation <http://yt-project
    .org/doc>`_ is recommended.