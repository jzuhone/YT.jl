import yt
import sys
import os
import glob

test_dir = sys.argv[1]
file_to_write = os.path.join(test_dir, "dataset_series.h5")

fns = glob.glob("WindTunnel/windtunnel_4lev_hdf5_plt_cnt_[0-9][0-9]0*")
fns.sort()

time = []
max_dens = []
ts = yt.DatasetSeries(fns)

for ds in ts:
    sp = ds.sphere("c", (0.2,"unitary"))
    time.append(ds.current_time)
    max_dens.append(sp["density"].max())

time = yt.YTArray(time)
max_dens = yt.YTArray(max_dens)

time.write_hdf5(file_to_write, dataset_name="time")
max_dens.write_hdf5(file_to_write, dataset_name="max_dens")