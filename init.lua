local gpu
local filesystem 
local api = {}
--BEGIN API
local sx = 0
local sy = 0
local listeners = {}
function api.listen(event, listener) listeners[listener] = event end
function api.ignore(listener) for k,v in pairs(listeners) do if k == listener then listeners[k] = nil end end end
function api.pullEvent(event) 
  local signal
  repeat 
    local function anon(signal, ...) 
      for k,v in pairs(listeners) do
        if v == signal then
          k(...)
        end
      end
    end
    anon(computer.pullSignal())
  until event == nil or signal == event end
  return signal
end
function api.write(...)
  gpu.set(sx,sy,tostring(...))
end
function api.setCursor(x,y) sx = x sy = y end
function api.print(...)
  local origx = sx
  api.write(...)
  sy = sy+1
  sx = origx
end
--TODO
function api.sleep(time) computer.pullSignal(time) end
function api.clear() local x,y = gpu.getResolution() gpu.fill(0,0,x,y," ") end
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
  api.getComponent("gpu").setResolution(x,y)
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
      api.clear()
      api.setCursor(1,1)
      api.ignore("touch", handleTouch)
      thingToExecute = buttons[y]
    end
  end
  while type(list) == "table" do
    api.listen("touch", handleTouch)
    if thingToExecute then
      thingToExecute()
      thingToExecute = nil
      api.listen("touch", handleTouch)
    else
      for n, module in pairs(api.modules) do
        module.callback()
      end
      api.autoResolution(list)
      api.clear()
      for _, text in ipairs(list) do
        api.print(text)
      end
      os.sleep(1)
    end
    list = listFunction()
    buttons = buttonsFunction()
  end
  api.ignore("touch", handleTouch)
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
--END API
gpu = api.getComponent("gpu")
filesystem = api.getComponent("filesystem",computer.getBootAddress)
local function loadfile(file)
  local handle, reason = filesystem.open(file)
  if not handle then
    error(reason)
  end
  local buffer = ""
  repeat
    local data, reason = filesystem.read(handle)
    if not data and reason then
      error(reason)
    end
    buffer = buffer .. (data or "")
  until not data
  filesystem.close(handle)
  return load(buffer, "=" .. file)
end

local function dofile(file)
  local program, reason = loadfile(file)
  if program then
    local result = table.pack(pcall(program))
    if result[1] then
      return table.unpack(result, 2, result.n)
    else
      error(result[2])
    end
  else
    error(reason)
  end
end

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
