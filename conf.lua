function love.conf(t)
    t.identity = "mygame"
    t.version  = "11.5"  -- keep in sync with LOVE_VERSION in scripts/versions.env

    t.window.title  = "My Game"
    t.window.width  = 1280
    t.window.height = 720
    t.window.vsync  = 1

    -- Disable unused modules to improve startup time
    t.modules.joystick = false
    t.modules.physics  = false
    t.modules.video    = false
    t.modules.touch    = false
end
