import Base: help, arg_decl_parts

dc_help = Dict()
dc_help["AllData"] = "The entire domain."
dc_help["CoveringGrid"] = "A fixed-resolution 3D grid of points."
dc_help["Point"] = "A single point."
dc_help["Ray"] = "A 1D ray of points."
dc_help["Sphere"] = "A sphere with a given center and radius."

# Help

macro help_dc(dc_type)
    quote
        println(string($dc_type)*" <: DataContainer")
        println("")
        println("   "*dc_help[string($dc_type)])
        println("\n   Parameters\n   ----------\n")
        mm = methods($dc_type)
        for m in mm
            args = arg_decl_parts(m)[2]
            for arg in args
                println("   $(arg[1])::$(arg[2])")
            end
        end
    end
end

for dc_type = (AllData,CoveringGrid,Point,Ray,Sphere)
    @eval help(io::IO, ::Type{$dc_type}) = @help_dc($dc_type)
end
