module plots

import ..data_objects: Dataset, DataContainer
import ..utils: Axis, FieldOrArray, Field
import ..array: YTArray

using PyCall
@pyimport yt.visualization.plot_window as pw
@pyimport yt.visualization.profile_plotter as pp

function SlicePlot(ds::Dataset, axis::Axis, fields::FieldOrArray;
                   center="c", args...)
    if typeof(center) == YTArray
        c = convert(PyObject, center)
    else
        c = center
    end
    pywrap(pw.SlicePlot(ds.ds, axis, fields, center=c; args...))
end

function ProjectionPlot(ds::Dataset, axis::Axis, fields::FieldOrArray,
                        center="c"; data_source=nothing, args...)
    if data_source != nothing
        source = data_source.cont
    else
        source = pybuiltin("None")
    end
    if typeof(center) == YTArray
        c = convert(PyObject, center)
    else
        c = center
    end
    pywrap(pw.ProjectionPlot(ds.ds, axis, fields, center=c,
                             data_source=source; args...))
end

function PhasePlot(dc::DataContainer, x_field::String, y_field::String,
                    z_fields::FieldOrArray; args...)
    pywrap(pp.PhasePlot(dc.cont, x_field, y_field, z_fields; args...))
end

function ProfilePlot(dc::DataContainer, x_field::String,
                     y_fields::FieldOrArray; args...)
    pywrap(pp.ProfilePlot(dc.cont, x_field, y_fields; args...))
end

# Show plot

function show_plot(plot)
    plot.refresh()
end

end
