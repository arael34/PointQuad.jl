using GameZero
game_include("PointQuad.jl")

const WIDTH = 800
const HEIGHT = 800
const BACKGROUND = colorant"black"

struct P
    x::Real
    y::Real
end

pslol = Vector{P}()
foundp = Vector{P}()

cursor = PointQuad.Sqr(0, 0, 60)

qt = PointQuad.QuadTree{P}(PointQuad.Sqr(WIDTH / 2, HEIGHT / 2, WIDTH), 4)

PointQuad.position(P) = (P.x, P.y)

function draw(v::Game)
    for p in pslol
        draw(Circle(trunc(Int, p.x), trunc(Int, p.y), 1), colorant"white", fill = true)
    end
    #draw(Rect(400, 400, 400, 400))
    for sec in PointQuad.get_trees(qt)
        draw(Rect(trunc(Int, sec.boundary.x - sec.boundary.s / 2), trunc(Int, sec.boundary.y - sec.boundary.s / 2), trunc(Int, sec.boundary.s), trunc(Int, sec.boundary.s)), colorant"white", fill = false)
    end
    draw(Circle(trunc(Int, cursor.x), trunc(Int, cursor.y), trunc(Int, cursor.s / 2)), colorant"blue", fill = false)
    foundp = PointQuad.query(qt, PointQuad.Sqr(cursor.x, cursor.y, 60))
    for p1 in foundp
        draw(Circle(trunc(Int, p1.x), trunc(Int, p1.y), 3), colorant"green", fill = true)
    end
end

function on_mouse_down(v::Game, pos, button)
    PointQuad.insert!(qt, P(pos[1], pos[2]))
    push!(pslol, P(pos[1], pos[2]))
end

function on_mouse_move(v::Game, pos)
    cursor.x, cursor.y = pos[1], pos[2]
end
