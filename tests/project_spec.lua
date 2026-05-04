local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local neq = MiniTest.expect.no_equality

local project = require("grepscope.project")

local T = new_set()

T["key()"] = new_set()

T["key()"]["converts slashes to percent"] = function()
  eq("home%user%project", project.key("/home/user/project"))
end

T["key()"]["handles Windows-style backslashes"] = function()
  eq("C%Users%project", project.key("C:\\Users\\project"))
end

T["key()"]["strips leading and trailing separators"] = function()
  eq("home%user", project.key("/home/user/"))
end

T["key()"]["escapes existing percent characters"] = function()
  neq(project.key("/home/user"), project.key("/home%user"))
end

T["key()"]["handles consecutive slashes"] = function()
  eq("home%user", project.key("//home//user"))
end

T["key()"]["returns fallback for root path"] = function()
  eq("root", project.key("/"))
end

T["key()"]["returns fallback for empty string"] = function()
  eq("root", project.key(""))
end

return T
