module plots

import ..data_objects: DataSet
using PyCall
@pyimport yt.visualization.plot_window as pw

abstract PlotWindow

PlotAxis = Union(String,Array,Integer)
StringOrArray = Union(String,Array)

type SlicePlot <: PlotWindow
    plot::PyObject
    function SlicePlot(ds::DataSet, axis::PlotAxis, fields::StringOrArray;
                       args...)
        new(pw.SlicePlot(ds.ds, axis, fields; args...))
    end
end

type ProjectionPlot <: PlotWindow
    plot::PyObject
    function ProjectionPlot(ds::DataSet, axis::PlotAxis, fields::StringOrArray;
                       data_source=nothing, args...)
        if data_source != nothing
            source = data_source.cont
        else
            source = pybuiltin("None")
        end
        new(pw.ProjectionPlot(ds.ds, axis, fields, data_source=source; args...))
    end
end

# Plot methods

function show_plot(plot::PlotWindow)
    plot.plot
end

function call(plot::PlotWindow)
    pywrap(plot.plot)
end

function save_plot(plot::PlotWindow; args...)
    pywrap(plot.plot).save(args...)
end

end
