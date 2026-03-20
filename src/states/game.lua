local game = {}

function game.newState()
	return {
		message = [[
Hello, LÖVE!

Take a look at the README.md to see where to go from here! ]],
	}
end

function game.update(state, dt)
	return state
end

function game.draw(state)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(state.message, 10, 10)
end

function game.keypressed(state, key)
	if key == "escape" then
		love.event.quit()
	end
	return state
end

function game.onEnter(previousState) end

function game.onExit(state) end

return game
