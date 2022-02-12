#=
TODO
clean up, especially visualization script
=#
module PointQuad

export
    Point,
    Sqr,
    position,
    get_pos,
    QuadTree,
    isleaf,
    clear!,
    get_subsquares,
    get_trees,
    contains,
    intersects,
    subdivide!,
    insert!,
    query

const Point = Tuple{Int32, Int32}

mutable struct Sqr
    x::Real
    y::Real
    s::Real
end

position((x, y)::Point) = (x, y)

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

function get_trees(qt::QuadTree{T})::Vector{QuadTree{T}} where {T}
    trees = Vector{QuadTree{T}}()
    push!(trees, qt)
    if length(qt.points) == 0 return trees end
    for section in qt.cr
        append!(trees, get_trees(section))
    end

    return trees
end

function contains(boundary::Sqr, p::Point)::Bool
    (
        p[1] > boundary.x - boundary.s / 2 &&
        p[1] < boundary.x + boundary.s / 2 &&
        p[2] > boundary.y - boundary.s / 2 &&
        p[2] < boundary.y + boundary.s / 2
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

function insert!(qt::QuadTree{T}, obj::T) where {T}
    p = position(obj)
    if !contains(qt.boundary, p) return nothing end
    if length(qt.points) < qt.capacity
        push!(qt.points, obj)
    else
        if isleaf(qt)
            subdivide!(qt)
        end
        for quad in qt.cr
            insert!(quad, obj)
        end
    end
end

function query(qt::QuadTree{T}, bounds::Sqr)::Vector{T} where {T}
    found = Vector{T}()
    if !intersects(qt.boundary, bounds) return found end
    for obj in qt.points
        if !contains(bounds, position(obj)) continue end
        push!(found, obj)
    end
    if isleaf(qt) return found end
    for section in qt.cr
        append!(found, query(section, bounds))
    end

    return found
end

end # module
