local term = require("term")
local event = require("event")
local component = require("component")

local gpu = component.gpu

local module = {}
module.name = "settings"
module.dispname = "Settings"
function module.message() return "Touch to open settings." end
local running = true
local buttons = {}
local thingToExecute = nil
local manualResolution = false

function module.resolution()
  manualResolution = true
  term.write("Please enter the width of the screen: ")
  local width = tonumber(term.read())
  if not width then
    width,_ = gpu.getResolution()
  end
  term.write("Please enter the height of the screen: ")
  local height = tonumber(term.read())
  if not height then
    _,height = gpu.getResolution()
  end
  gpu.setResolution(width, height)
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function module.callback()
  if not manualResolution then
    module.autoResolution()
  end
end
function module.autoResolution()
  local x = 10
  local y = tablelength(module.modules)+5
  for n,othermodule in pairs(module.modules) do
    local len = othermodule.dispname..":    "..othermodule.message()
    if #len+1 > x then x = #len+1 end
  end
  gpu.setResolution(x,y)
end
function module.goBack()
  running = false
end
function module.handleTouch(_, address, x, y, _, player)
  if buttons[y] then
    term.clear()
    term.setCursor(1,1)
    event.ignore("touch", module.handleTouch)
    thingToExecute = buttons[y]
  end
end
function module.activate()
  running = true
  while running do
    event.listen("touch", module.handleTouch)
    if thingToExecute then
      thingToExecute()
      thingToExecute = nil
      event.listen("touch", module.handleTouch)
    else
      local resX, resY = gpu.getResolution()
      term.clear()
      print("Settings")
      print("Set screen resolution, currently at "..resX..","..resY)
      buttons[2] = module.resolution
      print("Automatically adjust resolution.")
      buttons[3] = module.autoResolution
      print("Back")
      buttons[4] = module.goBack
      os.sleep(1)
    end
  end
  event.ignore("touch", module.handleTouch)
end

return module
