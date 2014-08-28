module plots

import ..data_objects: Dataset, DataContainer
import ..dataset_series: DatasetSeries
import ..array: YTArray
import PyCall: @pyimport, PyObject, pywrap

@pyimport yt.visualization.plot_window as pw
@pyimport yt.visualization.profile_plotter as pp

function SlicePlot(ds::Dataset, axis, fields; center="c", args...)
    if typeof(center) == YTArray
        c = convert(PyObject, center)
    else
        c = center
    end
    pywrap(pw.SlicePlot(ds.ds, axis, fields, center=c; args...))
end

function ProjectionPlot(ds::Dataset, axis, fields; center="c",
                        data_source=nothing, args...)
    if data_source != nothing
        source = data_source.cont
    else
        source = nothing
    end
    if typeof(center) == YTArray
        c = convert(PyObject, center)
    else
        c = center
    end
    pywrap(pw.ProjectionPlot(ds.ds, axis, fields, center=c,
                             data_source=source; args...))
end

# Show plot

function show_plot(plot)
    plot.refresh()
end

end
