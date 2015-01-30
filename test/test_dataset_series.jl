using YT
using Glob
using Base.Test

test_dir = Pkg.dir("YT") * "/test"

file_to_read = "$(test_dir)/dataset_series.h5"

fns = sort(glob("WindTunnel/windtunnel_4lev_hdf5_plt_cnt_[0-9][0-9]0*"))
time = YTQuantity[]
max_dens = YTQuantity[]
ts = DatasetSeries(fns)
for ds in ts
    append!(time, [ds.current_time])
    sp = Sphere(ds, "c", (0.2,"unitary"))
    append!(max_dens, [maximum(sp["density"])])
end
time = YTArray(time)
max_dens = YTArray(max_dens)

a = time
b = from_hdf5(file_to_read, dataset_name="time")
@test all(a.value .== b.value)
@test a.units == b.units

@test ts[1].current_time == a[1]

a = max_dens
b = from_hdf5(file_to_read, dataset_name="max_dens")
@test all(a.value .== b.value)
@test a.units == b.units

@test length(fns) == length(ts)
