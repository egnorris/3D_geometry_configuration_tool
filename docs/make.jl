push!(LOAD_PATH,"../src/")
using Documenter, geometry_configuration

makedocs(
         sitename = "Geometry Configuration Tool",
         modules  = geometry_configuration,
         pages=[
                "About" => "index.md",
               ])