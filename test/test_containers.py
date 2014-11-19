import yt
from yt.funcs import camelcase_to_underscore
import numpy as np

cont_dict = {}
cont_dict["dd"] = "AllData", (), {}
cont_dict["pt"] = "Point", (np.array([0.5, 0.6, 0.2]),), {}
cont_dict["sp1"] = "Sphere", ("c", (500.,"kpc")), {}
cont_dict["sp2"] = "Sphere", (np.array([0.5,0.3,0.4]), (0.2,"unitary")), {}
cont_dict["reg"] = "Region", ("c", np.array([0.1,0.1,0.1]), np.array([0.8,0.8,0.8])), {}
cont_dict["dk1"] = "Disk", ("c", np.array([1.0,0.5,0.2]), 0.2, 0.2), {}
cont_dict["dk2"] = "Disk", (np.array([0.5,0.57,0.43]), np.array([-1.0,0.7,-0.3]), 0.1, 0.3), {}
cont_dict["ray"] = "Ray", (np.array([0.1,0.1,0.4]), np.array([0.3,0.4,0.5])), {}
cont_dict["slc"] = "Slice", (1, 0.55), {}
cont_dict["cp1"] = "Cutting", (np.array([0.4, 0.5, 0.3]), "c"), {}
cont_dict["cp2"] = "Cutting", (np.array([0.2, -0.3, -0.4]), np.array([0.3, 0.5, 0.4])), {}
cont_dict["cvg"] = "CoveringGrid", (4, np.array([0.2, 0.2, 0.2]), np.array([100,100,100], dtype="int")), {}
cont_dict["prj1"] = "Proj", ("density", "z"), {}
cont_dict["prj2"] = "Proj", ("density", 2), {"weight_field":"temperature"}

file_to_write = "test/containers.h5"

def generate_container_data():

    ds = yt.load("enzo_tiny_cosmology/DD0046/DD0046")

    for key, value in cont_dict.items():
        cont = getattr(ds, camelcase_to_underscore(value[0]), None)
        if cont is not None:
            c = cont(*value[1], **value[2])
            c["density"].write_hdf5(file_to_write, dataset_name=key)
            
    # Special handling

    sp1 = ds.sphere(*cont_dict["sp1"][1])
    prj = ds.proj("density", 1, data_source=sp1)
    prj["density"].write_hdf5(file_to_write, dataset_name="prj3")

    sp2 = ds.sphere(*cont_dict["sp2"][1])
    conditions = ["obj['kT'] > 0.5"]
    cr = sp2.cut_region(conditions)
    cr["density"].write_hdf5(file_to_write, dataset_name="cr")

    for i, grid in enumerate(ds.index.grids):
        grid["density"].write_hdf5(file_to_write, dataset_name="grid_%04d" % (i+1))

if __name__ == "__main__":
    generate_container_data()
    
