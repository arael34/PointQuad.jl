using GameZero

const WIDTH = 800
const HEIGHT = 800
const BACKGROUND = colorant"antiquewhite"

struct Point
    x::Real
    y::Real
end

struct Sqr
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

isleaf(qt::QuadTree) = isempty(qt.cr)

function vertices(boundary::Sqr)
    [
        Sqr(boundary.x + boundary.s / 2, boundary.y - boundary.s / 2, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 2, boundary.y - boundary.s / 2, boundary.s / 2),
        Sqr(boundary.x + boundary.s / 2, boundary.y + boundary.s / 2, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 2, boundary.y + boundary.s / 2, boundary.s / 2)
    ]
end

function contains(boundary::Sqr, p::Point)
    return (
        p.x > boundary.x - boundary.s &&
        p.x < boundary.x + boundary.s &&
        p.y > boundary.y - boundary.s &&
        p.y < boundary.y + boundary.s
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
        else
            for quad in qt.cr
                insert!(quad, p)
            end
        end
    end
end

function draw(v::Game)
    qt = QuadTree(Sqr(200, 200, 200), 4)
    draw(Rect(qt.boundary.x, qt.boundary.y, qt.boundary.s, qt.boundary.s), colorant"black", fill = false)
end

