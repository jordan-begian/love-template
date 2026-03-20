package = "love-template"
version = "dev-1"
rockspec_format = "3.0"
source = {
	url = "git+ssh://git@github.com/jordan-begian/love-template.git",
}
description = {
	summary = "A LÖVE2D game template",
	detailed = [[
      Template for creating LÖVE2D games with organized project structure
      and LuaRocks dependency management.
   ]],
	homepage = "https://github.com/jordan-begian/love-template?tab=readme-ov-file#love-template-sparkling_heart",
	license = "MIT",
}
dependencies = {
	"lua >= 5.1, < 5.2",
}
test_dependencies = {
	"luacheck",
	"busted",
}
build = {
	type = "builtin",
	modules = {},
}
test = {
	type = "busted",
}
