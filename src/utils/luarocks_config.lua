LUA_VERSION = os.getenv("LUA_VERSION")

local function setup_luarocks()
    assert(LUA_VERSION, "LUA_VERSION environment variable is not set")

    love.filesystem.setRequirePath(
        love.filesystem.getRequirePath() ..
        ";lua_modules/share/lua/" .. LUA_VERSION .. "/?.lua" ..
        ";lua_modules/share/lua/" .. LUA_VERSION .. "/?/init.lua"
    )

    love.filesystem.setCRequirePath(
        love.filesystem.getCRequirePath() ..
        ";lua_modules/lib/lua/" .. LUA_VERSION .. "/?.so" ..
        ";lua_modules/lib/lua/" .. LUA_VERSION .. "/?.dll"
    )
end

return {
    setup = setup_luarocks
}
