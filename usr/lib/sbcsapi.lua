local term = require("term")
local component = require("component")
local event = require("event")
api = {}
function api.print(...)
  print(...)
end
function api.getComponent(componenttype, address)
  if address == nil then
    return component.proxy(component.list(componenttype)())
  else
    return component.proxy(component.get(address))
  end
end
function api.listComponent(componentype)
  local t = {}
  for address in component.list(componentype)
    table.insert(t, address)
  end
  return t
end
function api.setResolution(x,y)
  component.gpu.setResolution(x,y)
end
function api.autoResolution(list)
  local x = 10
  local y = #list+1
  for _,len in ipairs(list) do
    if #len+1 > x then x = #len+1 end
  end
  api.setResolution(x,y)
end
function api.displayList(listFunction, buttonsFunction)
  local list = listFunction()
  local buttons = buttonsFunction()
  local thingToExecute = nil
  function handleTouch(_, address, x, y, _, player)
    if buttons[y] then
      term.clear()
      term.setCursor(1,1)
      event.ignore("touch", handleTouch)
      thingToExecute = buttons[y]
    end
  end
  while type(list) == "table" do
    event.listen("touch", handleTouch)
    if thingToExecute then
      thingToExecute()
      thingToExecute = nil
      event.listen("touch", handleTouch)
    else
      for n, module in pairs(api.modules) do
        module.callback()
      end
      api.autoResolution(list)
      term.clear()
      for _, text in ipairs(list) do
        api.print(text)
      end
      os.sleep(1)
    end
    list = listFunction()
    buttons = buttonsFunction()
  end
  event.ignore("touch", handleTouch)
end
function api.formatNum(num)
  num = num * 100
  num = math.floor(num)
  num = num / 100
  local formatted = num
  if num > 1000*1000*100 then
    formatted = tostring(math.floor((num/1000/1000)*100)/100).."M"
  elseif num > 1000*100 then
    formatted = tostring(math.floor((num/1000)*100)/100).."k"
  end
  return formatted
end

return api
