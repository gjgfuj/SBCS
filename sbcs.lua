local component = require("component")
local filesystem = require("filesystem")
local term = require("term")
local event = require("event")
local computer = require("computer")

local gpu = component.gpu

term.clear()
print("Loading Sandra's Base Control System (SBCS) V0.1.0")
print("Searching for modules.")
local modules = {}
for file in filesystem.list("/usr/lib/sbcs/") do
  print("Loaded module: "..file)
  local module = dofile("/usr/lib/sbcs/"..file)
  modules[module.name] = module
end
os.sleep(1)
local buttons = {}
function handleTouch(_, address, x, y, _, player)
  term.clear()
  term.setCursor(1,1)
  event.ignore("touch", handleTouch)
  buttons[y]()
  event.listen("touch", handleTouch)
end
function drawGUI()
  term.clear()
  for n,module in pairs(modules) do
    local x,y = term.getCursor()
    print(module.dispname..":    "..module:message())
    buttons[y] = module.activate
  end
  local resX, resY = gpu.getResolution()
  term.setCursor(1, resY)
  term.write("Touch here to quit.")
  buttons[resY] = quit
end
function mainGUI()
  event.listen("touch", handleTouch)
  drawGUI()
end
local stillrunning = true
function quit()
  event.ignore("touch", handleTouch)
  stillrunning = false
end
mainGUI()
while stillrunning do
  os.sleep(1)
  drawGUI()
end
