include("yt_check.jl")

yt_version = check_for_yt()

println(STDERR, "Found yt version $yt_version. OK!")
