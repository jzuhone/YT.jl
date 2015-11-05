import PyCall: @pyimport
import Conda

min_version = v"3.2-"

inst_msg = ("Please install yt version $min_version or higher " *
            "from source, or using Anaconda, pip, or the yt installation script " *
            "found at http://yt-project.org.")

function check_for_yt()
    try
        @pyimport yt
    catch
        Conda.add("yt")
        ENV["PYTHON"] = abspath(Conda.PYTHONDIR, "python" * (@windows? ".exe" : ""))
        Pkg.build("PyCall")
        #err_msg = "Cannot import yt! "
        #error(err_msg * inst_msg)
    end

    try
        @pyimport yt
    catch
        err_msg = "Cannot import yt! "
        error(err_msg * inst_msg)
    end

    @pyimport yt
    yt_version = convert(VersionNumber, yt.__version__)
    if yt_version < min_version
        err_msg = "Your yt installation (v. $yt_version) is not up to date. "
        error(err_msg * inst_msg)
    end
    return yt_version
end
