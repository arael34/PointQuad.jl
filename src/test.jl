using GameZero
game_include("PointQuad.jl")

const WIDTH = 800
const HEIGHT = 800
const BACKGROUND = colorant"black"

mutable struct P
    x::Real
    y::Real
end

const qt = PointQuad.QuadTree{P}(PointQuad.Sqr(WIDTH / 2, HEIGHT / 2, WIDTH), 4)

PointQuad.position(p::P) = (trunc(Int, p.x), trunc(Int, p.y))

function init()
    for _ in 1:1200
        PointQuad.insert!(qt, P(rand(1:WIDTH - 1), rand(1:HEIGHT - 1)))
    end
end

init()

function draw()
    for p in PointQuad.get_points(qt)
        p.x += rand(-1:1)
        p.y += rand(-1:1)
        if length(PointQuad.query(qt, PointQuad.Sqr(p.x, p.y, 16))) > 1
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 4), colorant"green", fill = true)
        else
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 4), colorant"white", fill = true)
        end
    end
    agents = PointQuad.get_points(qt)
    PointQuad.clear!(qt)
    for lol in agents
        PointQuad.insert!(qt, lol)
    end
    agents = nothing
end