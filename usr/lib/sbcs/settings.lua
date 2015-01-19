local term = require("term")
local component = require("component")

local module = {}
module.name = "settings"
module.dispname = "Settings"
function module:message() return "Touch to open settings." end

function resolution()
  term.write("Please enter the width of the screen: ")
  local width = tonumber(term.read())
  term.write("Please enter the height of the screen: ")
  local height = tonumber(term.read())
  gpu.setResolution(width, height)
end
function goBack()
  running = false
end
local buttons = {}
function handleTouch(_, address, x, y, _, player)
  term.clear()
  term.setCursor(1,1)
  event.ignore("touch", handleTouch)
  buttons[y]()
  event.listen("touch", handleTouch)
end
local running = true
function module:activate()
  event.listen("touch", handleTouch)
  running = true
  local resX, resY = gpu.getResolution()
  while running do
    term.write("Set screen resolution, currently at "..resX..","..resY.."\n")
    buttons[1] = resolution
    print("Back\n")
    buttons[2] = goBack
    os.sleep(1)
  end
  event.ignore("touch", handleTouch)
end

return module
