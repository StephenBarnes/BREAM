local spawnerHealthMultiplier = settings.startup["BREAM-enemy-spawner-health-multiplier"].value
if spawnerHealthMultiplier ~= 1 then
	for _, spawner in pairs(data.raw['unit-spawner']) do
		spawner.max_health = spawner.max_health * spawnerHealthMultiplier
	end
end

local spawnerHealingMultiplier = settings.startup["BREAM-enemy-spawner-healing-multiplier"].value
if spawnerHealingMultiplier ~= 1 then
	for _, spawner in pairs(data.raw['unit-spawner']) do
		spawner.healing_per_tick = spawner.healing_per_tick * spawnerHealingMultiplier
	end
end

if settings.startup["BREAM-make-lamps-military-targets"].value then
	for _, lamp in pairs(data.raw.lamp) do
		lamp.is_military_target = true
	end
	for _, assemblerLamp in pairs {
		"deadlock-copper-lamp",
		"copper-aetheric-lamp-straight",
		"copper-aetheric-lamp-end"
	} do
		if data.raw["assembling-machine"][assemblerLamp] then
			data.raw["assembling-machine"][assemblerLamp].is_military_target = true
		end
	end
end

if settings.startup["BREAM-make-electric-poles-military-targets"].value then
	for _, pole in pairs(data.raw["electric-pole"]) do
		pole.is_military_target = true
	end
end