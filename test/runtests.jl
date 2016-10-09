test_dir = dirname(@__FILE__)

if !isfile("enzo_tiny_cosmology.tar.gz")
    run(`wget http://yt-project.org/data/enzo_tiny_cosmology.tar.gz`)
end
if !isfile("WindTunnel.tar.gz")
    run(`wget http://yt-project.org/data/WindTunnel.tar.gz`)
end
if !isdir("enzo_tiny_cosmology")
    run(`tar -zxvf enzo_tiny_cosmology.tar.gz`)
end
if !isdir("WindTunnel")
    run(`tar -zxvf WindTunnel.tar.gz`)
end

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
include("test_in_memory.jl")

