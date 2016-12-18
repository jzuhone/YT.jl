import PyCall: @pyimport
import Conda

try
    @pyimport yt
catch
    info("Did not find a Python stack with yt installed, so I'm " *
         "installing one using the Conda.jl package.")
    Conda.add("yt")
    ENV["PYTHON"] = abspath(Conda.PYTHONDIR, "python" * (@static is_windows() ? ".exe" : ""))
    Pkg.build("PyCall")
end
