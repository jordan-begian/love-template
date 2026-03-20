local game = require("src.states.game")

local state

function love.load()
    state = game.newState()
end

function love.update(dt)
    dt = math.min(dt, 0.1)
    state = game.update(state, dt)
end

function love.draw()
    game.draw(state)
end

function love.keypressed(key)
    if game.keypressed then
        state = game.keypressed(state, key)
    end
end
