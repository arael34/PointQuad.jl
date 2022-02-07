#=
TODO
clean up
insert function taking coordinates and/or point
=#
module PointQuad

export
    Point,
    Sqr,
    QuadTree,
    isleaf,
    get_subsquares,
    generate_trees,
    contains,
    intersects,
    subdivide!,
    insert!,
    query

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

function get_subsquares(boundary::Sqr)
    [
        Sqr(boundary.x + boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x + boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2)
    ]
end

function generate_trees(qt::QuadTree)
    trees = Vector{QuadTree}()
    push!(trees, qt)
    if length(qt.points) == 0 return trees end
    for section in qt.cr
        append!(trees, generate_trees(section))
    end

    return trees
end

function contains(boundary::Sqr, p::Point)
    (
        p.x > boundary.x - boundary.s / 2 &&
        p.x < boundary.x + boundary.s / 2 &&
        p.y > boundary.y - boundary.s / 2 &&
        p.y < boundary.y + boundary.s / 2
    )
end

function intersects(A::Sqr, B::Sqr)
    !(
        A.x - A.s / 2 >= B.x + B.s / 2 ||
        A.x + A.s / 2 <= B.x - B.s / 2 ||
        A.y - A.s / 2 >= B.y + B.s / 2 ||
        A.y + A.s / 2 <= B.y - B.s / 2
    )
end

function subdivide!(qt::QuadTree)
    qt.cr = QuadTree.(get_subsquares(qt.boundary), qt.capacity)
end

function insert!(qt::QuadTree, p::Point)
    if !contains(qt.boundary, p) return nothing end
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
        
insert!(qt::QuadTree, x::Real, y::Real) = insert!(qt::QuadTree, Point(x, y))

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

end # module
