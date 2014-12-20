.. _configuring:

.. |yt_plugin_file| replace:: ``yt`` plugin file
.. _yt_plugin_file: http://yt-project.org/doc/reference/faq/index.html?highlight=plugin#what-is-the-plugin-file

.. |yt_configuration| replace:: discussion on the configuration system in the ``yt`` documentation
.. _yt_configuration: http://yt-project.org/doc/reference/configuration.html?highlight=configuration

Configuring YT
==============

Configuration File
------------------

``yt`` has a configuration file that sits inside the ``$HOME/.yt`` directory. This file can be edited by hand,
or configuration settings can be obtained and set from the Julia REPL:

.. code-block:: jlcon

    julia> YT.ytcfg["yt","loglevel"]
    "20"

    julia> YT.ytcfg["yt","loglevel"] = "1"

    julia> YT.ytcfg["yt","loglevel"]
    "1"

.. note::

    All configuration setting values are strings, even if they represent other types such as integers or booleans!

For more information about the various configuration options can be found in the |yt_configuration|_.

Plugin File
-----------

``YT`` can make use of the |yt_plugin_file|_. This file can be used to set up derived fields,
define constants, add units to registries, etc. The file is typically called ``my_plugins.py`` and is
located within the ``$HOME/.yt`` directory. To load the plugin file, call the ``enable_plugins`` method:

.. code-block:: jlcon

    julia> YT.enable_plugins()
    yt : [INFO     ] 2014-11-19 12:01:02,316 Loading plugins from /Users/jzuhone/.yt/my_plugins.py

An alternative name for the plugin file can be specified using the configuration file:

.. code-block:: jlcon

    julia> YT.ytcfg["yt","pluginfilename"] = "fields_and_stuff.py"


