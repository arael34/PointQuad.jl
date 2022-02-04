mutable struct Particle
    x::Real
    y::Real
end

abstract type Boundary end

struct Sqr <: Boundary
    x::Real
    y::Real
    s::Real
end

function in(point::Particle, sq::Sqr)
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
    return Particle[
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

function in(point::Particle, c::Circle)
    x, y = point.x, point.y
end

mutable struct QuadTree
    bound::Sqr
    capacity::Int
    points::Vector{Particle}()
    sections::Vector{Quadtree}()
    QuadTree(init::Function) = (self = new(); init(self); self)
end 

function QuadTree(bound::Sqr, capacity::Int)
    return QuadTree() do self
        self.bound = bound
        self.capacity = capacity
        self.points = Vector{Particle}()
        self.sections = Vector{Quadtree}()
end

isleaf(qt::QuadTree) = isempty(qt.secitons)

function insert!(qt::QuadTree, p::Particle)::Bool
   
    if length(qt.points) < qt.capacity
        push!(qt.points, p)
        return true
    else
        isleaf(qt) && subdivide!(qt)
        for section in qt.sections
            if insert!(section, item)
                return true
            end
        end
    end
end

function subdivide!(qt::QuadTree)
    
    qt.sectons = QuadTree.(centers, length/2, qt.capacity)
end

push!(qt::QuadTree, points::Particle...) = begin
    for point in points
        insert!(qt, point)
    end
end

append!(qt::QuadTree, col::Vector{Particle}...) = begin
    for points in col
        push!(qt, points...)
    end
end

size(qt::QuadTree) = length(qt.points)

function query(qt::QuadTree, center::Tuple{Int, Int}, length::Int)

end

