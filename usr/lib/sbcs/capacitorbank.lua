local term = require("term")
local component = require("component")
local event = require("event")
local capbank = component.capacitor_bank
local module = {}
local energyStored = 0
local changePerTick = 0
module.name = "capacitorbank"
module.dispname = "Capacitor Bank Storage"
function module.callback() energyStored = capbank.getEnergyStored() changePerTick = capbank.getAverageChangePerTick() end
function module.message() return "Storage: "..energyStored.."RF, RF/t: "..changePerTick end
function module.activate() 
  print("Storage: "..energyStored.."RF, RF/t: "..changePerTick)
  print("Max Storage:  "..capbank.getMaxEnergyStored().."RF")
  print("Max RF/t in:  "..capbank.getMaxInput())
  print("Max RF/t out: "..capbank.getMaxOutput())
  print("Touch to go back.")
  event.pull("touch")
end
return module
