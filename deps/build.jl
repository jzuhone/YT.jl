min_version = v"3.0"

try
    @pyimport yt
    yt_version = convert(VersionNumber, yt.__version__)
    if yt_version < min_version
        println("Your version of yt is not up to date. You need at least version $min_version")
    end
catch import_err
    println("yt is not installed with the Python that is in the current path.")
end
