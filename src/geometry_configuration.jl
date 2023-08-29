module geometry_configuration
using JSON, GLMakie

export get_vertices, set_plane, rectangle_vertices,  triangle_vertices, circle_vertices, place_shape, load_JSON


"""
    load_JSON()
load the configuration and geometry json files. note that the
radius, length, width, and thickness must be followed by the 
value set for "scaling_factor" in the configuration.json file
all keys must be present for all shapes

    Expected Formatting for 2 shape geometry input
    [
                    {
                        "shape": "Rod",
                        "radius": 100e-9,
                        "length": 100e-9,
                        "width": 100e-9,
                        "thickness": 100e-9,
                        "material": "gold",
                        "position": [201.4, 101.1, 249.1]
                    },
                    {
                        "shape": "Rod",
                        "radius": 100e-9,
                        "length": 100e-9,
                        "width": 100e-9,
                        "thickness": 100e-9,
                        "material": "gold",
                        "position": [201.4, 101.1, 249.1]
                    }
    ]

    Geometry Keys:
        "shape": Expected values: "Rod", "Rectangle", or "Triangle"
        "radius": radius of rod in the XZ-plane
            can be any positive floating point number
        "length": number of units material spans along the Z-axis
            can be any positive floating point number
        "width": number of units material spans along the X-axis
            can be any positive floating point number
        "Thickness": number of units material spans along the Y-axis
            can be any positive floating point number
        "material": defines the color of the shape in the visualizer
            currently the only defined colors are blue for "air"
            and red for any other value
        "position": coordinateds for the center of the shape in
            a three value ordered pair, can be any positive float

    Expected Formatting for 2 shape geometry input
                [
                    {
                        "scaling_factor": 1E9,
                        "x_span": 450,
                        "y_span": 300,
                        "z_span": 900
                    }
                ]

    Configuration Keys:
        "scaling_factor": corresponds to the units of the geometry value
        "x_span": sets the maximum value of the slider for the x-coordinate
        "y_span": sets the maximum value of the slider for the y-coordinate
        "z_span": sets the maximum value of the slider for the z-coordinate
        

"""
function load_JSON()
    return [open(JSON.parse, "geometry.json"), open(JSON.parse, "configuration.json")]
end


"""
    get_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
"""
function get_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
    if shape == "Rectangle"
        return rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    elseif shape == "Triangle"
        if plane == "xz"
            #triangles have to be placed with face in the xz plane
            return triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, W, L)
        else
            return rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
        end
    elseif shape == "Rod"
        if plane == "xz"
            #triangles have to be placed with face in the xz plane
            return circle_vertices(x1_coordinate_slider, x2_coordinate_slider, R) 
        else
            return rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
        end
    end
end


"""
    set_plane(plane, L, W, T)
"""
function set_plane(plane, L, W, T)
    if plane == "xz"
        return [W, L]
    elseif plane == "xy"
        return [W, T]
    elseif plane == "yz"
        return [T, L]
    end
end


"""
    rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
"""
function rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    dim1, dim2 = set_plane(plane, L,W,T)
    vertices = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + dim1, x2 + dim2),
            Point2f(x1 + dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 + dim2)
        ]
    end
    return vertices
end
    
"""
    triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, W, L)
"""
function triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, W, L)
    vertices = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1, x2 + L),
            Point2f(x1 + W, x2 - L),
            Point2f(x1 - W, x2 - L)
        ]
    end
    return vertices
end

"""
    circle_vertices(x1_coordinate_slider, x2_coordinate_slider, R) 
"""
function circle_vertices(x1_coordinate_slider, x2_coordinate_slider, R) 
        vertices = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
            Circle(Point2f(x1, x2), R)
        end
    return vertices
end

"""
    place_shape(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
"""
function place_shape(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
    center_coordinates = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        Point2f(x1, x2)
    end
    vertice_coordinates = get_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T, R, shape)
    x1_coordinate_string = lift(x1 -> "$x1", x1_coordinate_slider.value)
    x2_coordinate_string = lift(x2 -> "$x2", x2_coordinate_slider.value)
    return [center_coordinates, vertice_coordinates, x1_coordinate_string, x2_coordinate_string]
end

end