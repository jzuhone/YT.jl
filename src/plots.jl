module plots

import ..data_objects: Dataset, DataContainer, parse_fps
import ..dataset_series: DatasetSeries
import ..array: YTArray
import PyCall: @pyimport, PyObject, pywrap

@pyimport yt.visualization.plot_window as pw
@pyimport yt.visualization.profile_plotter as pp

if VERSION < v"0.4-"
    import YT: @doc
end

@doc doc"""
      A plot of a slice through the simulation domain. 

      Arguments:

      * `ds::Dataset`: The dataset to be used.
      * `axis`: The axis to slice perpendicular to. Can be a string ("x","y", or "z"),
        integer (0,1,2), or a three-element `Array` (e.g., [0.1,0.3,-0.5]), for an
        off-axis slice. 
      * `fields`: A single field, e.g. "density" or ("flash","dens"), or `Array` of fields.
      * `center` (optional): The coordinate of the center of the image. A sequence of 
        floats, a string, or a tuple. If set to 'c', 'center' or left blank, the plot 
        is centered on the middle of the domain. If set to 'max' or 'm', the center 
        will be located at the maximum of the ('gas', 'density') field. Centering on 
        the max or min of a specific field is supported by providing a tuple such as 
        ("min","temperature") or ("max","dark_matter_density"). Units can be specified 
        by passing in `center` as a tuple containing a coordinate and string unit name 
        or by passing in a YTArray. If a list or unitless array is supplied, code units 
        are assumed.
      * `width`: The width of the slice. Width can have four different formats to support 
        windows with variable x and y widths. They are:
        
        ==================================     =======================
        format                                 example
        ==================================     =======================
        (float, string)                        (10,'kpc')
        ((float, string), (float, string))     ((10,'kpc'),(15,'kpc'))
        float                                  0.2
        (float, float)                         (0.2, 0.3)
        ==================================     =======================
        
        For example, (10, 'kpc') requests a plot window that is 10 kiloparsecs wide in the 
        x and y directions, ((10,'kpc'),(15,'kpc')) requests a window that is 10 kiloparsecs 
        wide along the x axis and 15 kiloparsecs wide along the y axis. In the other two 
        examples, code units are assumed, for example (0.2, 0.3) requests a plot that has an
        x width of 0.2 and a y width of 0.3 in code units.  If units are provided the resulting 
        plot axis labels will use the supplied units.
      * `field_parameters::Dict{ASCIIString,Any}` (optional): A dictionary of 
        field parameters than can be accessed by derived fields.

      Other optional arguments are handled by `yt`, consult the `yt` documentation for details.
      
      Examples:

          julia> import YT
          julia> ds = YT.load("RedshiftOutput0005")
          julia> slc = YT.SlicePlot(ds, "z", ["density","temperature"])
      """ ->
function SlicePlot(ds::Dataset, axis, fields; center="c", 
                   width=nothing, field_parameters=nothing, args...)
    if typeof(center) <: YTArray
        c = PyObject(center)
    else
        c = center
    end
    fps = parse_fps(field_parameters)
    pywrap(pw.SlicePlot(ds.ds, axis, fields; center=c,
                        width=width, field_parameters=fps, args...))
end

@doc doc"""
      A plot of an on-axis projection through the simulation domain. 

      Arguments:

      * `ds::Dataset`: The dataset to be used.
      * `axis`: The axis to slice perpendicular to. Can be a string ("x","y", or "z"),
        or an integer (0,1,2). 
      * `fields`: A single field, e.g. "density" or ("flash","dens"), or `Array` of fields.
      * `weight_field` (optional): The field to weight the projection by. Default is
        `nothing`, an unweighted projection. 
      * `center` (optional): The coordinate of the center of the image. A sequence of 
        floats, a string, or a tuple. If set to 'c', 'center' or left blank, the plot 
        is centered on the middle of the domain. If set to 'max' or 'm', the center 
        will be located at the maximum of the ('gas', 'density') field. Centering on 
        the max or min of a specific field is supported by providing a tuple such as 
        ("min","temperature") or ("max","dark_matter_density"). Units can be specified 
        by passing in `center` as a tuple containing a coordinate and string unit name 
        or by passing in a YTArray. If a list or unitless array is supplied, code units 
        are assumed.
      * `width` (optional): The width of the projection. Width can have four different 
        formats to support windows with variable x and y widths. They are:
        
        ==================================     =======================
        format                                 example
        ==================================     =======================
        (float, string)                        (10,'kpc')
        ((float, string), (float, string))     ((10,'kpc'),(15,'kpc'))
        float                                  0.2
        (float, float)                         (0.2, 0.3)
        ==================================     =======================
        
        For example, (10, 'kpc') requests a plot window that is 10 kiloparsecs wide in the 
        x and y directions, ((10,'kpc'),(15,'kpc')) requests a window that is 10 kiloparsecs 
        wide along the x axis and 15 kiloparsecs wide along the y axis. In the other two 
        examples, code units are assumed, for example (0.2, 0.3) requests a plot that has an
        x width of 0.2 and a y width of 0.3 in code units.  If units are provided the resulting 
        plot axis labels will use the supplied units.
      * `data_source::DataContainer` (optional): An optional data source to use when
        making the projection. Only the elements which have coordinates within the 
        `data_source` will be used in the projection. 
      * `field_parameters::Dict{ASCIIString,Any}` (optional): A dictionary of 
        field parameters than can be accessed by derived fields.

      Other optional arguments are handled by `yt`, consult the `yt` documentation for details.
      
      Examples:

          julia> import YT
          julia> ds = YT.load("RedshiftOutput0005")
          julia> sp = YT.Sphere(ds, "max", (0.5,"Mpc"))
          julia> prj = YT.ProjectionPlot(ds, "z", ["density","temperature"]; 
                                         data_source=sp, center="max", width=(2.0,"Mpc"))
      """ ->
function ProjectionPlot(ds::Dataset, axis, fields; weight_field=nothing,
                        center="c", width=nothing, data_source=nothing, 
                        field_parameters=nothing, args...)
    if data_source != nothing
        source = data_source.cont
    else
        source = nothing
    end
    if typeof(center) <: YTArray
        c = PyObject(center) 
    else
        c = center
    end
    fps = parse_fps(field_parameters)
    pywrap(pw.ProjectionPlot(ds.ds, axis, fields; weight_field=weight_field,
                             width=width, center=c, data_source=source, 
                             field_parameters=fps, args...))
end

# Show plot

@doc doc"""
      Show the `plot` in the IJulia notebook.
      """ ->
function show_plot(plot)
    plot.refresh()
end

end
