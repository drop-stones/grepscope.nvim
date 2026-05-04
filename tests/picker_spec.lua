local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local picker = require("grepscope.picker")

local T = new_set()

T["title()"] = new_set()

T["title()"]["returns base when globs are empty"] = function()
  eq("Grep", picker.title("Grep", {}))
end

T["title()"]["appends globs in brackets"] = function()
  eq("Grep [*.ts]", picker.title("Grep", { "*.ts" }))
end

T["title()"]["joins multiple globs with space"] = function()
  eq("Grep [*.ts !*.test.ts]", picker.title("Grep", { "*.ts", "!*.test.ts" }))
end

T["parse_globs()"] = new_set()

T["parse_globs()"]["parses space-separated patterns"] = function()
  eq({ "*.ts", "!*.test.ts" }, picker.parse_globs("*.ts !*.test.ts"))
end

T["parse_globs()"]["returns empty table for empty string"] = function()
  eq({}, picker.parse_globs(""))
end

T["parse_globs()"]["handles extra whitespace"] = function()
  eq({ "*.lua", "*.vim" }, picker.parse_globs("  *.lua   *.vim  "))
end

T["parse_globs()"]["handles single pattern"] = function()
  eq({ "*.rs" }, picker.parse_globs("*.rs"))
end

return T
