# love-template :sparkling_heart:

A template made with ♥ for [LÖVE](https://love2d.org/) projects with organized project structure and [LuaRocks](https://luarocks.org/) dependency management.

> [!IMPORTANT]
> This template requires **LÖVE 11.5**, **LuaJIT 2.1.0**, and **LuaRocks 3.11.1**. The install script handles all three.

> [!NOTE]
> The following template was created with the assistance of using LLM "agents" that leverages the agent control framework of [OpenAgent Control](https://github.com/darrenhinde/OpenAgentsControl?tab=readme-ov-file#openagents-control-oac) & [opencode](https://opencode.ai). 
> The overall intention of using these tools is to use them for what the are... as development tools and NOT replacements of developers or creators.
>
> I promise that while I use this template as a resource to explore game development, game assets (artwork, music, dialog, soundeffects, etc.) will be human made. From the game software development side -
> agents will be used as tools to "automate the boring stuff", have reference data that follows the development best practices, and changes be reviewed by a human that has experience with writing and reviewing code.
> No, the number of lines or number of commits are NOT considered valid representations of development experience or skill...
>
> When using this template I ask that you follow this approach, but it's up to you to choose what future you want to shape. 

## Setup

### 1. Get the template

**Use this template** *(recommended for new projects)*

Click **Use this template** on GitHub to create a new repository with a clean history.

**Fork**

Fork this repository if you want to contribute changes back upstream or track future updates to the template in your own project.

**Clone**

```bash
git clone git@github.com:jordan-begian/love-template.git my-game
cd my-game
```

### 2. Install dependencies

```bash
./setup.sh
```

> [!TIP]
> If the script isn't executable - run the following from project root:
>
> ```bash
> chmod +x setup.sh
> ```

This script checks whether `make` is installed first. If it is, it hands off to `make deps` immediately. If not, it installs `make` for your platform and then hands off. `make deps` then checks and installs LÖVE, LuaJIT, and LuaRocks.

Pinned versions are read from `scripts/versions.env` — the single source of truth for all dependency versions.

### 3. Run the setup wizard

```bash
make configure
```

The wizard walks through each optional component interactively:

| Step | What it configures |
|---|---|
| Git remote | Updates `source.url` and `description.homepage` in the rockspec, or clears them if no remote is provided |
| Git hooks | Activates `.githooks/` for conventional commits and luacheck |
| VS Code | Copies `.vscode.example/` → `.vscode/`, or removes the example if not needed |
| config.mk | Copies `config.mk.example` → `config.mk` for local build overrides, or removes the example if not needed |
| OpenCode | Keeps or removes `.opencode/` (AI development context — see [docs/opencode.md](docs/opencode.md)) |
| LuaRocks | Auto-detects your LuaJIT install and writes `.luarocks/config-5.1.lua` |
| LUA_VERSION | Writes `scripts/lua-env.sh` with `export LUA_VERSION=5.1` |

For VS Code, config.mk, and OpenCode: if you're not on the original template repo and decline the option, the example files/directories are deleted from your project automatically.

**LUA_VERSION** must be set in your shell environment before running `make install`. Activate it for the current session:

```bash
source scripts/lua-env.sh
```

To set it globally, add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):
👀 _Check out my [dotfiles](https://github.com/jordan-begian/dotfiles) repo for an example of an organized setup for your systems services and dev tooling configs!_

```bash
export LUA_VERSION=5.1
```

### 4. Run the game

```bash
make run
# or directly:
love .
```

## Project Structure

```
my-game/
├── Makefile                        # Root forwarder — delegates all targets to scripts/Makefile
├── main.lua                        # LÖVE entry point
├── conf.lua                        # Window and module configuration
├── scripts/
│   ├── Makefile                    # make run | build | deps | configure | install | test | clean | help
│   ├── install-deps.sh             # Bootstraps make, then hands off to make deps
│   ├── lua-env.sh                  # Sets LUA_VERSION — source in shell profile or session
│   ├── versions.env                # Pinned dependency versions (LÖVE, LuaJIT, LuaRocks)
│   └── tests/
│       └── assert-structure.sh     # Structural assertions (file presence, versions, rockspec)
├── .github/
│   └── workflows/
│       └── pull_request.yml        # CI pipeline: lint → unit tests → structure → dry-run
├── .githooks/
│   ├── pre-commit                  # Removes .gitkeep from populated dirs; runs luacheck
│   └── commit-msg                  # Enforces conventional commits format
├── src/
│   ├── main.lua                    # Imperative shell — holds state, wires LÖVE callbacks
│   ├── states/                     # One file per game scene
│   │   └── game.lua                # Example state
│   ├── systems/                    # Pure functions: (state, dt) → state
│   ├── types/                      # Factory functions returning plain data tables
│   └── utils/
│       └── luarocks_config.lua     # LuaRocks path setup
├── tests/
│   ├── states/
│   │   └── game_spec.lua           # Example: pure function + love.* mock tests
│   ├── systems/                    # Add spec files here as systems are created
│   └── types/                      # Add spec files here as types are created
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
├── docs/
│   └── reference/
│       ├── conventions.md          # Abbreviated names and domain terms
│       └── testing.md              # Testing reference: patterns, assertions, how to add a spec
└── love-template-dev-1.rockspec    # Dependency declarations
```

## Git Hooks

Activate with `make configure` (the wizard handles this interactively). Hooks live in `.githooks/` and are committed to the repo.

| Hook | Trigger | What it does |
|---|---|---|
| `pre-commit` | Every commit | Removes `.gitkeep` from directories that now contain other files; runs `luacheck` on staged Lua files to catch accidental globals (skipped with a warning if `luacheck` is not installed) |
| `commit-msg` | Every commit | Enforces [conventional commits](https://www.conventionalcommits.org) format: `<type>(optional scope): <description>` |

**Conventional commit types:** `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`

```
feat: add player movement system
fix(states): prevent nil state on first load
chore: update dependencies
```

## Testing

Run all checks (lint + unit tests + structural assertions):

```bash
make test
```

Run only busted unit tests:

```bash
make test-lua
```

Tests live in `tests/` and mirror the structure of `src/`. `tests/states/game_spec.lua` is the canonical example — it demonstrates both test patterns used in this project: pure function tests (no LÖVE needed) and love.* mock tests using a `_G.love` stub.

See [docs/reference/testing.md](docs/reference/testing.md) for the full reference on what to test, both patterns with examples, and how to add a new spec file.

## Adding Dependencies

1. Declare the dependency in `love-template-dev-1.rockspec`:

```lua
dependencies = {
   "lua == 5.1",
   "inspect >= 3.1.0"
}
```

2. Install it:

```bash
make install
```

3. Use it in your code:

```lua
local inspect = require("inspect")
```

## Reference

- [Conventions](docs/reference/conventions.md) — abbreviated names and industry terms used in this codebase (`dt`, `t`, `dx`/`dy`, etc.)
- [Testing](docs/reference/testing.md) — test patterns, busted assertions, and how to add a spec
- [OpenCode](docs/opencode.md) — optional AI development setup using OpenCode and OpenAgent

## AI Development (Optional)

This template includes optional AI development support via [OpenCode](https://opencode.ai) — an open source AI coding agent — configured with a custom **OpenAgent** that understands this project's architecture and conventions.

The `.opencode/context/project-intelligence/` directory contains two context files the agent reads before writing any code or documentation:

- `technical-domain.md` — stack, architecture, naming conventions, code standards, packaging
- `navigation.md` — project layout, where to find things, how code flows

This keeps AI-generated code consistent with the functional-core/imperative-shell architecture, Lua conventions, and project patterns established in this template.

**The template is fully functional without OpenCode.** You can delete `.opencode/` entirely if you don't plan to use it.

See [docs/opencode.md](docs/opencode.md) for full details on setup and how it works.

**Links**
- [OpenCode](https://opencode.ai) — official site
- [OpenCode GitHub](https://github.com/anomalyco/opencode) — source and releases
- [OpenCode Docs](https://opencode.ai/docs) — installation and configuration
- [OpenAgent Reference](https://github.com/darrenhinde/OpenAgentsControl?tab=readme-ov-file#openagents-control-oac) — agent configuration and control
