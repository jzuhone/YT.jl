import Base: help, arg_decl_parts

dc_help = Dict()
dc_help["AllData"] = "The entire domain."
dc_help["CoveringGrid"] = "A fixed-resolution 3D grid of points."
dc_help["Cutting"] = "An oblique slice through the domain."
dc_help["Disk"] = "A cylindrical region."
dc_help["Point"] = "A single point in the domain."
dc_help["Proj"] = "An projection along a given axis."
dc_help["Ray"] = "A oblique ray of points."
dc_help["Region"] = "A rectangular region of data."
dc_help["Slice"] = "A slice normal to an axis through the domain."
dc_help["Sphere"] = "A spherical region."

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

for dc_type = (AllData,CoveringGrid,Cutting,Disk,Point,
               Proj,Ray,Region,Slice,Sphere)
    @eval help(io::IO, ::Type{$dc_type}) = @help_dc($dc_type)
end
