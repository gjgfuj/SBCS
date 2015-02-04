local capbank
local module = {}
local energyStored = 0
local changePerTick = 0
local done = false
module.name = "capacitorbank"
module.dispname = "Capacitor Bank Storage"
function module.callback() energyStored = capbank.getEnergyStored() changePerTick = capbank.getAverageChangePerTick() end
function module.message() return "Storage: "..module.api.formatNum(energyStored).."RF, IO: "..module.api.formatNum(changePerTick).."RF" end
function module.setup() capbank = module.api.getComponent("capbank", nil) end
local function back()
  done = true
end
local function list()
  local fnum = module.api.formatNum
  if done then return false end
  return {
  "Storage: "..fnum(energyStored).."RF, RF/t: "..fnum(changePerTick),
  "Max Storage:  "..fnum(capbank.getMaxEnergyStored()).."RF",
  "Max RF/t in:  "..fnum(capbank.getMaxInput()),
  "Max RF/t out: "..fnum(capbank.getMaxOutput()),
  "Touch to go back."}
end
local function buttons()
  return { nil,nil,nil,nil,back }
end
function module.activate()
  done = false
  module.api.displayList(list, buttons)
end
return module
