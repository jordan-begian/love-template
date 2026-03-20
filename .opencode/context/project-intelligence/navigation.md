<!-- Context: project-intelligence/navigation | Priority: critical | Version: 1.4 | Updated: 2026-03-20 -->

# Project Navigation — LÖVE2D Game Template

## Quick Orientation

This is a **template** for LÖVE2D games. Its purpose is to give developers a clean, opinionated starting point with a functional-core/imperative-shell architecture. The template itself is evolving — new tooling and practices are added over time.

---

## Project Layout

```
my-game/
├── Makefile                        ← Root forwarder — delegates all targets to scripts/Makefile
├── setup.sh                        ← First-time setup entry point — runs scripts/install-deps.sh
├── main.lua                        ← LÖVE entry (~4 lines): requires src/main
├── conf.lua                        ← Window + module config
├── config.mk.example               ← Documents Makefile variables (committed)
├── config.mk                       ← Local overrides (gitignored)
├── scripts/
│   ├── Makefile                    ← make run | build | deps | configure | install | test | clean | help
│   ├── install-deps.sh             ← Bootstraps make, then hands off to make deps
│   ├── lua-env.sh                  ← Sets LUA_VERSION — source in shell profile or session
│   ├── versions.env                ← Pinned versions (LÖVE, LuaJIT, LuaRocks)
│   └── tests/
│       └── assert-structure.sh     ← Structural assertions (file presence, versions, rockspec)
├── .github/
│   ├── dependabot.yml              ← Weekly GitHub Actions dependency updates
│   └── workflows/
│       └── pull_request.yml        ← CI pipeline: lint → unit tests → structure → dry-run
├── .githooks/
│   ├── pre-commit                  ← Removes .gitkeep from populated dirs; runs luacheck
│   └── commit-msg                  ← Enforces conventional commits format
├── src/
│   ├── main.lua                    ← Imperative shell: state var + LÖVE callbacks
│   ├── states/                     ← One file per game scene
│   │   └── game.lua                ← Example state (newState/update/draw/...)
│   ├── systems/                    ← Pure functions: (state, dt) → state
│   ├── types/                      ← Factory functions returning plain tables
│   └── utils/
│       └── luarocks_config.lua     ← LuaRocks path setup + LUA_VERSION assert
├── tests/
│   ├── states/
│   │   └── game_spec.lua           ← Canonical example: pure function + love.* mock tests
│   ├── systems/                    ← Add spec files here as systems are created
│   └── types/                      ← Add spec files here as types are created
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
├── docs/
│   └── reference/
│       ├── conventions.md          ← Abbreviated names and domain terms
│       └── testing.md              ← Testing reference: patterns, assertions, how to add a spec
├── lua_modules/                    ← Project-local LuaRocks packages
├── .luarocks/
│   └── config-5.1.lua              ← LuaRocks config (LuaJIT / Lua 5.1)
└── love-template-dev-1.rockspec    ← Dep declarations
```

---

## Where to Find Things

| Need | Go to |
|---|---|
| Add a new scene | `src/states/` — create `my_scene.lua`, implement state interface |
| Add game logic | `src/systems/` — pure function `(state, dt) → state` |
| Define a data shape | `src/types/` — factory function `newFoo() → table` |
| Add a utility | `src/utils/` — pure helper, return a table of functions |
| Change window config | `conf.lua` |
| Add a dependency | `love-template-dev-1.rockspec` (declare first), then `make install` |
| Install/check core deps | `./setup.sh` (first-time entry point) or `./scripts/install-deps.sh` directly |
| Override build vars | `config.mk` (copy from `config.mk.example`) |
| Build / run / package | `Makefile` (root) → `scripts/Makefile` — run `make help` for all targets |
| Run all tests | `make test` (lint + unit tests + structure assertions) |
| Run unit tests only | `make test-lua` (busted under LuaJIT) |
| Add a test | `tests/<layer>/<module>_spec.lua` — see `tests/states/game_spec.lua` for both patterns |
| Understand test patterns | `docs/reference/testing.md` |
| Understand naming rules | `docs/reference/conventions.md` |
| Understand CI pipeline | `.github/workflows/pull_request.yml` |
| Understand dependency updates | `.github/dependabot.yml` |

---

## How Code Flows

```
LÖVE runtime
    ↓
main.lua (root)          requires src/main
    ↓
src/main.lua             holds `state`, wires love.load / love.update / love.draw
    ↓
src/states/<scene>.lua   newState() / update(s, dt) / draw(s)
    ↓
src/systems/             pure logic called by state.update
src/types/               data shapes used by state.newState
```

State transitions: `src/main.lua` swaps which state module is active and calls `onExit` / `onEnter`.

---

## Key Entry Points

| Task | File |
|---|---|
| Start reading code | `src/main.lua` |
| Understand a scene | `src/states/<scene>.lua` |
| Understand game logic | `src/systems/<system>.lua` |
| Understand data shapes | `src/types/<type>.lua` |
| Understand build system | `scripts/Makefile` + `config.mk.example` |
| Understand dep setup | `love-template-dev-1.rockspec` + `src/utils/luarocks_config.lua` |

---

## Scaffolded But Empty

The template ships these directories with `.gitkeep` placeholders. They exist but are intentionally empty until the developer adds content:

- `src/states/` — contains `game.lua` as an example; add more scenes here
- `src/systems/` — empty; add pure function system files here
- `src/types/` — empty; add factory function files here
- `tests/systems/` — empty; add spec files here as systems are created
- `tests/types/` — empty; add spec files here as types are created
- `assets/images/`, `assets/sounds/`, `assets/fonts/` — empty; add game assets here

`.gitkeep` files are automatically removed by the `pre-commit` hook once a directory contains real files.

---

## Context Files

| File | What it covers |
|---|---|
| `.opencode/context/project-intelligence/technical-domain.md` | Stack, architecture, naming, standards, security, packaging, testing |
| `.opencode/context/project-intelligence/navigation.md` | This file — layout, flow, entry points |
