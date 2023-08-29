module geometry_configuration
using JSON, GLMakie

export get_vertices, set_plane, rectangle_vertices,  triangle_vertices, circle_vertices, place_shape. load_JSON

function load_JSON()
    return [open(JSON.parse, "geometry.json"), open(JSON.parse, "configuration.json")]
end

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

function set_plane(plane, L, W, T)
    if plane == "xz"
        return [W, L]
    elseif plane == "xy"
        return [W, T]
    elseif plane == "yz"
        return [T, L]
    end
end

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
    
function triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, W, L)
    vertices = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + W, x2 + L),
            Point2f(x1 + W, x2 - L),
            Point2f(x1 - W, x2 - L),
            Point2f(x1 - W, x2 + L)
        ]
    end
    return vertices
end

function circle_vertices(x1_coordinate_slider, x2_coordinate_slider, R) 
        vertices = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
            Circle(Point2f(x1, x2), R)
        end
    return vertices
end

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