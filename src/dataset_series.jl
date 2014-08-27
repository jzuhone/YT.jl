module dataset_series

import ..data_objects: Dataset

import PyCall: @pyimport, PyObject

@pyimport yt.data_objects.time_series as time_series

type DatasetSeries
    ts::PyObject
    function DatasetSeries(fns::Array{Union(ASCIIString,UTF8String),1})
        ts = time_series.DatasetSeries(fns)
        new(ts)
    end
end

function getindex(ts::DatasetSeries, index::Integer)
    Dataset(ts.ts[:__getitem__](index-1))
end

end
