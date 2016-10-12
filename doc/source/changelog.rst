.. _changelog:

ChangeLog
=========

Version 0.4.0
-------------

* This version is compatible with Julia v0.5.x and is incompatible with previous versions.
* Fixed a one-off indexing bug which occurred when querying fields from data objects.
* Testing infrastructure has been brought up to date.
* Removed unused ``field_units`` keyword argument from ``load_amr_grids``.
* Added support for different unit systems, introduced in yt 3.3.
