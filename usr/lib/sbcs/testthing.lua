local term = require("term")
local module = {}
local times = 0
module.name = "testthing"
module.dispname = "Seconds since started"
function module.message() times = times + 1 return tostring(times) end
function module.activate() term.write(times.." updates since app begun.") os.sleep(1) end
return module
