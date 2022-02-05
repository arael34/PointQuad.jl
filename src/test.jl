using GameZero

const WIDTH = 800
const HEIGHT = 800
const BACKGROUND = colorant"black"

#=
TODO
fix and clean up generate_quad()
delete gamezero stuff
=#

struct Point
    x::Real
    y::Real
end

mutable struct Sqr
    x::Real
    y::Real
    s::Real
end

mutable struct QuadTree
    boundary::Sqr
    capacity::Int
    points::Vector{Point}
    cr::Vector{QuadTree}
end

function QuadTree(b::Sqr, c::Int) 
    QuadTree(b, c, Vector{Point}(), Vector{QuadTree}())
end

isleaf(qt::QuadTree) = length(qt.cr) == 0

function vertices(boundary::Sqr)
    [
        Sqr(boundary.x + boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x + boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2)
    ]
end

function contains(boundary::Sqr, p::Point)
    return (
        p.x > boundary.x - boundary.s / 2 &&
        p.x < boundary.x + boundary.s / 2 &&
        p.y > boundary.y - boundary.s / 2 &&
        p.y < boundary.y + boundary.s / 2
    )
end

function subdivide!(qt::QuadTree)
    qt.cr = QuadTree.(vertices(qt.boundary), qt.capacity)
end

function insert!(qt::QuadTree, p::Point)
    if !contains(qt.boundary, p) return end
    if length(qt.points) < qt.capacity
        push!(qt.points, p)
    else
        if isleaf(qt)
            subdivide!(qt)
        end
        for quad in qt.cr
            insert!(quad, p)
        end
    end
end

function intersects(A::Sqr, B::Sqr)
    !(
        A.x - A.s / 2 >= B.x + B.s / 2 ||
        A.x + A.s / 2 <= B.x - B.s / 2 ||
        A.y - A.s / 2 >= B.y + B.s / 2 ||
        A.y + A.s / 2 <= B.y - B.s / 2
    )
end

function query(qt::QuadTree, bounds::Sqr)
    found = Vector{Point}()
    if !intersects(qt.boundary, bounds) return found end
    for p in qt.points
        if !contains(bounds, p) continue end
        push!(found, p)
    end
    if isleaf(qt) return found end
    for section in qt.cr
        append!(found, query(section, bounds))
    end
    return found
end

function generate_quad(qt::QuadTree)
    l = Vector{QuadTree}()
    push!(l, qt)
    if length(qt.points) == 0
    else
        for section in qt.cr
            for quad in generate_quad(section)
                push!(l, quad)
            end
        end
    end
    return l
end

pslol = Vector{Point}()
foundp = Vector{Point}()

cursor = Sqr(0, 0, 60)

qt = QuadTree(Sqr(WIDTH / 2, HEIGHT / 2, WIDTH), 7)

function draw(v::Game)
    for p in pslol
        draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 1), colorant"white", fill = true)
    end
    #draw(Rect(400, 400, 400, 400))
    for sec in generate_quad(qt)
        draw(Rect(trunc(Int, sec.boundary.x - sec.boundary.s / 2), trunc(Int, sec.boundary.y - sec.boundary.s / 2), trunc(Int, sec.boundary.s), trunc(Int, sec.boundary.s)), colorant"white", fill = false)
    end
    draw(Circle(trunc(Int, cursor.x), trunc(Int, cursor.y), trunc(Int, cursor.s / 2)), colorant"blue", fill = false)
    foundp = query(qt, Sqr(cursor.x, cursor.y, 60))
    for p1 in foundp
        draw(Circle(trunc(Int, p1.x), trunc(Int, p1.y), 3), colorant"green", fill = true)
    end
end

function on_mouse_down(v::Game, pos, button)
    insert!(qt, Point(pos[1], pos[2]))
    push!(pslol, Point(pos[1], pos[2]))
end

function on_mouse_move(v::Game, pos)
    cursor.x, cursor.y = pos[1], pos[2]
end