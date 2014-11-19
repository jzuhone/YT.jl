.. _configuring:

Configuring YT
==============

Configuration
-------------

Plugins
-------

``YT`` can make use of the ``yt`` plugin file. This file can be used to set up derived fields,
define constants, add units to registries, etc. The file is typically called ``my_plugins.py`` and is
located within the ``.yt`` subdirectory in the user's home directory. To load the plugin file,
call the ``enable_plugins`` method:

.. code-block:: jlcon

    julia> YT.enable_plugins()
    yt : [INFO     ] 2014-11-19 12:01:02,316 Loading plugins from /Users/jzuhone/.yt/my_plugins.py


