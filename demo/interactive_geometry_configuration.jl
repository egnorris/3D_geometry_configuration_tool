using GLMakie
using JSON


function load_geometry()
    geometry = []
    D = JSON.parsefile("geometry.json")
    for i = 1:length(D)
        push!(geometry, D[i])
    end
    return geometry
end
function load_configuration()
    D = JSON.parsefile("configuration.json")
    return D
end

function get_coordinate_string(x1_coordinate_slider, x2_coordinate_slider)
        X1 = x1_coordinate_slider.value
        X2 = x2_coordinate_slider.value
        x1_coordinate_string = lift(x1 -> "$x1", X1)
        x2_coordinate_string = lift(x2 -> "$x2", X2)
    return [x1_coordinate_string, x2_coordinate_string]
end

function get_center_point(x1_coordinate_slider, x2_coordinate_slider)
    """
    convert the slider values into an observable point that can be updated by
    slider adjustment in the figure
    """
    coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        Point2f(x1, x2)
    end
    return coordinate
end

function get_rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    if plane == "xz"
        #x1: x, x2:z
        dim1 = W
        dim2 = L
    elseif plane == "xy"
        #x1: x, x2:y
        dim1 = W
        dim2 = T
        x2_domain = y_domain
    elseif plane == "yz"
        #x1: y, x2:z
        dim1 = T
        dim2 = L
    end
    coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + dim1, x2 + dim2),
            Point2f(x1 + dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 + dim2)
        ]
    end
    return coordinate
end

function get_triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    if plane == "xz"
        #x1: x, x2:z
        dim1 = W
        dim2 = L
        coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1, x2 + dim2),
            Point2f(x1+dim1, x2 - dim2),
            Point2f(x1-dim1, x2 - dim2)
        ]
        end
        return coordinate
    elseif plane == "xy"
        dim1 = W
        dim2 = T
        coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + dim1, x2 + dim2),
            Point2f(x1 + dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 + dim2)
        ]
        end
        return coordinate
    elseif plane == "yz"
        dim1 = T
        dim2 = L
        coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + dim1, x2 + dim2),
            Point2f(x1 + dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 - dim2),
            Point2f(x1 - dim1, x2 + dim2)
        ]
        end
        return coordinate
    end

    return coordinate
end

function get_sphere_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, radius)
    coordinate = lift(x1_coordinate_slider.value, x2_coordinate_slider.value) do x1, x2
        [
            Point2f(x1 + radius*cos(0), x2 + radius*sin(0)),
            
            Point2f(x1 + radius*cos(pi/6), x2 + radius*sin(pi/6)),
            Point2f(x1 + radius*cos(pi/4), x2 + radius*sin(pi/4)),
            Point2f(x1 + radius*cos(pi/3), x2 + radius*sin(pi/3)),
            
            Point2f(x1 + radius*cos(pi/2), x2 + radius*sin(pi/2)),
            
            Point2f(x1 + radius*cos(2*pi/3), x2 + radius*sin(2*pi/3)),
            Point2f(x1 + radius*cos(3*pi/4), x2 + radius*sin(3*pi/4)),
            Point2f(x1 + radius*cos(5*pi/6), x2 + radius*sin(5*pi/6)),
            
            Point2f(x1 + radius*cos(pi), x2 + radius*sin(pi)),
            
            Point2f(x1 + radius*cos(7*pi/6), x2 + radius*sin(7*pi/6)),
            Point2f(x1 + radius*cos(5*pi/4), x2 + radius*sin(5*pi/4)),
            Point2f(x1 + radius*cos(4*pi/3), x2 + radius*sin(4*pi/3)),
            
            Point2f(x1 + radius*cos(3*pi/2), x2 + radius*sin(3*pi/2)),
            
            Point2f(x1 + radius*cos(5*pi/3), x2 + radius*sin(5*pi/3)),
            Point2f(x1 + radius*cos(7*pi/4), x2 + radius*sin(7*pi/4)),
            Point2f(x1 + radius*cos(11*pi/6), x2 + radius*sin(11*pi/6)),
            
            Point2f(x1 + radius*cos(0), x2 + radius*sin(0))
        ]
    end
    return coordinate
end

function place_polygon(x1_coordinate_slider, x2_coordinate_slider; plane = "xz", L, W, T, shape)
    W = W / 2
    L = L / 2
    T = T / 2
    if shape == "Rectangle"
        return get_rectangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    elseif shape == "Triangle"
        return get_triangle_vertices(x1_coordinate_slider, x2_coordinate_slider, plane, L, W, T)
    end
end



config = load_configuration()[1]
x_domain = 0:0.1:config["x_span"]
z_domain = 0:0.1:config["z_span"]
y_domain = 0:0.1:config["y_span"]
geometry = load_geometry()
fig = Figure()

for k = 1:length(geometry)
    
    T = geometry[k]["thickness"] * config["scaling_factor"] #thickness, along Y
    L = geometry[k]["length"] * config["scaling_factor"]    #length, along Z
    W = geometry[k]["width"] * config["scaling_factor"]     #width, along x
    x0, y0, z0 = geometry[k]["position"]
    x_slider = Slider(fig[2+(k-1), 1], range = x_domain, startvalue = x0)
    y_slider = Slider(fig[2+(k-1), 2], range = y_domain, startvalue = y0)
    z_slider = Slider(fig[2+(k-1), 3], range = z_domain, startvalue = z0)
    
    X = x_slider.value
    Y = y_slider.value
    Z = z_slider.value
    X_coordinate_string = lift(x -> "$x", X)
    Y_coordinate_string = lift(y -> "$y", Y)
    Z_coordinate_string = lift(z -> "$z", Z)

    center_coords_xy = get_center_point(x_slider, y_slider)
    poly_coords_xy = place_polygon(x_slider, y_slider, plane = "xy", L=L, W=W, T=T, shape=geometry[k]["shape"])
    
    center_coords_xz = get_center_point(x_slider, z_slider)
    poly_coords_xz = place_polygon(x_slider, z_slider, plane = "xz", L=L, W=W, T=T, shape=geometry[k]["shape"])
    
    center_coords_yz = get_center_point(y_slider, z_slider)
    poly_coords_yz = place_polygon(y_slider, z_slider, plane = "yz", L=L, W=W, T=T, shape=geometry[k]["shape"])

    ax1 = Axis(fig[1, 1], xlabel = "X Slider", title = "XY - Plane", aspect = x_domain[end] / y_domain[end])
    c = (:red, 0.5)
    if geometry[k]["material"] == "air"
        c = (:blue, 0.5)
    end
    poly!(poly_coords_xy, color = c)
    scatter!(center_coords_xy)
    text!("x", color = :black, position = (50,10 * (length(geometry)+1)))
    text!("y", color = :black, position = (130,10 * (length(geometry)+1)))
    text!("z", color = :black, position = (210,10 * (length(geometry)+1)))
    text!(X_coordinate_string, color = :black, position = (50,10 * k))
    text!(Y_coordinate_string, color = :black, position = (130,10 * k))
    text!(Z_coordinate_string, color = :black, position = (210,10 * k))
    text!(string("G",k), color = :black, position = (10,10 * k))
    limits!(ax1, 1, x_domain[end], 1, y_domain[end])
    
    ax2 = Axis(fig[1, 2], xlabel = "Y Slider", title = "XZ - Plane", aspect = x_domain[end] / z_domain[end])
    poly!(poly_coords_xz, color = c)
    scatter!(center_coords_xz)
    limits!(ax2, 1, x_domain[end], 1, z_domain[end])
    
    ax3 = Axis(fig[1, 3], xlabel = "Z Slider", title = "YZ - Plane", aspect = y_domain[end] / z_domain[end])
    poly!(poly_coords_yz, color = c)
    scatter!(center_coords_yz)
    limits!(ax3, 1, y_domain[end], 1, z_domain[end])
end 

fig
wait(display(fig))