local Export = {}

Export.spawnEveryTicks = settings.startup["BREAM-spawn-every-seconds"].value * 60

local function splitToList(s)
	if s == "" then return {} end
	local result = {}
	for word in string.gmatch(s, '([^,]+)') do
		table.insert(result, word)
	end
	return result
end

local possibleSafeTiles = splitToList(settings.startup["BREAM-safe-tiles"].value)
Export.safeTiles = {}
for _, tileName in pairs(possibleSafeTiles) do
	if prototypes.tile[tileName] ~= nil then
		table.insert(Export.safeTiles, tileName)
	else
		log("Warning: safe tile "..tileName.." is not a valid tile name.")
	end
end

Export.phylumSurfaces = {
	{phylum = "nauvis", surfaceNames = splitToList(settings.startup["BREAM-surfaces-to-spawn-nauvis-enemies"].value)},
	{phylum = "gleba", surfaceNames = splitToList(settings.startup["BREAM-surfaces-to-spawn-gleba-enemies"].value)},
}

Export.spawnPosTolerance = 2
Export.darknessThreshold = 0.65

return Export