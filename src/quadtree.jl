module arael

import Base: push!, append!, insert!, length, in, /

const Point = Tuple{Real, Real}

sq_distance(x1, y1, x2, y2) = (x2 - x1) ^ 2 + (y2 - y1) ^ 2
distance(x1, y1, x2, y2) = sqrt(sq_disance(x1, y1, x2, y2))

position((x, y)::Point) = (x, y)

abstract type Boundary end

struct Sqr <: Boundary
    x::Real
    y::Real
    s::Real
end

/(sq::Sqr, n::Real) = Sqr(sq.x, sq.y, sq.s / n)

function in(point::Point, sq::Sqr)
    ss = sq.s / 2
    point.x >= sq.x - ss &&
    point.x <= sq.x + ss &&
    point.y >= sq.y + ss &&
    point.y <= sq.y + ss 
end

function in(sq1::Sqr, sq2::Sqr)
    s1 = sq1.s / 2
    s2 = sq2.s / 2
    return !(
        sq1.x - s1 > sq2.x + s2 ||
        sq1.x + s1 < sq2.x - s2 ||
        sq1.y - s1 > sq2.y + s2 ||
        sq1.y + s1 < sq2.y - s2
    )
end

function vertices(sq::Sqr)
    ss = sq.s / 2
    return Point[
        (sq.x - ss, sq.y - ss)
        (sq.x + ss, sq.y - ss)
        (sq.x + ss, sq.y + ss)
        (sq.x - ss, sq.y + ss)
    ]
end

struct Circle <: Boundary
    x::Real
    y::Real
    r::Real
end

/(c::Circle, n::Real) = Circle(c.x, c.y, c.r / n)

function in(point::Point, c::Circle)
    sq_d = sq_distance(point.x, point.y, c.x, c.y)
    return sq_d <= c.r ^2
end

function in(c1::Circle, c2::Circle)
    sq_d = sq_distance(c2.x, c2.y, c1.x, c1.y)
    return sq_d < c1.r + c2.r
end

function in(c::Circle, sq::Sqr)
    dx = abs(sq.x - c.x)
    dy = abs(sq.y - c.y)
    s = sq.s / 2
    if dx > c.r + s || dy > c.r + s return false end
    if dx <= s || dy <= s return true end
    return (dx - s) ^ 2 + (dy - s) ^ 2 <= r ^ 2
end

in(sq::Sqr, c::Circle) = c in sq

mutable struct QuadTree
    bound::Sqr
    capacity::Int
    points::Vector{Point}()
    sections::Vector{QuadTree}()
end 

isleaf(qt::QuadTree) = isempty(qt.sections)

function insert!(qt::QuadTree, p::Point)::Bool
    !(p in qt.bound) && return false
    if length(qt.points) < qt.capacity
        push!(qt.points, p)
        return true
    else
        isleaf(qt) && subdivide!(qt)
        for section in qt.sections
            if insert!(section, p)
                return true
            end
        end
    end
end

function subdivide!(qt::QuadTree)
    s = qt.bound.s
    points = vertices(qt.bound / 2)
    for point in points
        push!(qt.sections, QuadTree(point.x, point.y, s/2, qt.capacity))
    end
end

push!(qt::QuadTree, points::Point...) = begin
    for point in points
        insert!(qt, point)
    end
end

append!(qt::QuadTree, col::Vector{Point}...) = begin
    for points in col
        push!(qt, points...)
    end
end

size(qt::QuadTree) = length(qt.points)

function query(qt::QuadTree, bounds::Boundary)
    result = Vector{Point}()
    if bounds in qt.bound
        append!(result, filter(p -> p in bounds, qt.points))
        if !isleaf(qt)
            for section in qt.sections
                append(result, query(section, bounds))
            end
        end
    end
end

function search(qt::QuadTree, x::Real, y::Real, rad::Real)
    return query(qt, Circle(x, y, rad))
end

position(p::Point) = 

end