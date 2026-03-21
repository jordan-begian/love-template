#!/usr/bin/env bash
#
# assert-structure.sh — Structural assertions for the love-template project.
#
# Checks that required files exist, versions are consistent, and key invariants
# hold. Intended to run in CI on every PR via `make test-scripts`.
#
# MAINTENANCE: Keep this file in sync with the project structure.
# When you add or remove a required file, directory, or invariant, update the
# relevant section below. Sections are clearly labeled — find the right one and
# add or remove the corresponding assert_file / assert_dir / assert_contains call.
#
#   Required files          → "Required files" section (also add to KNOWN_ROOT_FILES
#                             or KNOWN_ROOT_DIRS if it lives at the project root)
#   Required directories    → "Required directories" section (also add to
#                             KNOWN_ROOT_DIRS if it lives at the project root,
#                             or KNOWN_SRC_DIRS if it lives under src/)
#   New version variable    → "versions.env" section
#   New consistency check   → "Version consistency" section
#   Rockspec invariant      → "Rockspec" section
#   Scaffolded empty dirs   → "gitkeep placeholders" section (also update the
#                             for-loop list and the Scaffolded But Empty section
#                             in .opencode/context/project-intelligence/navigation.md)
#
# Failure messages indicate one of two actions:
#   "missing"       → file/dir was expected but not found; add it or remove the assertion
#   "unexpected"    → file/dir was found but is not known; add it to the known list
#                     (required or optional) or remove it from the project
#
# Exit codes: 0 = all assertions passed, 1 = one or more failures.
#
# Usage: bash scripts/tests/assert-structure.sh

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)

PASS=0
FAIL=0

# --- Version constants ---------------------------------------------------------
#
# All version values used in assertions are defined here — no hardcoded strings
# elsewhere in this file. Package versions are sourced from versions.env (the
# single source of truth). LUA_API_VERSION is the Lua language compatibility
# level required by this project; update it here if the project ever targets
# a different Lua runtime.

# shellcheck source=../versions.env
. "$PROJECT_ROOT/scripts/versions.env"
# LOVE_VERSION, LUAJIT_VERSION, LUAROCKS_VERSION now available from versions.env

LUA_API_VERSION="5.1"

# --- Helpers ------------------------------------------------------------------

pass() {
    echo "  ✓ $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "  ✗ $1"
    FAIL=$((FAIL + 1))
}

assert_file() {
    if [ -f "$PROJECT_ROOT/$1" ]; then
        pass "$1 exists"
    else
        fail "$1 missing — add the file or remove this assertion if it is no longer required"
    fi
}

assert_dir() {
    if [ -d "$PROJECT_ROOT/$1" ]; then
        pass "$1/ exists"
    else
        fail "$1/ missing — create the directory or remove this assertion if it is no longer required"
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local label="${3:-$file contains '$pattern'}"
    if grep -q "$pattern" "$PROJECT_ROOT/$file" 2>/dev/null; then
        pass "$label"
    else
        fail "$label"
    fi
}

# --- Known root entries -------------------------------------------------------
#
# Files and directories that are expected at the project root.
# Anything found at the root that is not in one of these lists will be flagged
# as unexpected. Add new root-level entries here when they are introduced.
#
# KNOWN_ROOT_FILES  — individual files at the project root
# KNOWN_ROOT_DIRS   — directories at the project root
# KNOWN_ROOT_HIDDEN — dot-files and dot-dirs at the project root (gitignored
#                     or tool-generated entries belong here)

KNOWN_ROOT_FILES=(
    Makefile
    setup.sh
    main.lua
    conf.lua
    config.mk.example
    README.md
    LICENSE
    love-template-dev-1.rockspec
    .luacheckrc
    .gitignore
    AGENTS.md
    lua
    luarocks
)

KNOWN_ROOT_DIRS=(
    src
    tests
    assets
    docs
    scripts
    lua_modules
    build
)

KNOWN_ROOT_HIDDEN=(
    .git
    .githooks
    .opencode
    .luarocks
    .luarocks.example
    .vscode
    .vscode.example
    .github
    config.mk
    .tmp
)

# --- Optional ignore list (env/file) -----------------------------------------
#
# You can optionally provide additional root-level entries that should be
# ignored by the unexpected-entry check. This is useful for CI-only generated
# directories (e.g., .lua created by a GitHub Action) without changing the
# default strict behavior for local developers.
#
# Sources (applied in order):
#  1) .assert-structure-ignore at the project root (one entry per line)
#  2) ASSERT_IGNORE env var (comma or space separated list)
#
KNOWN_ROOT_IGNORED=()

# (1) file-based ignores (one per line, trimmed)
if [ -f "$PROJECT_ROOT/.assert-structure-ignore" ]; then
    while IFS= read -r line; do
        # Trim whitespace
        entry="$(echo "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        [ -n "$entry" ] && KNOWN_ROOT_IGNORED+=("$entry")
    done < "$PROJECT_ROOT/.assert-structure-ignore"
fi

# (2) ASSERT_IGNORE env var (comma or space separated)
if [ -n "${ASSERT_IGNORE:-}" ]; then
    # Normalize commas to spaces, then iterate
    for entry in $(echo "$ASSERT_IGNORE" | tr ',' ' '); do
        entry="$(echo "$entry" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
        [ -n "$entry" ] && KNOWN_ROOT_IGNORED+=("$entry")
    done
fi

# Merge ignored entries into the hidden-known list so they are accepted as known.
for ignored in "${KNOWN_ROOT_IGNORED[@]}"; do
    KNOWN_ROOT_HIDDEN+=( "$ignored" )
done

# --- Known src/ subdirectories ------------------------------------------------
#
# Immediate subdirectories expected under src/. Anything else found there is
# flagged as unexpected.

KNOWN_SRC_DIRS=(
    states
    systems
    types
    utils
)

# --- Required files -----------------------------------------------------------

echo ""
echo "=== Required files ==="
echo ""

assert_file "Makefile"
assert_file "setup.sh"
assert_file "main.lua"
assert_file "conf.lua"
assert_file "love-template-dev-1.rockspec"
assert_file "src/main.lua"
assert_file "src/states/game.lua"
assert_file "src/utils/luarocks_config.lua"
assert_file "scripts/Makefile"
assert_file "scripts/install-deps.sh"
assert_file "scripts/versions.env"
assert_file "scripts/lua-env.sh"
assert_file "config.mk.example"
assert_file ".luarocks.example/config-5.1.lua"
assert_file ".githooks/pre-commit"
assert_file ".githooks/commit-msg"
assert_file ".luacheckrc"
assert_file "docs/reference/conventions.md"
assert_file "docs/reference/testing.md"
assert_file "docs/opencode.md"
assert_file ".opencode/context/project-intelligence/technical-domain.md"
assert_file ".opencode/context/project-intelligence/navigation.md"
assert_file ".github/workflows/pull_request.yml"
assert_file ".github/dependabot.yml"
assert_file ".github/.luarocks/config-5.1.lua"

# --- Required directories -----------------------------------------------------

echo ""
echo "=== Required directories ==="
echo ""

assert_dir "src/states"
assert_dir "src/systems"
assert_dir "src/types"
assert_dir "src/utils"
assert_dir "assets/images"
assert_dir "assets/sounds"
assert_dir "assets/fonts"
assert_dir "tests/states"
assert_dir "tests/systems"
assert_dir "tests/types"
assert_dir ".githooks"

# --- Unexpected root entries --------------------------------------------------
#
# Flag anything at the project root that is not in the known lists above.
# This catches new files that were added without updating this script.

echo ""
echo "=== Unexpected root entries ==="
echo ""

_root_unexpected=0

for entry in "$PROJECT_ROOT"/* "$PROJECT_ROOT"/.[!.]*; do
    [ -e "$entry" ] || continue
    name=$(basename "$entry")

    # Build a combined known list for lookup
    known=0
    for f in "${KNOWN_ROOT_FILES[@]}"; do [ "$name" = "$f" ] && known=1 && break; done
    if [ "$known" -eq 0 ]; then
        for d in "${KNOWN_ROOT_DIRS[@]}"; do [ "$name" = "$d" ] && known=1 && break; done
    fi
    if [ "$known" -eq 0 ]; then
        for h in "${KNOWN_ROOT_HIDDEN[@]}"; do [ "$name" = "$h" ] && known=1 && break; done
    fi

    if [ "$known" -eq 0 ]; then
        fail "$name — unexpected entry at project root; add it to KNOWN_ROOT_FILES, KNOWN_ROOT_DIRS, or KNOWN_ROOT_HIDDEN in assert-structure.sh (mark as required or optional), or remove it from the project"
        _root_unexpected=$((_root_unexpected + 1))
    fi
done

if [ "$_root_unexpected" -eq 0 ]; then
    pass "no unexpected entries at project root"
fi

# --- Unexpected src/ subdirectories -------------------------------------------
#
# Flag any immediate subdirectory of src/ that is not in KNOWN_SRC_DIRS.

echo ""
echo "=== Unexpected src/ subdirectories ==="
echo ""

_src_unexpected=0

for entry in "$PROJECT_ROOT/src"/*/; do
    [ -d "$entry" ] || continue
    name=$(basename "$entry")

    known=0
    for d in "${KNOWN_SRC_DIRS[@]}"; do [ "$name" = "$d" ] && known=1 && break; done

    if [ "$known" -eq 0 ]; then
        fail "src/$name/ — unexpected subdirectory under src/; add it to KNOWN_SRC_DIRS in assert-structure.sh (mark as required or optional), or remove it from the project"
        _src_unexpected=$((_src_unexpected + 1))
    fi
done

if [ "$_src_unexpected" -eq 0 ]; then
    pass "no unexpected subdirectories under src/"
fi

# --- versions.env format and completeness -------------------------------------

echo ""
echo "=== versions.env ==="
echo ""

VERSIONS_FILE="$PROJECT_ROOT/scripts/versions.env"

assert_contains "scripts/versions.env" "^LOVE_VERSION=[0-9]" "LOVE_VERSION is set"
assert_contains "scripts/versions.env" "^LUAJIT_VERSION=[0-9]" "LUAJIT_VERSION is set"
assert_contains "scripts/versions.env" "^LUAROCKS_VERSION=[0-9]" "LUAROCKS_VERSION is set"

# No spaces around = (shell-sourceable format)
if grep -qE "^[A-Z_]+ = " "$VERSIONS_FILE" 2>/dev/null; then
    fail "versions.env has spaces around = (must be KEY=value, no spaces)"
else
    pass "versions.env uses KEY=value format (no spaces around =)"
fi

# --- conf.lua version matches versions.env LOVE_VERSION ----------------------

echo ""
echo "=== Version consistency ==="
echo ""

. "$PROJECT_ROOT/scripts/versions.env"

CONF_VERSION=$(grep 't\.version' "$PROJECT_ROOT/conf.lua" | grep -o '"[^"]*"' | tr -d '"')
if [ "$CONF_VERSION" = "$LOVE_VERSION" ]; then
    pass "conf.lua t.version ($CONF_VERSION) matches LOVE_VERSION in versions.env"
else
    fail "conf.lua t.version ($CONF_VERSION) does not match LOVE_VERSION ($LOVE_VERSION) in versions.env"
fi

# --- rockspec invariants ------------------------------------------------------

echo ""
echo "=== Rockspec ==="
echo ""

assert_contains "love-template-dev-1.rockspec" "dependencies" "rockspec has dependencies block"
assert_contains "love-template-dev-1.rockspec" "luacheck" "rockspec has luacheck dev dependency"
assert_contains "love-template-dev-1.rockspec" "busted" "rockspec has busted dev dependency"

# --- lua-env.sh exports LUA_VERSION -------------------------------------------

echo ""
echo "=== lua-env.sh ==="
echo ""

assert_contains "scripts/lua-env.sh" "export LUA_VERSION=" "lua-env.sh exports LUA_VERSION"

LUA_ENV_VERSION=$(grep "^export LUA_VERSION=" "$PROJECT_ROOT/scripts/lua-env.sh" | cut -d= -f2)
if [ "$LUA_ENV_VERSION" = "$LUA_API_VERSION" ]; then
    pass "lua-env.sh LUA_VERSION is $LUA_API_VERSION"
else
    fail "lua-env.sh LUA_VERSION is '$LUA_ENV_VERSION' (expected $LUA_API_VERSION)"
fi

# --- Scaffolded empty dirs have .gitkeep -------------------------------------

echo ""
echo "=== .gitkeep placeholders ==="
echo ""

for dir in src/systems src/types assets/images assets/sounds assets/fonts tests/systems tests/types; do
    full="$PROJECT_ROOT/$dir"
    # A .gitkeep is only required if the directory has no other files
    non_gitkeep_count=$(find "$full" -maxdepth 1 -type f ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')
    gitkeep_exists=$([ -f "$full/.gitkeep" ] && echo "yes" || echo "no")

    if [ "$non_gitkeep_count" -gt 0 ]; then
        pass "$dir/ has real files (no .gitkeep required)"
    elif [ "$gitkeep_exists" = "yes" ]; then
        pass "$dir/ is empty — .gitkeep present"
    else
        fail "$dir/ is empty but missing .gitkeep — add a .gitkeep file to preserve the directory in git"
    fi
done

# --- Summary ------------------------------------------------------------------

echo ""
echo "============================================================"
echo "  Passed: $PASS   Failed: $FAIL"
echo "============================================================"
echo ""

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
