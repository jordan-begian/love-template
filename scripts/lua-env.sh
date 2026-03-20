# lua-env.sh — Source this file to set LUA_VERSION in your shell session.
#
# LUA_VERSION tells LuaRocks which Lua interpreter to target. This project
# uses LuaJIT (Lua 5.1 compatible), so the value should always be 5.1 unless
# you switch to a different Lua runtime.
#
# To set it permanently, add one of the following to your shell profile
# (~/.bashrc, ~/.zshrc, ~/.profile, etc.):
#
#   source /path/to/your/project/scripts/lua-env.sh
#
# Or add the export line directly:
#
#   export LUA_VERSION=5.1
#
export LUA_VERSION=5.1
