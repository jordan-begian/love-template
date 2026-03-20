# Testing

This project uses [busted](https://lunarmodules.github.io/busted/) for Lua unit tests. Tests live in `tests/` and mirror the structure of `src/`.

```
tests/
├── states/     ← one spec file per state module
├── systems/    ← one spec file per system module
└── types/      ← one spec file per type module
```

Run all checks:

```bash
make test
```

Run only unit tests:

```bash
make test-lua
```

---

## What to test and what not to

### Test these (pure Lua — no LÖVE needed)

- `newState()` — returns the expected table shape
- `update(state, dt)` — returns a new state, does not mutate input
- `onEnter` / `onExit` — do not error, return expected values
- Systems — given an input state, return the correct output state
- Type factories — return tables with expected fields and types

### Test these (with a `love` stub)

- `draw(state)` — calls the expected `love.graphics.*` functions
- `keypressed(state, key)` — triggers the right `love.event.*` calls
- Any function that branches on `love.*` state

### Don't test

- `love.load()` / the imperative shell in `src/main.lua` — this is the boundary; it has no logic of its own
- Asset loading side effects — test that assets are *referenced*, not that they load correctly (that requires a running LÖVE instance)
- LÖVE rendering output — not feasible without a GPU

---

## Pure function tests

Pure functions take a state table and return a new state table. No `love.*` calls. No setup required.

```lua
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
```

**Pattern**: always verify both the return value *and* that the input was not mutated. The functional-core architecture depends on this contract holding.

---

## love.* mock tests

When a function calls `love.*` APIs, stub the `love` global before requiring the module. Use `before_each` to reset the stub and clear `package.loaded` so each test gets a clean require.

### Minimal stub pattern

```lua
describe("draw (with love stub)", function()
    before_each(function()
        _G.love = {
            graphics = {
                setColor = function(...) end,
                print    = function(...) end,
            },
        }
        package.loaded["src.states.game"] = nil
    end)

    after_each(function()
        _G.love = nil
        package.loaded["src.states.game"] = nil
    end)

    it("calls love.graphics.print with the state message", function()
        local printedText

        _G.love.graphics.print = function(text, ...) printedText = text end

        local game = require("src.states.game")
        local state = game.newState()
        game.draw(state)

        assert.equals(state.message, printedText)
    end)
end)
```

### Why `package.loaded` must be cleared

Lua caches `require` results in `package.loaded`. If you set `_G.love` *after* a module has already been required in a previous test, the module closure still holds the old (nil) reference. Clearing `package.loaded["src.states.game"]` before each test forces a fresh require against the current `_G.love` stub.

### Tracking calls with a counter

```lua
it("calls love.graphics.setColor at least once", function()
    local callCount = 0
    _G.love.graphics.setColor = function(...) callCount = callCount + 1 end

    local game = require("src.states.game")
    game.draw(game.newState())

    assert.is_true(callCount > 0)
end)
```

### Stubbing love.event

```lua
before_each(function()
    _G.love = {
        graphics = { setColor = function(...) end, print = function(...) end },
        event    = { quit = function() end },
    }
    package.loaded["src.states.game"] = nil
end)

it("calls love.event.quit when escape is pressed", function()
    local quitCalled = false
    _G.love.event.quit = function() quitCalled = true end

    local game = require("src.states.game")
    game.keypressed(game.newState(), "escape")

    assert.is_true(quitCalled)
end)
```

---

## File naming and structure

| Source file | Test file |
|---|---|
| `src/states/game.lua` | `tests/states/game_spec.lua` |
| `src/systems/movement.lua` | `tests/systems/movement_spec.lua` |
| `src/types/player.lua` | `tests/types/player_spec.lua` |

busted discovers test files by the `_spec.lua` suffix. The `tests/` directory mirrors `src/` so it is always clear which spec covers which module.

---

## Useful busted assertions

```lua
assert.is_table(value)
assert.is_string(value)
assert.is_number(value)
assert.is_boolean(value)
assert.is_nil(value)
assert.is_true(value)
assert.is_false(value)
assert.equals(expected, actual)
assert.not_equals(unexpected, actual)
assert.has_no_error(function() ... end)
assert.has_error(function() ... end)
```

---

## Adding a new spec file

1. Create `tests/<layer>/<module>_spec.lua`
2. Mirror the `describe` blocks to the module's public functions
3. Test pure functions directly; stub `love` for anything that calls `love.*`
4. Run `make test-lua` to verify

See `tests/states/game_spec.lua` for a complete working example of both patterns.
