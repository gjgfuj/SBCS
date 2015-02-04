local filesystem = require("filesystem")
local api = require("sbcsapi")

local gpu = api.getComponent("gpu")

api.clear()
api.print("Loading Sandra's Base Control System (SBCS) V0.2.0")
api.print("Searching for modules.")
local modules = {}
api.modules = modules
for file in filesystem.list("/usr/lib/sbcs/") do
  api.print("Loaded module. "..file)
  local module = dofile("/usr/lib/sbcs/"..file)
  module.api = api
  modules[module.name] = module
  module.modules = modules
  if module.setup ~= nil then module.setup() end
end
local stillrunning = true
function list()
  if not stillrunning then return false end
  local t = {}
  for n, module in pairs(modules) do
    table.insert(t, module.dispname..":    "..module.message())
  end
  table.insert(t, "Touch here to quit.")
  return t
end
function quit()
  stillrunning = false
end
function buttons()
  local t = {}
  for n, module in pairs(modules) do
    table.insert(t, module.activate)
  end
  table.insert(t, quit)
  return t
end
api.displayList(list, buttons)
