What is ``YT``?
===============

.. |yt-docs| replace:: ``yt`` Documentation
.. _yt-docs: http://yt-project.org/docs/3.0

``YT`` is a Julia interface to ``yt``. ``yt`` is a Python package for the analysis and
visualization of volumetric simulation data. For more information about yt,
check out http://yt-project.org.

What ``YT`` Does
----------------

``YT`` exposes a number of the essential features of ``yt`` from within a Julia environment. These
include:

* Datasets
* Data objects (e.g., spheres, rectangular regions, slices, projections, profiles, etc.)
* Unit-aware quantities and arrays
* Simple visualization tools (e.g., ``SlicePlot``, ``ProjectionPlot``, ``FixedResolutionBuffer``)

``YT`` enables the end-user to "ask" physically-motivated questions of volumetric data and work
with the "answers" from within a Julia environment.

What ``YT`` Doesn't Do (and Probably Won't)
-------------------------------------------

``YT`` is not intended to be a full exposure of everything ``yt`` does. ``yt`` boasts many
features, and exposing all of them would be somewhat redundant, especially those features that
don't involve a lot of additional coding on the part of the end-user. Some of these features
include:

* Analysis modules (e.g., particle trajectories, two-point functions, halo finders, simulated observations, etc.)
* Initial conditions generation
* Volume rendering
* Utilities for cosmology, image writing, generating streamlines, clump finding, etc.

``yt`` does a great job at handling these tasks already, and so if you are looking to use these
features, working with ``yt`` directly from within a Python environment is the way to go. The
purpose of ``YT`` is to expose the basic data loading and examining features of ``yt``, as well
as a few handy visualization tools, so that those who want to take advantage of the strengths
of both Julia and ``yt`` strengths can do so.

.. note::

    This documentation does not exhaustively cover the API of the Python methods of ``yt`` that may
    be accessed via ``YT``. For that, consulting the |yt-docs|_ is recommended.