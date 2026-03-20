local LUA_VERSION = os.getenv("LUA_VERSION") or "5.1"

local function setup_luarocks()
    if not os.getenv("LUA_VERSION") then
        print("Warning: LUA_VERSION environment variable is not set — defaulting to 5.1.")
        print("  To silence this: source scripts/lua-env.sh or add 'export LUA_VERSION=5.1' to your shell profile.")
    end

    love.filesystem.setRequirePath(
        love.filesystem.getRequirePath() ..
        ";lua_modules/share/lua/" .. LUA_VERSION .. "/?.lua" ..
        ";lua_modules/share/lua/" .. LUA_VERSION .. "/?/init.lua"
    )

    -- love.filesystem.setCRequirePath cannot load C extensions — LÖVE's VFS
    -- cannot dlopen() from a zip. Use package.cpath with a real OS path instead.
    local source_path = love.filesystem.getSource()
    package.cpath = package.cpath ..
        ";" .. source_path .. "/lua_modules/lib/lua/" .. LUA_VERSION .. "/?.so" ..
        ";" .. source_path .. "/lua_modules/lib/lua/" .. LUA_VERSION .. "/?.dll"
end

return {
    setup = setup_luarocks
}
