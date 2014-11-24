module dataset_series

import ..data_objects: Dataset
import Base: length, start, next, done

import PyCall: @pyimport, PyObject

@pyimport yt.data_objects.time_series as time_series

@doc doc"""
      Construct a time series sequence of datasets
      from an array of filenames, `fns::Array{ASCIIString,1}`.
      """ ->
type DatasetSeries
    ts::PyObject
    num_ds::Int
    function DatasetSeries(fns::Array{ASCIIString,1})
        ts = time_series.DatasetSeries(fns)
        num_ds = length(fns)
        new(ts, num_ds)
    end
end

function getindex(ts::DatasetSeries, index::Integer)
    Dataset(get(ts.ts, index-1))
end

length(ts::DatasetSeries) = ts.num_ds

start(ts::DatasetSeries) = 1
next(ts::DatasetSeries,i) = (ts[i],i+1)
done(ts::DatasetSeries,i) = (i > length(ts))

end
