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

const qt = PointQuad.QuadTree{P}(PointQuad.Sqr(WIDTH / 2, HEIGHT / 2, WIDTH), 4)

PointQuad.position(p::P) = (trunc(Int, p.x), trunc(Int, p.y))

function draw()
    agents = PointQuad.get_points(qt)
    PointQuad.clear!(qt)
    for p in agents
        if length(PointQuad.query(qt, PointQuad.Sqr(p.x, p.y, 12))) > 1
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 0), colorant"green", fill = true)
        else
            draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 0), colorant"white", fill = true)
        end
        new_x, new_y = p.x + cos(p.angle), p.y + sin(p.angle)
        if new_x < 5 || new_x >= WIDTH - 5 || new_y < 5 || new_y >= HEIGHT - 5
            new_x = min(WIDTH - 5, max(5, new_x))
            new_y = min(HEIGHT - 5, max(5, new_y))
            p.angle = rand() * 2 * π
        end
        p.x, p.y = new_x, new_y
        PointQuad.insert!(qt, p)
    end
    agents = nothing
    for sec in PointQuad.get_trees(qt)
        draw(Rect(trunc(Int, sec.boundary.x - sec.boundary.s / 2), trunc(Int, sec.boundary.y - sec.boundary.s / 2), trunc(Int, sec.boundary.s), trunc(Int, sec.boundary.s)), colorant"white", fill = false)
    end
end

function on_mouse_move(g::Game, pos)
    PointQuad.insert!(qt, P(pos[1], pos[2], rand() * 2 * π))
end