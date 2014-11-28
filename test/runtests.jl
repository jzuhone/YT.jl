test_dir = Pkg.dir("YT") * "/test"

ENV["PYTHONPATH"] = "$(test_dir):" * ENV["PYTHONPATH"] 

run(`python $(test_dir)/test_containers.py $(test_dir)`)
run(`python $(test_dir)/test_frbs.py $(test_dir)`)

include("test_array.jl")
include("test_containers.jl")
include("test_frbs.jl")
include("test_plots.jl")