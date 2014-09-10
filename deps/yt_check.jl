import PyCall: @pyimport

min_version = v"3.0"

function check_for_yt()
    try
        @pyimport yt
    catch
        error("Cannot import yt! Is it installed in the current Python?")
    end

    @pyimport yt
    yt_version = convert(VersionNumber, yt.__version__)
    if yt_version < min_version
        err_msg = ("Your version of yt is not up to date. " *
                   "You need at least version $min_version, " *
                   "but your current version is $yt_version.")
        error(err_msg)
    end
    return yt_version
end
