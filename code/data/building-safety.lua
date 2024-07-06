if settings.startup["BREAM-safety-lamps"].value == "military-target" then
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

if settings.startup["BREAM-safety-power-poles"].value == "military-target" then
	for _, pole in pairs(data.raw["electric-pole"]) do
		pole.is_military_target = true
	end
end