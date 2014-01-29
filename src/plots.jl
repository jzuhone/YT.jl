module plots

import ..data_objects: DataSet
using PyCall
@pyimport yt.visualization.plot_window as pw

abstract PlotWindow

type SlicePlot <: PlotWindow
    plot::PyObject
    function SlicePlot(ds::DataSet, axis::String, fields::Array{ASCIIString,1}; args...)
        new(pw.SlicePlot(ds.ds, axis, fields; args...))
    end
    function SlicePlot(ds::DataSet, axis::Array, fields::Array{ASCIIString,1}; args...)
        new(pw.SlicePlot(ds.ds, axis, fields; args...))
    end
end

# Plot callbacks

function show(plot::PlotWindow)
    plot.plot
end

function set_width(plot::PlotWindow, value::Real, unit::String)
    plot.plot[:set_width](value, unit)
end

function set_log(plot::PlotWindow, field::String, islog::Bool)
    plot.plot[:set_log](field, islog)
end

function zoom(plot::PlotWindow, zoom::Real)
    plot.plot[:zoom](zoom)
end

function annotate_grids(plot::PlotWindow)
    plot.plot[:annotate_grids]()
end

end
