test_dir = Pkg.dir("YT") * "/test"

if haskey(ENV,"PYTHONPATH")
    ENV["PYTHONPATH"] = "$(test_dir):" * ENV["PYTHONPATH"]
else
    ENV["PYTHONPATH"] = "$(test_dir)"
end

run(`python $(test_dir)/test_containers.py $(test_dir)`)
run(`python $(test_dir)/test_frbs.py $(test_dir)`)
run(`python $(test_dir)/test_dataset_series.py $(test_dir)`)

include("test_array.jl")
include("test_containers.jl")
include("test_frbs.jl")
include("test_plots.jl")
include("test_dataset_series.jl")
include("test_profiles.jl")

