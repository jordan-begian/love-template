# love-template :sparkling_heart:

A template to use for developing [LÖVE](https://love2d.org/) projects with organized project structure and [LuaRocks](https://luarocks.org/) dependency management.

## Prerequisites

Before using this template, you'll need to install:

### LÖVE2D

LÖVE is the game framework this template uses.

- **Official Downloads**: [https://love2d.org](https://love2d.org)

### Lua/LuaJIT

LÖVE uses LuaJIT (Lua 5.1 compatible), which is included with LÖVE. However, for LuaRocks compatibility, you may need LuaJIT installed separately:

- **Installation Guide**: [https://luajit.org/download.html](https://luajit.org/download.html)

### LuaRocks (Optional)

Only needed if you plan to use external Lua libraries.

- **Installation Guide**: [https://github.com/luarocks/luarocks/wiki/Download](https://github.com/luarocks/luarocks/wiki/Download)

## Setup

### 1. Clone or use this template

```bash
git clone git@github.com:jordan-begian/love-template.git my-game
cd my-game
```

### 2. Set up configuration files

Copy the example configurations to create your local settings:

```bash
cp -r .vscode.example .vscode \
cp -r .luarocks.example .luarocks \
rm -rf .vscode.example .luarocks.example;
```

**Note**: Adjust `.luarocks/config-5.1.lua` paths to match your system's LuaJIT installation:
- `LUA`: Path to luajit executable
- `LUA_INCDIR`: Path to LuaJIT headers (usually `/usr/include/luajit-2.1` or similar)

### 3. Set environment variable

Export the Lua version for LuaRocks:

```bash
export LUA_VERSION=5.1
```

Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to make it permanent.

### 4. Install dependencies (optional)

If you add dependencies to `love-template-dev-1.rockspec`, install them with:

```bash
# Install to project-local lua_modules
luarocks install --tree=lua_modules packagename

# Or install all dependencies from rockspec
luarocks install --tree=lua_modules --deps-only love-template-dev-1.rockspec
```

### 5. Run the game

```bash
love .
```

## Project Structure

```
love-template/
├── main.lua                     # Entry point (required by LÖVE)
├── src/
│   ├── main.lua                 # Main game code
│   └── utils/
│       └── luarocks_config.lua  # LuaRocks path configuration
├── .vscode.example/             # VS Code settings (copy to .vscode/)
├── .luarocks.example/           # LuaRocks config (copy to .luarocks/)
└── love-template-dev-1.rockspec # LuaRocks package specification
```

## Adding Dependencies Example

1. Add the dependency to `dependencies` in `love-template-dev-1.rockspec`:

```lua
dependencies = {
   "lua == 5.1",
   "inspect >= 3.1.0"
}
```

2. Install it:

```bash
luarocks install --tree=lua_modules inspect
```

3. Use it in your code:

```lua
local inspect = require("inspect")
```
