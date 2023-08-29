# Geometry Generation
Documentation for functions used to generate potential
geometry during the population growth in the genetic algorithm
optimization.

```@meta
CurrentModule = geometry_configuration
```

```@docs
load_JSON()
get_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
set_plane(plane, L, W, T)
rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, W, L)
circle_vertices(x1_coordinate_slider, x2_coordinate_slider, R) 
place_shape(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
```