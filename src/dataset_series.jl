module dataset_series

import ..data_objects: Dataset
import Base: length, start, next, done

import PyCall: @pyimport, PyObject

@pyimport yt.data_objects.time_series as time_series

type DatasetSeries
    ts::PyObject
    num_ds::Int
    function DatasetSeries(fns::Array{Union(ASCIIString,UTF8String),1})
        ts = time_series.DatasetSeries(fns)
        num_ds = ts[:__len__]()
        new(ts, num_ds)
    end
end

function getindex(ts::DatasetSeries, index::Integer)
    Dataset(ts.ts[:__getitem__](index-1))
end

length(ts::DatasetSeries) = ts.num_ds

start(ts::DatasetSeries) = 1
next(ts::DatasetSeries,i) = (ts[i],i+1)
done(ts::DatasetSeries,i) = (i > length(ts))

end
