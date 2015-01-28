local term = require("term")
local component = require("component")
local event = require("event")
local capbank = component.capacitor_bank
local reactor = component.br_reactor
local module = {}
local online = reactor.getActive()
local reactorRF = 0
local reactorControlRodLevel = 0
local reactorFuelUsage = 0
local fuelLevel = 0
local fuelLevelMax = 0
local buttons = {}
local running = true
module.name = "reactor"
module.dispname = "Reactor Status"
function module.callback() 
  reactorRF = reactor.getEnergyProducedLastTick() 
  reactorFuelUsage = reactor.getFuelConsumedLastTick()
  fuelLevel = reactor.getFuelAmount()
  fuelLevelMax = reactor.getFuelAmountMax()
end
function module.message() return "Production: "..module.api.formatNum(reactorRF).."RF Fuel Usage: "..module.api.formatNum(fuelLevel).."/"..module.api.formatNum(fuelLevelMax) end
function module.reactorOnOff() reactor.setActive(not reactor.getActive()) end
function module.goBack()
  running = false
end
local function reactorList()
  local fnum = module.api.formatNum
  if not running then return false end
  local fuelLevel = reactor.getFuelAmount()
  local fuelLevelMax = reactor.getFuelAmountMax()
  local reactorOn = reactor.getActive()
  return {
  "Turn Reactor On/Off",
  "Back",
  "",
  "Reactor RF/t: "..fnum(reactorRF),
  "Reactor Fuel Level: "..fnum(fuelLevel).."/"..fnum(fuelLevelMax),
  "Reactor Fuel Usage: "..fnum(reactorFuelUsage),
  "Reactor Online? "..tostring(reactorOn)
  }
end
local function reactorButtons()
  return {module.reactorOnOff, module.goBack}
end
function module.activate()
  running = true
  module.api.displayList(reactorList, reactorButtons)
end
return module
