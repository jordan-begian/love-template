#!/usr/bin/env bash
#
# Entry point for first-time project setup.
# Delegates to scripts/install-deps.sh, which bootstraps make and installs
# all required dependencies (LÖVE, LuaJIT, LuaRocks).
#
# Usage: ./setup.sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

exec "$SCRIPT_DIR/scripts/install-deps.sh"
