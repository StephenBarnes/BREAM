local newSettings = {}

local nextOrderNum = 0
local function nextOrder()
	nextOrderNum = nextOrderNum + 1
	return string.format("%03d", nextOrderNum)
end

local function addSetting(name, valType, stage, default, minVal, maxVal)
	table.insert(newSettings, {
		type = valType .. "-setting",
		name = "BREAM-" .. name,
		setting_type = stage,
		default_value = default,
		order = nextOrder(),
		minimum_value = minVal,
		maximum_value = maxVal,
	})
end

local function addSafetySetting(name, default)
	table.insert(newSettings, {
		type = "string-setting",
		name = "BREAM-safety-" .. name,
		setting_type = "startup",
		default_value = default,
		allowed_values = { "military-target", "default", "safe" },
		order = nextOrder(),
	})
end

addSetting("surfaces-to-spawn-on", "string", "startup", "nauvis")
addSetting("safe-tiles", "string", "startup",
	"stone-path,concrete,refined-concrete,tarmac,hazard-concrete-left,hazard-concrete-right,refined-hazard-concrete-left,refined-hazard-concrete-right")
-- TODO add paving tiles from mods, eg the stone path from Space Exploration
addSetting("spawn-every-seconds", "double", "startup", 2.0, 0.1)
addSetting("enemy-spawner-health-multiplier", "double", "startup", 1.0, 0.0)
addSetting("enemy-spawner-healing-multiplier", "double", "startup", 1.0, 0.0)

addSafetySetting("lamps", "military-target")
addSafetySetting("power-poles", "default")
addSafetySetting("railways", "safe")
addSafetySetting("rail-signals", "safe")

addSetting("pollution-cost-multiplier", "double", "runtime-global", 0.5, 0.01)
addSetting("max-bugs-per-swarm", "int", "runtime-global", 50, 1)
addSetting("spawn-at-all-chance", "double", "runtime-global", 1.0, 0.0, 1.0)
addSetting("num-chunks-to-check", "int", "runtime-global", 5, 0)
addSetting("starting-peace-minutes", "double", "runtime-global", 5, 0)
addSetting("only-spawn-when-dark", "bool", "runtime-global", true)
addSetting("player-spawn-block-radius", "int", "runtime-global", 100, 0)
addSetting("water-tile-spawn-block-radius", "int", "runtime-global", 5, 0)
addSetting("safe-tile-spawn-block-radius", "int", "runtime-global", 0, 0)
addSetting("lit-safe-tile-spawn-block-radius", "int", "runtime-global", 0, 0)
addSetting("entity-spawn-block-radius", "int", "runtime-global", 15, 0)
addSetting("lamp-safety-factor", "double", "runtime-global", 1.2, 0)
addSetting("enemy-spawn-block-radius", "int", "runtime-global", 100, 0)
addSetting("enemy-count-for-spawn-blocking", "int", "runtime-global", 10, 0)
addSetting("extra-bug-class-chance", "double", "runtime-global", 0.5, 0, 1)
addSetting("min-pollution-for-spawn", "int", "runtime-global", 20, 0)
addSetting("spawn-chance-at-min-pollution", "double", "runtime-global", 0.2, 0, 1)
addSetting("pollution-for-max-spawn-chance", "double", "runtime-global", 100, 0)
addSetting("spawn-chance-at-max-pollution", "double", "runtime-global", 1.0, 0, 1)
addSetting("pollution-fraction-per-swarm-min", "double", "runtime-global", 0.3, 0, 1)
addSetting("pollution-fraction-per-swarm-max", "double", "runtime-global", 0.9, 0, 1)

table.insert(newSettings, {
	type = "string-setting",
	name = "BREAM-debug-printing",
	setting_type = "runtime-global",
	default_value = "off",
	allowed_values = { "off", "player-pos", "report-spawns", "all" },
	order = nextOrder(),
})

data:extend(newSettings)
