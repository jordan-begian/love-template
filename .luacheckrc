std = "lua51"

globals = {
    "love",
    "jit",
    "arg",
}

ignore = {
    -- State interface functions (onEnter, onExit) must accept specific arguments
    -- to satisfy the interface contract even when a particular state doesn't use them.
    -- Luacheck 212 would flag those arguments as unused, which would be a false positive.
    "212",
}

exclude_files = {
    ".github/.luarocks/",
}
