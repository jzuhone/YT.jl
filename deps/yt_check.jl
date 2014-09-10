import PyCall: @pyimport

min_version = v"3.0"

inst_msg = ("Please install yt version $min_version or higher " *
            "using Anaconda, pip, or the yt installation script " *
            "found at http://yt-project.org.")

function check_for_yt()
    try
        @pyimport yt
    catch
        err_msg = "Cannot import yt! "
        error(err_msg * inst_msg)
    end

    @pyimport yt
    yt_version = convert(VersionNumber, yt.__version__)
    if yt_version < min_version
        err_msg = ("Your version of yt is not up to date. " *
                   "You need at least version $min_version, " *
                   "but your current version is $yt_version. ")
        error(err_msg * inst_msg)
    end
    return yt_version
end
