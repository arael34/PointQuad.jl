#=
TODO
clean up
generics
=#
module PointQuad

export
    Point,
    Sqr,
    QuadTree,
    isleaf,
    clear!,
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

position(x::Real, y::Real) = (x, y)

get_pos(obj::T) where {T} = position(obj)

mutable struct QuadTree{T}
    datatype::Type{T}
    boundary::Sqr
    capacity::Int
    points::Vector{T}
    cr::Vector{QuadTree{T}}
end

function QuadTree{T}(b::Sqr, c::Int) where {T}
    QuadTree{T}(T, b, c, Vector{T}(), Vector{QuadTree{T}}())
end

function isleaf(qt::QuadTree{T})::Bool where {T}  
    length(qt.cr) == 0
end

function clear!(qt::QuadTree{T}) where {T}
    empty!(qt.points)
    qt.points = Vector{T}()
    if !isleaf(qt) return nothing end
    for section in qt.cr
        clear!(section)
        empty!(section.points)
    end
end

function get_subsquares(boundary::Sqr)::Vector{Sqr}
    [
        Sqr(boundary.x + boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y - boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x + boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2),
        Sqr(boundary.x - boundary.s / 4, boundary.y + boundary.s / 4, boundary.s / 2)
    ]
end

function generate_trees(qt::QuadTree{T})::Vector{QuadTree{T}} where {T}
    trees = Vector{QuadTree{T}}()
    push!(trees, qt)
    if length(qt.points) == 0 return trees end
    for section in qt.cr
        append!(trees, generate_trees(section))
    end

    return trees
end

function contains(boundary::Sqr, p::Point)::Bool
    (
        p.x > boundary.x - boundary.s / 2 &&
        p.x < boundary.x + boundary.s / 2 &&
        p.y > boundary.y - boundary.s / 2 &&
        p.y < boundary.y + boundary.s / 2
    )
end

function intersects(A::Sqr, B::Sqr)::Bool
    !(
        A.x - A.s / 2 >= B.x + B.s / 2 ||
        A.x + A.s / 2 <= B.x - B.s / 2 ||
        A.y - A.s / 2 >= B.y + B.s / 2 ||
        A.y + A.s / 2 <= B.y - B.s / 2
    )
end

function subdivide!(qt::QuadTree{T}) where {T}
    qt.cr = QuadTree{T}.(get_subsquares(qt.boundary), qt.capacity)
end

function insert!(qt::QuadTree{T}, p::Point) where {T}
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
        
insert!(qt::QuadTree{T}, x::Real, y::Real) where {T} = insert!(qt, Point(x, y))

function query(qt::QuadTree{T}, bounds::Sqr)::Vector{T} where {T}
    found = Vector{T}()
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
