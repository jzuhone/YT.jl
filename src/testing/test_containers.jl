function run_container_tests(dc::DataContainer)
    max_jt = maximum(dc["density"]).value
    min_jt = minimum(dc["density"]).value
    sum_jt = sum(dc["density"]).value
    len_jt = length(dc["density"])
    min_yt, max_yt = dc.cont[:quantities][:extrema][:__call__]("density")
    sum_yt = dc.cont[:quantities][:total_quantity][:__call__]("density")
    len_yt = int(dc.cont[:quantities][:total_quantity][:__call__]("ones"))[1]
    @test_approx_eq max_jt max_yt
    @test_approx_eq min_jt min_yt
    @test_approx_eq sum_jt sum_yt
    @test len_jt == len_yt
end

ds = load("/Users/jzuhone/yt/test_outputs/GasSloshing/sloshing_nomag2_hdf5_plt_cnt_0100")

dd = AllData(ds)

run_container_tests(dd)

sp1 = Sphere(ds, "c", (100.,"kpc"))
sp2 = Sphere(ds, "max", (3.0856e22,"cm"))
sp3 = Sphere(ds, [0.0,0.0,0.0], (0.2,"unitary"))

run_container_tests(sp1)
run_container_tests(sp2)
run_container_tests(sp3)
