# ==============================================================================
# LÖVE2D Game Makefile
# Usage: make [target] [PLATFORM=linux|macos|windows|all]
# ==============================================================================

# --- Dependency versions (single source of truth) ----------------------------

# Capture this Makefile's path before include appends versions.env to MAKEFILE_LIST
THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))

include $(dir $(THIS_MAKEFILE))versions.env
export LOVE_VERSION LUAJIT_VERSION LUAROCKS_VERSION

# --- Config loading (priority: rockspec < config.mk < CLI args) ---------------

-include config.mk

# Auto-parse GAME_NAME from rockspec if not set in config.mk or CLI
ifndef GAME_NAME
    ROCKSPEC := $(wildcard *.rockspec)
    ifdef ROCKSPEC
        GAME_NAME := $(shell grep -m1 '^package' $(ROCKSPEC) | sed 's/.*= *"\(.*\)".*/\1/')
        VERSION   := $(shell grep -m1 '^version' $(ROCKSPEC) | sed 's/.*= *"\(.*\)".*/\1/')
        # Strip rockspec revision suffix: "dev-1" → "dev", "1.0-1" → "1.0"
        VERSION   := $(shell echo $(VERSION) | sed 's/-[0-9]*$$//')
    else
        GAME_NAME := $(notdir $(CURDIR))
        VERSION   := 0.0.0
    endif
endif

# Defaults
PLATFORM  ?= none
BUILD_DIR ?= build
LOVE_FILE := $(BUILD_DIR)/$(GAME_NAME)-$(VERSION).love

# Exclude patterns for .love archive (no .loveignore — must be explicit).
# zip is invoked from PROJECT_ROOT so all archive paths are relative to the
# project root — no directory prefix needed.
LOVE_EXCLUDE := \
    --exclude ".git/*" \
    --exclude ".gitignore" \
    --exclude ".githooks/*" \
    --exclude ".github/*" \
    --exclude ".opencode/*" \
    --exclude ".luarocks/*" \
    --exclude ".luarocks.example/*" \
    --exclude ".luacheckrc" \
    --exclude ".tmp/*" \
    --exclude ".vscode/*" \
    --exclude ".vscode.example/*" \
    --exclude "$(BUILD_DIR)/*" \
    --exclude "lua_modules/lib/luarocks/*" \
    --exclude "scripts/*" \
    --exclude "tests/*" \
    --exclude "docs/*" \
    --exclude "Makefile" \
    --exclude "setup.sh" \
    --exclude "lua" \
    --exclude "luarocks" \
    --exclude "config.mk" \
    --exclude "config.mk.example" \
    --exclude "README.md" \
    --exclude "LICENSE" \
    --exclude "*.rockspec"

# ==============================================================================
# Targets
# ==============================================================================

.PHONY: help configure deps deps-linux deps-macos deps-windows run build install clean test test-lua test-lint test-scripts test-dry-run

## help: Show available targets (default)
help:
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@echo "  help           Show this message (default)"
	@echo "  configure      Interactive project configuration wizard (run once after cloning)"
	@echo "  deps           Check and install core dependencies (detects OS automatically)"
	@echo "  deps-linux     Check and install dependencies for Linux"
	@echo "  deps-macos     Check and install dependencies for macOS"
	@echo "  deps-windows   Print manual install instructions for Windows"
	@echo "  run            Run the game with LÖVE"
	@echo "  build          Package game into a .love file (runs clean + runtime dep install first)"
	@echo "  install        Install all Lua dependencies via LuaRocks (dev + test)"
	@echo "  clean          Remove build artifacts"
	@echo "  test           Run all checks (lint + unit tests + structure + dry-run)"
	@echo "  test-lua       Run busted unit tests in tests/"
	@echo "  test-lint      Run luacheck on src/ and tests/"
	@echo "  test-scripts   Run structural assertions (scripts/tests/assert-structure.sh)"
	@echo "  test-dry-run   Verify Makefile targets parse correctly (make -n)"
	@echo ""
	@echo "Variables (set in config.mk or on CLI):"
	@echo "  GAME_NAME   Game name (default: parsed from rockspec)"
	@echo "  PLATFORM    Target platform for C deps: none|linux|macos|windows|all (default: none)"
	@echo "  BUILD_DIR   Output directory (default: build)"
	@echo ""
	@echo "Examples:"
	@echo "  make run"
	@echo "  make test"
	@echo "  make build PLATFORM=linux"
	@echo "  make build GAME_NAME=mygame"
	@echo ""

# --- Setup wizard helpers -----------------------------------------------------

# Absolute path to project root (one level up from scripts/)
PROJECT_ROOT := $(abspath $(dir $(THIS_MAKEFILE))../)
ROCKSPEC     := $(wildcard $(PROJECT_ROOT)/*.rockspec)

# Detect whether we are running inside the template repo itself.
# Checks the git remote URL — if origin contains jordan-begian/love-template
# we treat this as the template repo and skip any delete-if-unwanted paths.
IS_TEMPLATE_REPO := $(shell \
	git -C "$(PROJECT_ROOT)" remote get-url origin 2>/dev/null | \
	grep -c 'jordan-begian/love-template' || echo 0)

## configure: Interactive project configuration wizard (run once after cloning)
configure:
	@echo ""
	@echo "============================================================"
	@echo "  love-template configure wizard"
	@echo "============================================================"
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 1 — Git remote / rockspec URLs
	@# ----------------------------------------------------------------
	@echo "Step 1/7  Git repository"
	@echo ""
	@ROCKSPEC_FILE="$(ROCKSPEC)"; \
	if [ -z "$$ROCKSPEC_FILE" ]; then \
		echo "  ⚠ No rockspec found — skipping rockspec URL update."; \
	else \
		CURRENT_URL=$$(grep 'source.*url' "$$ROCKSPEC_FILE" | grep -o '"[^"]*"' | tr -d '"'); \
		echo "  Current source.url: $$CURRENT_URL"; \
		echo ""; \
		printf "  Enter your git remote URL (leave blank to skip): "; \
		read REMOTE_URL; \
		if [ -n "$$REMOTE_URL" ]; then \
			HOMEPAGE=$$(echo "$$REMOTE_URL" | sed 's|git+ssh://git@github.com/||; s|\.git$$||; s|^|https://github.com/|'); \
			sed -i.bak \
				-e "s|url = \"[^\"]*\"|url = \"$$REMOTE_URL\"|" \
				-e "s|homepage = \"[^\"]*\"|homepage = \"$$HOMEPAGE?tab=readme-ov-file\"|" \
				"$$ROCKSPEC_FILE" && rm -f "$$ROCKSPEC_FILE.bak"; \
			echo "  ✓ Updated source.url and description.homepage in $$(basename $$ROCKSPEC_FILE)"; \
		elif [ "$(IS_TEMPLATE_REPO)" != "1" ]; then \
			sed -i.bak \
				-e 's|url = "[^"]*"|url = ""|' \
				-e 's|homepage = "[^"]*"|homepage = ""|' \
				"$$ROCKSPEC_FILE" && rm -f "$$ROCKSPEC_FILE.bak"; \
			echo "  ✓ Cleared source.url and description.homepage (not the template repo)."; \
		else \
			echo "  → Skipped (template repo — URLs left unchanged)."; \
		fi; \
	fi
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 2 — Git hooks
	@# ----------------------------------------------------------------
	@echo "Step 2/7  Git hooks"
	@echo ""
	@echo "  Hooks in .githooks/ enforce conventional commits and run luacheck"
	@echo "  on staged Lua files before every commit."
	@echo ""
	@printf "  Activate git hooks? [Y/n]: "; \
	read USE_HOOKS; \
	USE_HOOKS=$$(echo "$${USE_HOOKS:-y}" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$USE_HOOKS" != "n" ]; then \
		git -C "$(PROJECT_ROOT)" config core.hooksPath .githooks; \
		echo "  ✓ Git hooks configured."; \
	else \
		echo "  → Skipped."; \
	fi
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 3 — VS Code
	@# ----------------------------------------------------------------
	@echo "Step 3/7  VS Code"
	@echo ""
	@echo "  .vscode.example/ contains launch and settings files for the"
	@echo "  Lua Language Server and LÖVE debugger."
	@echo ""
	@printf "  Set up VS Code config? [y/N]: "; \
	read USE_VSCODE; \
	USE_VSCODE=$$(echo "$${USE_VSCODE:-n}" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$USE_VSCODE" = "y" ]; then \
		cp -r "$(PROJECT_ROOT)/.vscode.example" "$(PROJECT_ROOT)/.vscode"; \
		echo "  ✓ .vscode/ created from .vscode.example/"; \
	elif [ "$(IS_TEMPLATE_REPO)" != "1" ]; then \
		rm -rf "$(PROJECT_ROOT)/.vscode.example"; \
		echo "  ✓ .vscode.example/ removed."; \
	else \
		echo "  → Skipped (template repo — .vscode.example/ left in place)."; \
	fi
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 4 — config.mk
	@# ----------------------------------------------------------------
	@echo "Step 4/7  Makefile local config"
	@echo ""
	@echo "  config.mk lets you override GAME_NAME, PLATFORM, and BUILD_DIR"
	@echo "  for your local environment without committing those values."
	@echo ""
	@printf "  Create config.mk? [y/N]: "; \
	read USE_CONFIG_MK; \
	USE_CONFIG_MK=$$(echo "$${USE_CONFIG_MK:-n}" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$USE_CONFIG_MK" = "y" ]; then \
		cp "$(PROJECT_ROOT)/config.mk.example" "$(PROJECT_ROOT)/config.mk"; \
		echo "  ✓ config.mk created. Edit it to override build variables."; \
	elif [ "$(IS_TEMPLATE_REPO)" != "1" ]; then \
		rm -f "$(PROJECT_ROOT)/config.mk.example"; \
		echo "  ✓ config.mk.example removed."; \
	else \
		echo "  → Skipped (template repo — config.mk.example left in place)."; \
	fi
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 5 — OpenCode / AI development
	@# ----------------------------------------------------------------
	@echo "Step 5/7  OpenCode (AI development)"
	@echo ""
	@echo "  .opencode/ contains project-intelligence context files that"
	@echo "  teach an AI agent this project's architecture and conventions."
	@echo "  See docs/opencode.md for details."
	@echo ""
	@printf "  Keep OpenCode context? [Y/n]: "; \
	read USE_OPENCODE; \
	USE_OPENCODE=$$(echo "$${USE_OPENCODE:-y}" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$USE_OPENCODE" != "n" ]; then \
		echo "  ✓ .opencode/ kept."; \
	elif [ "$(IS_TEMPLATE_REPO)" != "1" ]; then \
		rm -rf "$(PROJECT_ROOT)/.opencode"; \
		rm -f "$(PROJECT_ROOT)/AGENTS.md"; \
		echo "  ✓ .opencode/ removed."; \
		echo "  ✓ AGENTS.md removed."; \
	else \
		echo "  → Skipped (template repo — .opencode/ cannot be removed here)."; \
	fi
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 6 — LuaRocks config
	@# ----------------------------------------------------------------
	@echo "Step 6/7  LuaRocks config"
	@echo ""
	@echo "  LuaRocks needs to know where your LuaJIT binary and headers"
	@echo "  are installed so it can build C extensions correctly."
	@echo ""
	@AUTO_LUA=$$(command -v luajit 2>/dev/null); \
	if [ -n "$$AUTO_LUA" ]; then \
		echo "  Detected luajit: $$AUTO_LUA"; \
	else \
		AUTO_LUA="/usr/bin/luajit"; \
		echo "  luajit not found on PATH — defaulting to $$AUTO_LUA"; \
	fi; \
	if [ "$(DETECTED_OS)" = "macos" ]; then \
		BREW_PREFIX=$$(brew --prefix luajit 2>/dev/null); \
		AUTO_INCDIR="$${BREW_PREFIX:-/usr/local}/include/luajit-2.1"; \
	else \
		AUTO_INCDIR="/usr/include/luajit-2.1"; \
	fi; \
	echo ""; \
	echo "  LUA       = $$AUTO_LUA"; \
	echo "  LUA_BINDIR = $$(dirname $$AUTO_LUA)"; \
	echo "  LUA_DIR   = $$(dirname $$(dirname $$AUTO_LUA))"; \
	echo "  LUA_INCDIR = $$AUTO_INCDIR"; \
	echo ""; \
	echo "  To find LUA_INCDIR on Linux:  find /usr -name 'luajit.h' 2>/dev/null"; \
	echo "  To find LUA_INCDIR on macOS:  brew --prefix luajit"; \
	echo ""; \
	printf "  Use these values? [Y/n]: "; \
	read CONFIRM_LUAROCKS; \
	CONFIRM_LUAROCKS=$$(echo "$${CONFIRM_LUAROCKS:-y}" | tr '[:upper:]' '[:lower:]'); \
	if [ "$$CONFIRM_LUAROCKS" != "n" ]; then \
		LUA_BIN="$$AUTO_LUA"; \
		LUA_INCDIR="$$AUTO_INCDIR"; \
	else \
		printf "  LUA (path to luajit binary) [$$AUTO_LUA]: "; \
		read INPUT_LUA; \
		LUA_BIN="$${INPUT_LUA:-$$AUTO_LUA}"; \
		printf "  LUA_INCDIR (path to luajit headers) [$$AUTO_INCDIR]: "; \
		read INPUT_INCDIR; \
		LUA_INCDIR="$${INPUT_INCDIR:-$$AUTO_INCDIR}"; \
	fi; \
	LUA_BINDIR=$$(dirname "$$LUA_BIN"); \
	LUA_DIR=$$(dirname "$$LUA_BINDIR"); \
	mkdir -p "$(PROJECT_ROOT)/.luarocks"; \
	printf 'lua_version = "5.1"\nvariables = {\n    LUA        = "%s",\n    LUA_BINDIR = "%s",\n    LUA_DIR    = "%s",\n    LUA_INCDIR = "%s"\n}\n' \
		"$$LUA_BIN" "$$LUA_BINDIR" "$$LUA_DIR" "$$LUA_INCDIR" \
		> "$(PROJECT_ROOT)/.luarocks/config-5.1.lua"; \
	echo "  ✓ .luarocks/config-5.1.lua written."
	@echo ""
	@# ----------------------------------------------------------------
	@# Step 7 — LUA_VERSION env
	@# ----------------------------------------------------------------
	@echo "Step 7/7  LUA_VERSION environment variable"
	@echo ""
	@echo "  LuaRocks and the game startup script require LUA_VERSION=5.1"
	@echo "  to be set in your shell environment."
	@echo ""
	@echo "  scripts/lua-env.sh will be written with this value. You can"
	@echo "  source it from your shell profile to set it globally, or add"
	@echo "  the export to ~/.bashrc / ~/.zshrc directly."
	@echo ""
	@printf "  LUA_VERSION [5.1]: "; \
	read INPUT_LUA_VERSION; \
	LUA_VERSION_VALUE="$${INPUT_LUA_VERSION:-5.1}"; \
	printf '# lua-env.sh — Source this file to set LUA_VERSION in your shell session.\n#\n# LUA_VERSION tells LuaRocks which Lua interpreter to target. This project\n# uses LuaJIT (Lua 5.1 compatible), so the value should always be 5.1 unless\n# you switch to a different Lua runtime.\n#\n# To set it permanently, add one of the following to your shell profile\n# (~/.bashrc, ~/.zshrc, ~/.profile, etc.):\n#\n#   source /path/to/your/project/scripts/lua-env.sh\n#\n# Or add the export line directly:\n#\n#   export LUA_VERSION=5.1\n#\nexport LUA_VERSION=%s\n' \
		"$$LUA_VERSION_VALUE" > "$(PROJECT_ROOT)/scripts/lua-env.sh"; \
	echo "  ✓ scripts/lua-env.sh written (LUA_VERSION=$$LUA_VERSION_VALUE)."; \
	echo ""; \
	echo "  To activate now:"; \
	echo "    source scripts/lua-env.sh"; \
	echo "  To activate permanently, add to your shell profile:"; \
	echo "    source $$(realpath $(PROJECT_ROOT)/scripts/lua-env.sh 2>/dev/null || echo scripts/lua-env.sh)"
	@echo ""
	@echo "============================================================"
	@echo "  Setup complete. Next: make run to run game"
	@echo "============================================================"
	@echo ""

# --- Dependency detection helpers --------------------------------------------

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
    DETECTED_OS := linux
else ifeq ($(UNAME_S),Darwin)
    DETECTED_OS := macos
else
    DETECTED_OS := windows
endif

HAS_YAY     := $(shell command -v yay 2>/dev/null)
HAS_PACMAN  := $(shell command -v pacman 2>/dev/null)
HAS_APT     := $(shell command -v apt-get 2>/dev/null)
HAS_BREW    := $(shell command -v brew 2>/dev/null)
HAS_LOVE    := $(shell command -v love 2>/dev/null)
HAS_LUAJIT  := $(shell command -v luajit 2>/dev/null)
HAS_LUAROCKS := $(shell command -v luarocks 2>/dev/null)

## deps: Check and install core dependencies (detects OS automatically)
deps:
	@if [ "$(LOVE_TEMPLATE_BOOTSTRAP)" != "true" ]; then \
		echo ""; \
		echo "  ⚠ Do not run make deps directly."; \
		echo "  → Run ./scripts/install-deps.sh instead."; \
		echo "  → This ensures make itself is installed and up to date first."; \
		echo ""; \
		exit 1; \
	fi
	@$(MAKE) -f $(THIS_MAKEFILE) deps-$(DETECTED_OS)

## deps-linux: Check and install dependencies for Linux (yay → pacman → apt)
deps-linux:
	@echo ""
	@echo "=== Dependencies (Linux) ==="
	@echo ""
	@echo "--- LÖVE ---"
	@if [ -n "$(HAS_LOVE)" ]; then \
		echo "  ✓ LÖVE $$(love --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LÖVE not found — installing..."; \
		if [ -n "$(HAS_YAY)" ]; then \
			echo "  → Installing via yay (AUR)..."; \
			yay -S --noconfirm love; \
		elif [ -n "$(HAS_PACMAN)" ]; then \
			echo "  → Installing via pacman..."; \
			sudo pacman -S --noconfirm love; \
		elif [ -n "$(HAS_APT)" ]; then \
			echo "  → Installing via PPA (Ubuntu/Debian)..."; \
			sudo add-apt-repository -y ppa:bartbes/love-stable; \
			sudo apt-get update -q; \
			sudo apt-get install -y love; \
		else \
			echo "  ⚠ No supported package manager found."; \
			echo "  → Install LÖVE manually from https://love2d.org"; \
		fi \
	fi
	@echo ""
	@echo "--- LuaJIT ---"
	@if [ -n "$(HAS_LUAJIT)" ]; then \
		echo "  ✓ LuaJIT $$(luajit -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LuaJIT not found — installing..."; \
		if [ -n "$(HAS_YAY)" ]; then \
			echo "  → Installing via yay (AUR)..."; \
			yay -S --noconfirm luajit; \
		elif [ -n "$(HAS_PACMAN)" ]; then \
			echo "  → Installing via pacman..."; \
			sudo pacman -S --noconfirm luajit; \
		elif [ -n "$(HAS_APT)" ]; then \
			echo "  → Installing via apt..."; \
			sudo apt-get install -y luajit; \
		else \
			echo "  ⚠ No supported package manager found."; \
			echo "  → Install LuaJIT manually from https://luajit.org/download.html"; \
		fi \
	fi
	@echo ""
	@echo "--- LuaRocks ---"
	@if [ -n "$(HAS_LUAROCKS)" ]; then \
		echo "  ✓ LuaRocks $$(luarocks --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LuaRocks not found — installing..."; \
		if [ -n "$(HAS_YAY)" ]; then \
			echo "  → Installing via yay (AUR)..."; \
			yay -S --noconfirm luarocks; \
		elif [ -n "$(HAS_PACMAN)" ]; then \
			echo "  → Installing via pacman..."; \
			sudo pacman -S --noconfirm luarocks; \
		elif [ -n "$(HAS_APT)" ]; then \
			echo "  → Installing via apt..."; \
			sudo apt-get install -y luarocks; \
		else \
			echo "  ⚠ No supported package manager found."; \
			echo "  → Install LuaRocks manually from https://luarocks.org"; \
		fi \
	fi
	@echo ""
	@echo "Done. Run 'make configure' to run configuration wizard OR 'make run' to start the game."
	@echo ""

## deps-macos: Check and install dependencies for macOS (Homebrew)
deps-macos:
	@echo ""
	@echo "=== Dependencies (macOS) ==="
	@echo ""
	@if [ -z "$(HAS_BREW)" ]; then \
		echo "  ⚠ Homebrew not found. Install it first: https://brew.sh"; \
		echo "  → Then re-run: make deps"; \
		exit 1; \
	fi
	@echo "--- LÖVE ---"
	@if [ -n "$(HAS_LOVE)" ]; then \
		echo "  ✓ LÖVE $$(love --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LÖVE not found — installing via Homebrew..."; \
		brew install love; \
	fi
	@echo ""
	@echo "--- LuaJIT ---"
	@if [ -n "$(HAS_LUAJIT)" ]; then \
		echo "  ✓ LuaJIT $$(luajit -v 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LuaJIT not found — installing via Homebrew..."; \
		brew install luajit; \
	fi
	@echo ""
	@echo "--- LuaRocks ---"
	@if [ -n "$(HAS_LUAROCKS)" ]; then \
		echo "  ✓ LuaRocks $$(luarocks --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"; \
	else \
		echo "  ⚠ LuaRocks not found — installing via Homebrew..."; \
		brew install luarocks; \
	fi
	@echo ""
	@echo "Done. Run 'make configure' to run configuration wizard OR 'make run' to start the game."
	@echo ""

## deps-windows: Print manual install instructions for Windows
deps-windows:
	@echo ""
	@echo "=== Dependencies (Windows) ==="
	@echo ""
	@echo "Automatic installation is not supported on Windows."
	@echo "Install the following dependencies manually:"
	@echo ""
	@echo "  LÖVE"
	@echo "    https://love2d.org"
	@echo ""
	@echo "  LuaJIT"
	@echo "    https://luajit.org/download.html"
	@echo ""
	@echo "  LuaRocks"
	@echo "    https://luarocks.github.io/luarocks/releases"
	@echo ""
	@echo "Tip: WSL (Windows Subsystem for Linux) is recommended for a smoother experience."
	@echo "     Inside WSL, run: ./setup.sh"
	@echo ""

## run: Run the game with LÖVE from source
run:
	love .

## build: Package the game into a .love archive
## Runs clean then installs runtime-only deps to ensure the zip contains no dev/test artifacts.
build:
	@$(MAKE) -f $(THIS_MAKEFILE) clean
	@luarocks install --only-deps $(wildcard *.rockspec) --tree lua_modules
	@mkdir -p $(BUILD_DIR)
ifeq ($(PLATFORM),none)
	@echo "Building $(LOVE_FILE) (pure Lua)..."
	@if find lua_modules/lib -name "*.so" -o -name "*.dll" 2>/dev/null | grep -q .; then \
		echo "WARNING: C extensions found in lua_modules/lib. Use PLATFORM=linux|macos|windows|all to include them."; \
	fi
else
	@echo "Building $(LOVE_FILE) (platform: $(PLATFORM))..."
endif
	@cd $(PROJECT_ROOT) && zip -9 -r $(PROJECT_ROOT)/$(LOVE_FILE) . $(LOVE_EXCLUDE)
	@echo "Done: $(LOVE_FILE)"

## install: Install all Lua dependencies via LuaRocks (runtime + dev/test, for local development and CI)
install:
	luarocks install --only-deps $(wildcard *.rockspec) --tree lua_modules
	luarocks test --prepare $(wildcard *.rockspec) --tree lua_modules

## clean: Remove build artifacts and installed Lua dependencies
clean:
	rm -rf $(BUILD_DIR)
	rm -rf lua_modules/bin lua_modules/lib/lua lua_modules/lib/luarocks lua_modules/share
	@echo "Cleaned."

# ==============================================================================
# Test targets
#
# MAINTENANCE: When the project structure changes (files added/removed,
# invariants change), update scripts/tests/assert-structure.sh to match.
# The file has a labeled section for each category of assertion — find the
# right section and add or remove the corresponding assert_file / assert_dir /
# assert_contains call. test-scripts runs that file; the other targets below
# are independent.
# ==============================================================================

## test: Run all checks — lint, unit tests, structure assertions, dry-run
test: test-lint test-lua test-scripts test-dry-run
	@echo ""
	@echo "All checks passed."
	@echo ""

## test-lua: Run busted unit tests in tests/
test-lua:
	@echo ""
	@echo "=== Lua unit tests (busted) ==="
	@echo ""
	lua_modules/bin/busted tests/
	@echo ""

## test-lint: Run luacheck on src/ and tests/
test-lint:
	@echo ""
	@echo "=== Lint (luacheck) ==="
	@echo ""
	lua_modules/bin/luacheck src/ tests/ --config $(PROJECT_ROOT)/.luacheckrc
	@echo ""

## test-scripts: Run structural assertions
test-scripts:
	@echo ""
	@echo "=== Structural assertions ==="
	@echo ""
	bash $(dir $(THIS_MAKEFILE))tests/assert-structure.sh
	@echo ""

## test-dry-run: Verify Makefile targets parse correctly without executing
test-dry-run:
	@echo ""
	@echo "=== Makefile dry-run ==="
	@echo ""
	$(MAKE) -f $(THIS_MAKEFILE) -n run   > /dev/null && echo "  ✓ run"
	$(MAKE) -f $(THIS_MAKEFILE) -n build > /dev/null && echo "  ✓ build"
	$(MAKE) -f $(THIS_MAKEFILE) -n install > /dev/null && echo "  ✓ install"
	$(MAKE) -f $(THIS_MAKEFILE) -n clean > /dev/null && echo "  ✓ clean"
	@echo ""
