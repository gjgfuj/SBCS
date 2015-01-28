local component = require("component")
local filesystem = require("filesystem")
local term = require("term")
local event = require("event")
local computer = require("computer")
local api = require("sbcsapi")

local gpu = component.gpu

term.clear()
print("Loading Sandra's Base Control System (SBCS) V0.1.0")
print("Searching for modules.")
local modules = {}
api.modules = modules
for file in filesystem.list("/usr/lib/sbcs/") do
  print("Loaded module. "..file)
  local module = dofile("/usr/lib/sbcs/"..file)
  module.api = api
  modules[module.name] = module
  module.modules = modules
end
os.sleep(1)
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
