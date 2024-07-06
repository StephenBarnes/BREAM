local Export = {}

Export.spawnEveryTicks = settings.startup["BREAM-spawn-every-seconds"].value * 60

local function splitToList(s)
	local result = {}
	for word in string.gmatch(s, '([^,]+)') do
		table.insert(result, word)
	end
	return result
end
Export.safeTiles = splitToList(settings.startup["BREAM-safe-tiles"].value)
Export.surfacesForSpawns = splitToList(settings.startup["BREAM-surfaces-to-spawn-on"].value)

Export.spawnPosTolerance = 2
Export.darknessThreshold = 0.65

return Export