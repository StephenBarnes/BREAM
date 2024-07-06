--- FUNCTIONS FOR CHECKING WHETHER SPAWNING IS ALLOWED AT A TIME/PLACE

local U = require("code/util")
local CC = require("code/control/control-constants")

local Export = {}

Export.startingPeaceActive = function()
	return game.tick <= U.mapSetting("starting-peace-minutes")*3600
end

local function surfaceIsDark(surface)
	--return (surface.daytime > surface.dusk) and (surface.daytime < surface.dawn)
	-- From testing, this spawns when it's still light.
	-- Instead, I'll do what the Rampant mod's "nocturnal" setting uses, which is to check that darkness is over 0.65.
	return surface.darkness > CC.darknessThreshold
end

Export.lightLevelAllowsSpawn = function(surface)
	if not U.mapSetting("only-spawn-when-dark") then return true end
	return surfaceIsDark(surface)
end

local function nearbyEnemiesAllowSpawn(pos, surface)
	local rad = U.mapSetting("enemy-spawn-block-radius")
	if rad == 0 then return true end
	local nearbyEnemyCount = #(surface.find_enemy_units(pos, rad))
	return nearbyEnemyCount < U.mapSetting("enemy-count-for-spawn-blocking")
end

local function nearbyPlayersAllowSpawn(pos, surface)
	local rad = U.mapSetting("player-spawn-block-radius")
	if rad == 0 then return true end
	local playerCount = surface.count_entities_filtered(
		{position=pos, radius=rad, limit=1, type="character"})
	return playerCount == 0
end

local function isLampOn(lampEntity, surface)
	-- Apparently the API does not give any easy way to check this?
	-- If you know how to do this better, please raise an issue or submit a PR.
	if not lampEntity.valid then return false end
	if not lampEntity.is_connected_to_electric_network() then return false end
	if lampEntity.energy == 0 then return false end

	local lampControl = lampEntity.get_control_behavior()
	if lampControl ~= nil then
		if not lampControl.valid then return false end
		return not lampControl.disabled
	else
		return (lampEntity.prototype.always_on or false) or (lampEntity.prototype.darkness_for_all_lamps_off < surface.darkness)
		-- FIXME this isn't quite correct because individual lamps turn on/off at random times, darkness_for_all_lamps_on/off doesn't guarantee whether this one lamp is on/off. So, currently playing it safe and just assuming all powered lights are on when it's dark.
	end
end

-- Numbers from measuring manually in-game.
local defaultLightRadius = 17 -- Assumed radius for unknown lamps from other mods.
local lightRadius = {
	["small-lamp"] = 17,
	["deadlock-large-lamp"] = 29,
	["deadlock-floor-lamp"] = 29,
}
local assemblerLightRadius = {
	["deadlock-copper-lamp"] = 29,
	["copper-aetheric-lamp-straight"] = 12,
	["copper-aetheric-lamp-end"] = 12,
}
local maxLampLightRadius = 29

local function hasNearbyLamp(pos, surface, lampRadMultiplier)
	-- Check all lamps registered as lamps.
	local searchRadius = lampRadMultiplier * maxLampLightRadius
	local lamps = surface.find_entities_filtered{position=pos, radius=searchRadius, type="lamp"}
	for i, lamp in pairs(lamps) do
		if isLampOn(lamp, surface) then
			local x = (lamp.bounding_box.left_top.x + lamp.bounding_box.right_bottom.x) / 2
			local y = (lamp.bounding_box.left_top.y + lamp.bounding_box.right_bottom.y) / 2
			local distanceSq = math.pow(pos.x - x, 2) + math.pow(pos.y - y, 2)
			local distance = math.sqrt(distanceSq)
			local lightRadius = lightRadius[lamp.name] or defaultLightRadius
			if (lightRadius * lampRadMultiplier) > distance then return true end
		end
	end

	-- Check all lamps registered as assemblers.
	-- Deadlock's Larger Lamps and Industrial Revolution 3 do this for copper and aetheric lamps, so that they can consume fuel items or steam.
	for k, v in pairs(assemblerLightRadius) do
		local lamps = surface.find_entities_filtered{position=pos, radius=searchRadius, name=k}
		for i, lamp in pairs(lamps) do
			if lamp.is_crafting() then
				local x = (lamp.bounding_box.left_top.x + lamp.bounding_box.right_bottom.x) / 2
				local y = (lamp.bounding_box.left_top.y + lamp.bounding_box.right_bottom.y) / 2
				local distanceSq = math.pow(pos.x - x, 2) + math.pow(pos.y - y, 2)
				local distance = math.sqrt(distanceSq)
				if (v * lampRadMultiplier) > distance then return true end
			end
		end
	end

	return false
end

local function nearbyLampsAllowSpawn(pos, surface)
	local safetyFactor = U.mapSetting("lamp-safety-factor")
	if safetyFactor == 0 then return true end
	return not hasNearbyLamp(pos, surface, safetyFactor)
end

local function nearbyWaterTilesAllowSpawn(pos, surface)
	local rad = U.mapSetting("water-tile-spawn-block-radius")
	if rad == 0 then return true end
	local waterTileCount = surface.count_tiles_filtered(
		{position=pos, radius=rad, collision_mask="water-tile", limit=1})
	return waterTileCount == 0
end

local function hasNearbySafeTiles(pos, surface, rad)
	local safeTileCount = surface.count_tiles_filtered(
		{position=pos, radius=rad, name=CC.safeTiles, limit=1})
	return safeTileCount ~= 0
end

local function nearbySafeTilesAllowSpawn(pos, surface)
	local rad = U.mapSetting("safe-tile-spawn-block-radius")
	if rad == 0 then return true end
	return not hasNearbySafeTiles(pos, surface, rad)
end

local function nearbyLitSafeTilesAllowSpawn(pos, surface)
	local rad = U.mapSetting("lit-safe-tile-spawn-block-radius")
	if rad == 0 then return true end
	if hasNearbySafeTiles(pos, surface, rad) then
		local isLit = (not surfaceIsDark(surface)) or hasNearbyLamp(pos, surface, 1.0)
		return not isLit
	end
	return true
end

local function nearbyEntitiesAllowSpawn(pos, surface)
	local rad = U.mapSetting("entity-spawn-block-radius")
	if rad == 0 then return true end
	-- Use count_entities_filtered to find whether there's at least 1 non-resource entity in the box.
	local entityCount = surface.count_entities_filtered(
		{position=pos, radius=rad, limit=1, invert=true, type={"resource", "tree", "simple-entity"}})
		-- Type "simple-entity" is for minable rocks.
	return entityCount == 0
end

------------------------------------------------------------------------

Export.positionAllowsSpawn = function(pos, surface)
	if U.mapSetting("debug-printing") then
		if not nearbyEnemiesAllowSpawn(pos, surface) then
			U.debugPrint("Nearby enemies blocked spawn.")
		elseif not nearbyPlayersAllowSpawn(pos, surface) then
			U.debugPrint("Nearby player blocked spawn.")
		elseif not nearbyLampsAllowSpawn(pos, surface) then
			U.debugPrint("Nearby lamps blocked spawn.")
		elseif not nearbyWaterTilesAllowSpawn(pos, surface) then
			U.debugPrint("Water tiles blocked spawn.")
		elseif not nearbySafeTilesAllowSpawn(pos, surface) then
			U.debugPrint("Safe tiles blocked spawn.")
		elseif not nearbyLitSafeTilesAllowSpawn(pos, surface) then
			U.debugPrint("Lit safe tiles blocked spawn.")
		elseif not nearbyEntitiesAllowSpawn(pos, surface) then
			U.debugPrint("Nearby entities blocked spawn.")
		end
	end
	return (nearbyEnemiesAllowSpawn(pos, surface)
		and nearbyPlayersAllowSpawn(pos, surface)
		and nearbyLampsAllowSpawn(pos, surface)
		and nearbyWaterTilesAllowSpawn(pos, surface)
		and nearbySafeTilesAllowSpawn(pos, surface)
		and nearbyLitSafeTilesAllowSpawn(pos, surface)
		and nearbyEntitiesAllowSpawn(pos, surface))
end

Export.playerPosDebug = function()
	U.debugPrint("--------------------")
	U.debugPrint("BREAM player-position debugger, checking current position.")
	local surface = game.get_surface(CC.surfacesForSpawns[1])
	for _,player in pairs(game.players) do
		local pos = player.position
		U.debugPrint("Starting peace time allows spawn: "..U.boolStr(not Export.startingPeaceActive()))
		U.debugPrint("Darkness / time of day allows spawn: "..U.boolStr(Export.lightLevelAllowsSpawn(surface)))
		U.debugPrint("Nearby enemies allow spawn: "..U.boolStr(nearbyEnemiesAllowSpawn(pos, surface)))
		U.debugPrint("Nearby players allow spawn: "..U.boolStr(nearbyPlayersAllowSpawn(pos, surface)))
		U.debugPrint("Nearby lamps allow spawn: "..U.boolStr(nearbyLampsAllowSpawn(pos, surface)))
		U.debugPrint("Nearby water tiles allow spawn: "..U.boolStr(nearbyWaterTilesAllowSpawn(pos, surface)))
		U.debugPrint("Nearby safe tiles allow spawn: "..U.boolStr(nearbySafeTilesAllowSpawn(pos, surface)))
		U.debugPrint("Nearby lit safe tiles allow spawn: "..U.boolStr(nearbyLitSafeTilesAllowSpawn(pos, surface)))
		U.debugPrint("Nearby entities allow spawn: "..U.boolStr(nearbyEntitiesAllowSpawn(pos, surface)))
	end
end

return Export