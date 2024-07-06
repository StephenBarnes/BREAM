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