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
  print("Loaded module. "..file)
  local module = dofile("/usr/lib/sbcs/"..file)
  modules[module.name] = module
  module.modules = modules
end
os.sleep(1)
if modules["settings"] then
  modules["settings"].autoResolution()
end
local buttons = {}
local handlingTouch = false
function handleTouch(_, address, x, y, _, player)
  if buttons[y] then
    term.setCursor(1,1)
    term.clear()
    event.ignore("touch", handleTouch)
    handlingTouch = buttons[y]
  end
end
function drawGUI()
  if not handlingTouch then
    term.clear()
    for n,module in pairs(modules) do
      local x,y = term.getCursor()
      print(module.dispname..":    "..module.message())
      buttons[y] = module.activate
    end
    local resX, resY = gpu.getResolution()
    term.setCursor(1, resY)
    term.write("Touch here to quit.")
    buttons[resY] = quit
  else
    handlingTouch()
    event.listen("touch", handleTouch)
    handlingTouch = false
  end
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
