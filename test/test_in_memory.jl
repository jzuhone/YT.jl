import YT

arr = rand(64,64,64)
data = Dict()
data["density"] = (arr, "g/cm**3")
bbox = [-1.5 1.5; -1.5 1.5; -1.5 1.5]
ds = YT.load_uniform_grid(data, [64,64,64]; length_unit="Mpc", bbox=bbox, nprocs=64)

grid_data = [
  Dict("left_edge"=>[0.0, 0.0, 0.0],
       "right_edge"=>[1.0, 1.0, 1.0],
       "level"=>0,
       "dimensions"=>[32, 32, 32]),
  Dict("left_edge"=>[0.25, 0.25, 0.25],
       "right_edge"=>[0.75, 0.75, 0.75],
       "level"=>1,
       "dimensions"=>[32, 32, 32])
  ]

for g in grid_data
    g["density"] = (rand(g["dimensions"]...) * 2^g["level"], "code_mass/code_length**3")
end

ds = YT.load_amr_grids(grid_data, [32, 32, 32])

n_particles = 5000000
data = Dict()
data["particle_position_x"] = 1.0e6*randn(n_particles)
data["particle_position_y"] = 1.0e6*randn(n_particles)
data["particle_position_z"] = 1.0e6*randn(n_particles)
data["particle_mass"] = ones(n_particles)

bbox = 1.1*[minimum(data["particle_position_x"]) maximum(data["particle_position_x"]);
  minimum(data["particle_position_y"]) maximum(data["particle_position_y"]);
  minimum(data["particle_position_z"]) maximum(data["particle_position_z"])]

ds = YT.load_particles(data, length_unit="pc", mass_unit=(1e8, "Msun"), n_ref=256, bbox=bbox)
