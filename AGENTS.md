<!-- AGENTS.md — Quick reference for developers and AI agents -->

# AGENTS.md — Quick Reference

This is a **LÖVE2D game template** with a functional-core/imperative-shell architecture. Use this file to understand how to build, test, and write code in this project.

For deeper context, see:
- `.opencode/context/project-intelligence/technical-domain.md` — full architecture, naming, standards, testing patterns, security, packaging
- `.opencode/context/project-intelligence/navigation.md` — project layout, file structure, code flow
- `docs/reference/testing.md` — testing patterns, assertions, how to add specs
- `docs/reference/conventions.md` — naming abbreviations (dt, dx/dy, etc.)

---

## Quick Command Reference

| Command | Purpose |
|---|---|
| `make help` | List all available targets |
| `make run` | Run game from source |
| `make build` | Package game as `.love` file (runs clean + runtime dep install first) |
| `make install` | Install all Lua dependencies via LuaRocks (runtime + dev/test) |
| `make test` | Run all checks: lint + unit tests + structure assertions |
| `make test-lua` | Run unit tests only (busted under LuaJIT) |
| `make test-lint` | Run linter (luacheck) on src/ and tests/ |
| `make clean` | Remove build artifacts |
| `make configure` | Interactive project setup wizard (run once after cloning) |

---

## Running a Single Test

```bash
# Run all tests in a file
busted --lua=luajit tests/states/game_spec.lua

# Run tests matching a pattern
busted --lua=luajit tests/states/game_spec.lua -f "does not mutate"
```

**Requirement**: Set `LUA_VERSION` in your shell before running tests:
```bash
source scripts/lua-env.sh
```

---

## Code Style at a Glance

| Element | Style | Example |
|---|---|---|
| **Indentation** | 4 spaces (not tabs) | |
| **Functions** | camelCase | `newState()`, `updatePlayer()` |
| **Constants** | UPPER_SNAKE_CASE | `MAX_SPEED`, `SCREEN_WIDTH` |
| **Local variables** | camelCase | `playerState`, `nextFrame` |
| **File names** | snake_case | `player_movement.lua` |
| **Modules** | Always `local`, return table | `return { newState = ..., update = ... }` |
| **Requires** | Dot notation | `require("src.states.game")` |
| **No globals** | Ever | Always `local` |
| **No OOP** | Plain tables only | No metatables — behavior in pure functions |

See `docs/reference/conventions.md` for abbreviations like `dt` (delta time), `dx`/`dy` (position delta).

---

## State Module Contract

Every state module in `src/states/` must return a table with these functions:

```lua
return {
    -- Required
    newState   = function() end,            -- returns initial state table
    update     = function(state, dt) end,   -- returns new state (no mutation)
    draw       = function(state) end,       -- renders using love.graphics

    -- Optional
    keypressed = function(state, key) end,  -- returns new state
    onEnter    = function(previousState) end,
    onExit     = function(state) end,
}
```

**State reassignment pattern** (functional, not mutating):
```lua
-- correct
state = game.update(state, dt)

-- wrong — never mutate state directly
state.x = state.x + dt
```

---

## Testing Quick Start

Tests use busted under LuaJIT. Test files live in `tests/` and mirror `src/` structure.

### Pattern 1 — Pure Functions (no love.* calls)

Test logic directly. Always verify both the return value and that the input was not mutated:

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
        local original = state.message
        game.update(state, 0.016)
        assert.equals(original, state.message)
    end)
end)
```

### Pattern 2 — love.* Mock Tests

Stub `_G.love` before requiring the module. Clear `package.loaded` in `before_each` to force a fresh require against the current stub:

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

**Why `package.loaded` must be cleared**: Lua caches `require` results. A module required before `_G.love` was stubbed holds a closure over the nil reference. Clearing the cache forces a fresh require against the current stub.

See `docs/reference/testing.md` for full patterns, assertions, and how to add a new spec.

---

## Dependencies

All Lua dependencies are declared in `love-template-dev-1.rockspec` before installing:

1. Add the package to `dependencies` (runtime) or `test_dependencies` (dev/test) in the rockspec
2. Run `make install` to install to the project-local `lua_modules/` tree

The rockspec uses format 3.0 and targets `lua >= 5.1, < 5.2` (LuaJIT).

---

## Key Project Files

| File / Directory | Purpose |
|---|---|
| `scripts/Makefile` | All build targets (run, build, test, deps, clean, etc.) |
| `love-template-dev-1.rockspec` | Lua dependency declarations |
| `src/main.lua` | Imperative shell — holds state, wires LÖVE callbacks |
| `src/states/` | Scene modules — one per game scene |
| `src/systems/` | Pure function logic — `(state, dt) -> state` |
| `src/types/` | Type/data factories — return plain tables |
| `src/utils/luarocks_config.lua` | LuaRocks path setup at runtime |
| `tests/` | Unit tests — mirrors `src/` structure, `_spec.lua` suffix |
| `.luacheckrc` | Linter config (Lua 5.1, love/jit globals allowed) |

---

## Critical Notes

- **Lua version**: LuaJIT (Lua 5.1 semantics), NOT standard Lua 5.3+
- **LUA_VERSION env var**: Defaults to `"5.1"` if unset; `source scripts/lua-env.sh` to set it
- **No globals**: Always `local`; modules return a table of functions
- **Functional style**: Never mutate state; always reassign via `state = module.update(state, dt)`
- **Dependencies**: Declare in rockspec before running `make install`
- **Test structure**: Mirror `src/` in `tests/`; one spec file per module; use `_spec.lua` suffix

---

For more context, consult `.opencode/context/project-intelligence/` or `docs/reference/`.
