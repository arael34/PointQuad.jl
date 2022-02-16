using GameZero
game_include("PointQuad.jl")

const WIDTH = 800
const HEIGHT = 800
const BACKGROUND = colorant"black"

mutable struct P
    x::Real
    y::Real
    angle::Real
end

qt = PointQuad.QuadTree{P}(PointQuad.Sqr(WIDTH / 2, HEIGHT / 2, WIDTH), 2)

PointQuad.position(p::P) = (p.x, p.y)

function draw()
    for p in PointQuad.query(qt, PointQuad.Sqr(WIDTH/2, HEIGHT/2, WIDTH))
        if length(PointQuad.query(qt, PointQuad.Sqr(p.x, p.y, 12))) > 1
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 3), colorant"green", fill = true)
        else
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 3), colorant"white", fill = true)
        end
    end
    for sec in PointQuad.get_trees(qt)
        draw(Rect(trunc(Int, sec.boundary.x - sec.boundary.s / 2), trunc(Int, sec.boundary.y - sec.boundary.s / 2), trunc(Int, sec.boundary.s), trunc(Int, sec.boundary.s)), colorant"white", fill = false)
    end
end

function update()
    agents = PointQuad.query(qt, PointQuad.Sqr(WIDTH/2, HEIGHT/2, WIDTH))
    PointQuad.clear!(qt)
    for p in agents
        p.x -= 1
        PointQuad.insert!(qt, p)
    end
end

function on_mouse_down(v::Game, pos, button)
    PointQuad.insert!(qt, P(pos[1], pos[2], 0))
    if button == MouseButtons.RIGHT
        PointQuad.clear!(qt)
    end
end