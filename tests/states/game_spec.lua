-- tests/states/game_spec.lua
--
-- Example tests for src/states/game.lua.
-- Demonstrates two patterns used throughout this project:
--
--   1. Pure function tests — no love.* calls needed; test logic directly.
--   2. love.* mock tests — stub the love global before requiring the module
--      so draw() and keypressed() can be exercised without a running LÖVE instance.
--
-- Pattern for new state tests:
--   - Pure functions (newState, update, onEnter, onExit): test directly, no setup needed.
--   - Functions that call love.* (draw, keypressed with love.event): stub love before require.

describe("game state", function()

    -- -------------------------------------------------------------------------
    -- Pure function tests (no love.* involvement)
    -- -------------------------------------------------------------------------

    describe("newState", function()
        it("returns a table", function()
            local game = require("src.states.game")
            local state = game.newState()
            assert.is_table(state)
        end)

        it("includes a message field", function()
            local game = require("src.states.game")
            local state = game.newState()
            assert.is_string(state.message)
            assert.is_true(#state.message > 0)
        end)
    end)

    describe("update", function()
        it("returns a state table", function()
            local game = require("src.states.game")
            local state = game.newState()
            local nextState = game.update(state, 0.016)
            assert.is_table(nextState)
        end)

        it("does not mutate the input state", function()
            local game = require("src.states.game")
            local state = game.newState()
            local originalMessage = state.message
            game.update(state, 0.016)
            assert.equals(originalMessage, state.message)
        end)
    end)

    describe("onEnter", function()
        it("does not error when called with a previous state", function()
            local game = require("src.states.game")
            assert.has_no_error(function()
                game.onEnter({ message = "previous" })
            end)
        end)

        it("does not error when called with nil", function()
            local game = require("src.states.game")
            assert.has_no_error(function()
                game.onEnter(nil)
            end)
        end)
    end)

    describe("onExit", function()
        it("does not error when called with a state", function()
            local game = require("src.states.game")
            local state = game.newState()
            assert.has_no_error(function()
                game.onExit(state)
            end)
        end)
    end)

    -- -------------------------------------------------------------------------
    -- love.* mock tests
    --
    -- Stub the love global before requiring the module so LÖVE API calls in
    -- draw() and keypressed() can be exercised without a running LÖVE instance.
    --
    -- Use before_each to reset the stub and package.loaded before every test
    -- so modules are re-required cleanly against the current love stub.
    -- -------------------------------------------------------------------------

    describe("draw (with love stub)", function()
        local loveStub

        before_each(function()
            loveStub = {
                graphics = {
                    setColor = function(...) end,
                    print    = function(...) end,
                },
            }
            _G.love = loveStub
            package.loaded["src.states.game"] = nil
        end)

        after_each(function()
            _G.love = nil
            package.loaded["src.states.game"] = nil
        end)

        it("calls love.graphics.setColor", function()
            local callCount = 0
            loveStub.graphics.setColor = function(...) callCount = callCount + 1 end

            local game = require("src.states.game")
            game.draw(game.newState())

            assert.is_true(callCount > 0)
        end)

        it("calls love.graphics.print with the state message", function()
            local printedText

            loveStub.graphics.print = function(text, ...) printedText = text end

            local game = require("src.states.game")
            local state = game.newState()
            game.draw(state)

            assert.equals(state.message, printedText)
        end)
    end)

    describe("keypressed (with love stub)", function()
        before_each(function()
            _G.love = {
                graphics = {
                    setColor = function(...) end,
                    print    = function(...) end,
                },
                event = {
                    quit = function() end,
                },
            }
            package.loaded["src.states.game"] = nil
        end)

        after_each(function()
            _G.love = nil
            package.loaded["src.states.game"] = nil
        end)

        it("returns a state table for any key", function()
            local game = require("src.states.game")
            local state = game.newState()
            local nextState = game.keypressed(state, "space")
            assert.is_table(nextState)
        end)

        it("calls love.event.quit when escape is pressed", function()
            local quitCalled = false
            _G.love.event.quit = function() quitCalled = true end

            local game = require("src.states.game")
            game.keypressed(game.newState(), "escape")

            assert.is_true(quitCalled)
        end)

        it("does not call love.event.quit for other keys", function()
            local quitCalled = false
            _G.love.event.quit = function() quitCalled = true end

            local game = require("src.states.game")
            game.keypressed(game.newState(), "space")

            assert.is_false(quitCalled)
        end)
    end)

end)
