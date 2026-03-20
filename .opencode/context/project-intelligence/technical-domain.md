<!-- Context: project-intelligence/technical | Priority: critical | Version: 1.2 | Updated: 2026-03-20 -->

# Technical Domain — LÖVE2D Game Template

## Stack

| Layer | Tech |
|---|---|
| Runtime | LÖVE2D 11.5 + LuaJIT (Lua 5.1 — NOT standard Lua 5.x) |
| Language | Lua |
| Deps | LuaRocks, project-local tree (`lua_modules/`) |
| Build | `scripts/Makefile` |
| Editors | Neovim + AstroNvim (primary), VS Code + Lua LSP (secondary) |

> **Template evolves** — new dev tools and best practices added over time.

---

## Architecture: Functional Core, Imperative Shell

```
main.lua (root)           ← LÖVE entry (~4 lines), delegates immediately
src/main.lua              ← Imperative shell: holds mutable state, wires LÖVE callbacks
src/states/               ← Scene modules (one file per game scene)
src/systems/              ← Pure function systems: (state, dt) → state
src/types/                ← Factory functions returning plain data tables
src/utils/                ← Pure helpers, table-return modules
```

**The core rule**: behavior lives in systems, data lives in types. No methods on tables.

### State Reassignment Pattern

```lua
-- ✅ correct — functional reassignment
state = game.update(state, dt)

-- ❌ wrong — direct mutation
state.x = state.x + dt
```

### State Module Interface (every `src/states/` file)

```lua
-- Required
return {
    newState   = function()                  end,
    update     = function(state, dt)         end,
    draw       = function(state)             end,

-- Optional
    keypressed = function(state, key)        end,
    onEnter    = function(previousState)     end,
    onExit     = function(state)             end,
}
```

---

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files / modules | snake_case | `player_movement.lua` |
| Functions | camelCase | `newState()`, `drawPlayer()` |
| Type factories | `new` + noun | `newPlayer()`, `newPosition()` |
| Systems | verb + noun | `updateMovement()`, `drawHUD()` |
| Constants | UPPER_SNAKE | `MAX_SPEED`, `SCREEN_WIDTH` |
| Local vars | camelCase | `playerState`, `dt` |

Module require paths use dot notation: `require("src.types.player")`

---

## Code Standards

- **No metatables / OOP** — plain tables only; nesting is fine; behavior always in systems
- **Always `local`** — never pollute globals
- **Modules return a table of functions** — never bare globals
- **Assets loaded once** in `love.load()` / `newState()` — never inside `draw()`
- **`conf.lua` always present** at project root
- **4-space indentation**
- **Deps declared in rockspec** before installing
- **`LUA_VERSION` env var** — defaults to `5.1` if unset; set it in your shell profile to silence the startup warning

---

## Packaging (Makefile)

Config priority (lowest → highest): rockspec defaults → `config.mk` (gitignored) → CLI arg

```bash
make help          # list targets
make configure     # interactive project configuration wizard
make run           # run game with LÖVE
make build         # package .love file
make deps          # check and install core dependencies (LÖVE, LuaJIT, LuaRocks)
make deps-linux    # deps for Linux (yay → pacman → apt)
make deps-macos    # deps for macOS (Homebrew)
make deps-windows  # print manual install instructions for Windows
make install       # install Lua deps via LuaRocks
make clean         # remove build artifacts
make test          # run all checks: lint + unit tests + structure + dry-run
make test-lua      # run busted unit tests only
make test-lint     # run luacheck on src/ and tests/
make test-scripts  # run structural assertions (assert-structure.sh)
```

`make deps` is guarded — it must be invoked via `./setup.sh` (or `./scripts/install-deps.sh`
directly), which bootstraps `make` itself first. Direct calls to `make deps` are blocked unless
the env var `LOVE_TEMPLATE_BOOTSTRAP=true` is set (which the script sets before handing off).

`PLATFORM` arg controls C extension inclusion:
- Default (`none`): pure Lua only — warns if C deps detected
- `linux` | `macos` | `windows` | `all`: includes compiled binaries

`config.mk.example` is committed; `config.mk` is gitignored for local overrides.

---

## Security

- `LUA_VERSION` defaults to `"5.1"` at startup if unset — a warning is printed to the console but the game still runs
- Packages installed to `lua_modules/` — no global pollution
- Deps declared explicitly in rockspec
- Use `love.filesystem` for all file I/O (LÖVE sandbox)
- Validate save data on load — guard against corrupt/malformed data

---

## Testing

Tests use **busted** running under **LuaJIT**. Test files live in `tests/` and mirror the structure of `src/`.

```
tests/
├── states/     ← one spec file per state module
├── systems/    ← one spec file per system module
└── types/      ← one spec file per type module
```

Run all checks (lint + unit tests + structure assertions):

```bash
make test
```

Run only busted unit tests:

```bash
make test-lua   # busted --lua=luajit tests/
```

### Two patterns

**Pattern 1 — Pure function tests** (no `love.*` involvement): require the module and call it directly.

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

Always verify both the return value *and* that the input was not mutated — the functional-core contract depends on this.

**Pattern 2 — love.\* mock tests**: stub `_G.love` before requiring the module, then reset in `after_each`.

```lua
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
        package.loaded["src.states.game"] = nil   -- force fresh require against stub
    end)

    after_each(function()
        _G.love = nil
        package.loaded["src.states.game"] = nil
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
```

**Why `package.loaded` must be cleared**: Lua caches `require` results. If `_G.love` is set *after* a module was already required in a previous test, the module closure still holds the old (nil) reference. Clearing `package.loaded["src.states.game"]` in `before_each` forces a fresh require against the current stub.

**Call tracking with a counter** (when you need to assert a function was called, not its args):

```lua
it("calls love.graphics.setColor at least once", function()
    local callCount = 0
    loveStub.graphics.setColor = function(...) callCount = callCount + 1 end

    local game = require("src.states.game")
    game.draw(game.newState())

    assert.is_true(callCount > 0)
end)
```

### Canonical example

`tests/states/game_spec.lua` — demonstrates both patterns in a single file. Read this first when adding a new spec.

### Keeping assertions in sync

`scripts/tests/assert-structure.sh` must stay in sync with the project structure. When a required file, directory, or invariant changes:

- **Required file added/removed** → update the "Required files" section
- **Required directory added/removed** → update the "Required directories" section
- **Scaffolded empty dir added/removed** → update the `.gitkeep placeholders` for-loop list AND the Scaffolded But Empty section in `navigation.md`
- **New rockspec invariant** → update the "Rockspec" section

The assertion file has a labeled section for each category. The Makefile test targets section has a matching comment pointing here.

### What not to test

- `love.load()` / `src/main.lua` — the imperative shell has no logic of its own
- Asset loading side effects — requires a running LÖVE instance
- LÖVE rendering output — not feasible without a GPU

---

## 📂 Codebase References

| File | Purpose |
|---|---|
| `main.lua` | LÖVE entry point (~4 lines) |
| `conf.lua` | Window + module config |
| `scripts/versions.env` | Pinned dependency versions (LÖVE, LuaJIT, LuaRocks) — single source of truth |
| `src/main.lua` | Imperative shell — state var + LÖVE callbacks |
| `src/states/` | Scene modules |
| `src/systems/` | Pure function systems |
| `src/types/` | Factory/type definitions |
| `src/utils/luarocks_config.lua` | LuaRocks path setup + `LUA_VERSION` assertion |
| `love-template-dev-1.rockspec` | Dep declarations |
| `scripts/Makefile` | Build, run, deps, install, test, clean targets |
| `scripts/install-deps.sh` | Bootstraps make, then hands off to `make deps` |
| `scripts/tests/assert-structure.sh` | Structural assertions — file presence, versions.env format, rockspec invariants |
| `config.mk.example` | Documents Makefile variables (committed) |
| `config.mk` | Local overrides (gitignored) |
| `lua_modules/` | Project-local LuaRocks tree |
| `.luarocks/config-5.1.lua` | LuaRocks local config |
| `.githooks/pre-commit` | Removes `.gitkeep` from populated dirs; runs luacheck on staged Lua files |
| `.githooks/commit-msg` | Enforces conventional commits format |
| `.github/workflows/pull_request.yml` | CI pipeline — lint, unit tests, structure assertions, dry-run on push/PR |
| `tests/` | busted unit tests — mirrors `src/` structure |
| `tests/states/game_spec.lua` | Canonical example: pure function tests + love.* mock tests |
| `docs/reference/conventions.md` | Abbreviated names and domain terms (`dt`, `t`, `dx`/`dy`, etc.) |
| `docs/reference/testing.md` | Testing reference — patterns, assertions, how to add a spec |
