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