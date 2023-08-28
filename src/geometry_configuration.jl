module geometry_configuration
using JSON, GLMakie

export load_geometry

""""
    load_geometry()

loads in the geometry defined in the geometry.json file
"""
function load_geometry()
    geometry = []
    D = JSON.parsefile("geometry.json")
    for i = 1:length(D)
        push!(geometry, D[i])
    end
    return geometry
end

end