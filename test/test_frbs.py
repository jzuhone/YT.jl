import yt

file_to_write = "test/frbs.h5"

ds = yt.load("enzo_tiny_cosmology/DD0046/DD0046")

slc = ds.slice("z", 0.0)
prj = ds.proj("density", "z")
cut = ds.cutting([0.4, 0.5, 0.3], "c")

frb1 = slc.to_frb((500.,"kpc"), 800)
frb2 = prj.to_frb((500.,"kpc"), 800)
frb3 = cut.to_frb((500.,"kpc"), 800)

a = ds.arr(frb1["density"].v, frb1["density"].units)
b = ds.arr(frb2["density"].v, frb2["density"].units)
c = ds.arr(frb3["density"].v, frb3["density"].units)

a.write_hdf5(file_to_write, dataset_name="frb1")
b.write_hdf5(file_to_write, dataset_name="frb2")
c.write_hdf5(file_to_write, dataset_name="frb3")

