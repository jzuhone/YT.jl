module plots

import ..data_objects: Dataset, DataContainer, parse_fps
import ..dataset_series: DatasetSeries
import ..array: YTArray
import PyCall: @pyimport, PyObject, pywrap

@pyimport yt.visualization.plot_window as pw
@pyimport yt.visualization.profile_plotter as pp

function SlicePlot(ds::Dataset, axis, fields; center="c", 
                   field_parameters=nothing, args...)
    if typeof(center) <: YTArray
        c = PyObject(center)
    else
        c = center
    end
    fps = parse_fps(field_parameters)
    pywrap(pw.SlicePlot(ds.ds, axis, fields; center=c,
                        field_parameters=fps, args...))
end

function ProjectionPlot(ds::Dataset, axis, fields; center="c",
                        data_source=nothing, field_paramters=nothing,
                        args...)
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
    pywrap(pw.ProjectionPlot(ds.ds, axis, fields; center=c,
                             data_source=source, field_parameters=fps, args...))
end

# Show plot

function show_plot(plot)
    plot.refresh()
end

end
