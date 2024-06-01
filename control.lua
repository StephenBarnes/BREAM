
------------------------------------------------------------------------
--- CONSTANTS

local spawnEveryTicks = settings.startup["BREAM-spawn-every-seconds"].value * 60

function splitToList(s)
	local result = {}
	for word in string.gmatch(s, '([^,]+)') do
		table.insert(result, word)
	end
	return result
end
local safeTiles = splitToList(settings.startup["BREAM-safe-tiles"].value)
local surfacesForSpawns = splitToList(settings.startup["BREAM-surfaces-to-spawn-on"].value)

local spawnPosTolerance = 2
local darknessThreshold = 0.65

------------------------------------------------------------------------
--- GENERAL UTILITY FUNCTIONS

function randomPosInside(box)
	return {
		x = box.left_top.x + math.random() * (box.right_bottom.x - box.left_top.x),
		y = box.left_top.y + math.random() * (box.right_bottom.y - box.left_top.y),
	}
end

function getChunkPosAndArea(c)
	-- Turns a ChunkPosition into a ChunkPositionAndArea.
	return {x = c.x, y = c.y,
		area = {
			left_top = { x = c.x * 32, y = c.y * 32 },
			right_bottom = { x = (c.x + 1) * 32, y = (c.y + 1) * 32} 
		}
	}
end

function randomBetween(a, b)
	return a + math.random() * (b - a)
end

function rg(s)
	-- Fetch runtime-global setting
	local val = settings.global["BREAM-"..s].value
	return val
end

------------------------------------------------------------------------
--- DEBUGGING TOOLS

function debug(s)
	if rg("debug-printing") then debugPrint(s) end
end

function debugPrint(s)
	-- Factorio suppresses duplicate prints, so I'm adding random numbers at the start to stop debug lines from being deleted as duplicate.
	-- It's stupid, but it works, and it's only for debugging.
	game.print(math.random(1000, 9999).." BREAM: "..s)
end

function boolStr(b)
	if (b) then return "TRUE" else return "FALSE" end
end

function playerPosDebug()
	debugPrint("--------------------")
	debugPrint("BREAM player-position debugger, checking current position.")
	local surface = game.get_surface(surfacesForSpawns[1])
	for _,player in pairs(game.players) do
		local pos = player.position
		debugPrint("Starting peace time allows spawn: "..boolStr(not startingPeaceActive()))
		debugPrint("Darkness / time of day allows spawn: "..boolStr(lightLevelAllowsSpawn(surface)))
		debugPrint("Nearby enemies allow spawn: "..boolStr(nearbyEnemiesAllowSpawn(pos, surface)))
		debugPrint("Nearby players allow spawn: "..boolStr(nearbyPlayersAllowSpawn(pos, surface)))
		debugPrint("Nearby lamps allow spawn: "..boolStr(nearbyLampsAllowSpawn(pos, surface)))
		debugPrint("Nearby water tiles allow spawn: "..boolStr(nearbyLampsAllowSpawn(pos, surface)))
		debugPrint("Nearby safe tiles allow spawn: "..boolStr(nearbySafeTilesAllowSpawn(pos, surface)))
		debugPrint("Nearby entities allow spawn: "..boolStr(nearbyEntitiesAllowSpawn(pos, surface)))
	end
end

------------------------------------------------------------------------
--- FUNCTIONS FOR CHECKING WHETHER SPAWNING IS ALLOWED AT A TIME/PLACE

function startingPeaceActive()
	return game.tick <= rg("starting-peace-minutes")*3600
end

function lightLevelAllowsSpawn(surface)
	if not rg("only-spawn-when-dark") then return true end
	--return (surface.daytime > surface.dusk) and (surface.daytime < surface.dawn)
	-- From testing, this spawns when it's still light.
	-- Instead, I'll do what the Rampant mod's "nocturnal" setting uses, which is to check that darkness is over 0.65.
	return surface.darkness > darknessThreshold
end

function nearbyEnemiesAllowSpawn(pos, surface)
	local rad = rg("enemy-spawn-block-radius")
	if rad == 0 then return true end
	local nearbyEnemyCount = #(surface.find_enemy_units(pos, rad))
	return nearbyEnemyCount < rg("enemy-count-for-spawn-blocking")
end

function nearbyPlayersAllowSpawn(pos, surface)
	local rad = rg("player-spawn-block-radius")
	if rad == 0 then return true end
	local playerCount = surface.count_entities_filtered(
		{position=pos, radius=rad, limit=1, type="character"})
	return playerCount == 0
end

function isLampOn(lampEntity, surface)
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

function nearbyLampsAllowSpawn(pos, surface)
	local safetyFactor = rg("lamp-safety-factor")
	if safetyFactor == 0 then return true end

	-- Check all lamps registered as lamps.
	local searchRadius = safetyFactor * maxLampLightRadius
	local lamps = surface.find_entities_filtered{position=pos, radius=searchRadius, type="lamp"}
	for i, lamp in pairs(lamps) do
		if isLampOn(lamp, surface) then
			local x = (lamp.bounding_box.left_top.x + lamp.bounding_box.right_bottom.x) / 2
			local y = (lamp.bounding_box.left_top.y + lamp.bounding_box.right_bottom.y) / 2
			local distanceSq = math.pow(pos.x - x, 2) + math.pow(pos.y - y, 2)
			local distance = math.sqrt(distanceSq)
			local lightRadius = lightRadius[lamp.name] or defaultLightRadius
			if (lightRadius * safetyFactor) > distance then return false end
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
				if (v * safetyFactor) > distance then return false end
			end
		end
	end

	return true
end

function nearbyWaterTilesAllowSpawn(pos, surface)
	local rad = rg("water-tile-spawn-block-radius")
	if rad == 0 then return true end
	local waterTileCount = surface.count_tiles_filtered(
		{position=pos, radius=rad, collision_mask="water-tile", limit=1})
	return waterTileCount == 0
end

function nearbySafeTilesAllowSpawn(pos, surface)
	local rad = rg("safe-tile-spawn-block-radius")
	if rad == 0 then return true end
	local safeTileCount = surface.count_tiles_filtered(
		{position=pos, radius=rad, name=safeTiles, limit=1})
	return safeTileCount == 0
end

function nearbyEntitiesAllowSpawn(pos, surface)
	local rad = rg("entity-spawn-block-radius")
	if rad == 0 then return true end
	-- Use count_entities_filtered to find whether there's at least 1 non-resource entity in the box.
	local entityCount = surface.count_entities_filtered(
		{position=pos, radius=rad, limit=1, invert=true, type={"resource", "tree", "simple-entity"}})
		-- Type "simple-entity" is for minable rocks.
	return entityCount == 0
end

function positionAllowsSpawn(pos, surface)
	if rg("debug-printing") then
		if not nearbyEnemiesAllowSpawn(pos, surface) then
			debugPrint("Nearby enemies blocked spawn.")
		elseif not nearbyPlayersAllowSpawn(pos, surface) then
			debugPrint("Nearby player blocked spawn.")
		elseif not nearbyLampsAllowSpawn(pos, surface) then
			debugPrint("Nearby lamps blocked spawn.")
		elseif not nearbyWaterTilesAllowSpawn(pos, surface) then
			debugPrint("Water tiles blocked spawn.")
		elseif not nearbySafeTilesAllowSpawn(pos, surface) then
			debugPrint("Safe tiles blocked spawn.")
		elseif not nearbyEntitiesAllowSpawn(pos, surface) then
			debugPrint("Nearby entities blocked spawn.")
		end
	end
	return (nearbyEnemiesAllowSpawn(pos, surface)
		and nearbyPlayersAllowSpawn(pos, surface)
		and nearbyLampsAllowSpawn(pos, surface)
		and nearbyWaterTilesAllowSpawn(pos, surface)
		and nearbySafeTilesAllowSpawn(pos, surface)
		and nearbyEntitiesAllowSpawn(pos, surface))
end

function getSpawnChance(pollution)
	-- Return probability that a swarm should spawn in a chunk, given pollution.
	if pollution < rg("min-pollution-for-spawn") then
		return 0
	elseif pollution > rg("pollution-for-max-spawn-chance") then
		return rg("spawn-chance-at-max-pollution")
	else
		local x = (pollution - rg("min-pollution-for-spawn")) / (rg("pollution-for-max-spawn-chance")- rg("min-pollution-for-spawn"))
		return rg("spawn-chance-at-min-pollution") + (x * (rg("spawn-chance-at-max-pollution") - rg("spawn-chance-at-min-pollution")))
	end
end

------------------------------------------------------------------------
--- FUNCTIONS FOR FLESHING OUT THE DETAILS OF ENEMY SWARMS.
--- TO ADD SUPPORT FOR MODS THAT CREATE NEW ENEMY TYPES, ADD THEM HERE.
--- TODO If you add compat for more enemy mods, you should add a way to specify minimum evolution for each bug class, so that eg Rampant's new enemy types only start appearing at a certain evolution level.

function getBugClasses()
	local bugClasses = {"biter", "spitter"}
	-- Include enemies from Armoured Biters mod
	if game.entity_prototypes["small-armoured-biter"] ~= nil then
		table.insert(bugClasses, "armoured-biter")
	end
	return bugClasses
end

local bugClassToSizes = {
	biter = {"small", "medium", "big", "behemoth"},
	spitter = {"small", "medium", "big", "behemoth"},
	["armoured-biter"] = {"small", "medium", "big", "behemoth", "leviathan"},
	-- NOTE The chosen size is linear in evolution, over these lists; for example biters will be small or medium if evolution is between 0 and 0.33, between medium and big if evolution is 0.33 to 0.67, etc.
	-- So you could repeat sizes in these lists to change the shape of the curve relating evolution to bug size.
	-- This mod currently chooses sizes in different ratios than the ones in vanilla.
}
function getBugSize(bugClass, evolutionFactor)
	-- Instead of choosing size like the bug nests do, I'll instead just make it linear.
	local numSizes = #(bugClassToSizes[bugClass])
	local minSizeIdx = math.floor(evolutionFactor * (numSizes - 1)) + 1
	local maxSizeIdx = minSizeIdx + 1
	if maxSizeIdx > numSizes then return bugClassToSizes[bugClass][minSizeIdx] end
	local evoPerSizeGap = 1.0 / (numSizes - 1)
	local minSizeIsAtEvo = evoPerSizeGap * (minSizeIdx - 1)
	local chanceOfBiggerSize = (evolutionFactor - minSizeIsAtEvo) / evoPerSizeGap
	--debug("Num sizes "..numSizes..", evolutionFactor "..evolutionFactor..", min size index "..minSizeIdx..", chance of bigger size is "..chanceOfBiggerSize)
	if math.random() < chanceOfBiggerSize then
		return bugClassToSizes[bugClass][maxSizeIdx]
	else
		return bugClassToSizes[bugClass][minSizeIdx]
	end
end

function pollutionForBug(bugName)
	return game.entity_prototypes[bugName].pollution_to_join_attack * rg("pollution-cost-multiplier")
end

function selectBugs(pollutionInChunk, evolutionFactor)
	local bugClasses = getBugClasses()
	local bugClassSubset = {} -- Subset of bug classes to use for this swarm.
	-- Always choose at least 1 bug class to include.
	guaranteedBugClass = bugClasses[math.random(#bugClasses)]
	table.insert(bugClassSubset, guaranteedBugClass)
	-- Then add each additional bug class with some probability.
	for i, class in pairs(bugClasses) do
		if class ~= guaranteedBugClass then
			if math.random() < rg("extra-bug-class-chance") then
				table.insert(bugClassSubset, class)
			end
		end
	end

	local pollutionFraction = randomBetween(rg("pollution-fraction-per-swarm-min"), rg("pollution-fraction-per-swarm-max"))
	local pollutionBudget = pollutionInChunk * pollutionFraction
	debug("Pollution budget is "..math.floor(pollutionBudget).." for a chunk with pollution "..math.floor(pollutionInChunk)..".")
	local pollutionSpent = 0.0
	local bugs = {}
	local bugTypeToPollution = {}
	for i = 1, rg("max-bugs-per-swarm") do
		local bugClass = bugClassSubset[math.random(#bugClassSubset)]
		local bugSize = getBugSize(bugClass, evolutionFactor)
		local bugName = bugSize .. "-" .. bugClass
		local pollutionForThisBug = pollutionForBug(bugName)
		if (pollutionSpent + pollutionForThisBug) > pollutionBudget then
			debug("Couldn't afford next bug "..bugName.." for "..pollutionForThisBug.." pollution.")
			break
		end
		bugTypeToPollution[bugName] = (bugTypeToPollution[bugName] or 0) + pollutionForThisBug
		pollutionSpent = pollutionSpent + pollutionForThisBug
		debug("Bought "..bugName.." for "..pollutionForThisBug.." pollution, remaining budget: "..math.floor(pollutionBudget-pollutionSpent))
		table.insert(bugs, bugName)
	end
	if #bugs > 0 then
		debug("Purchased a swarm of "..#bugs.." bugs for "..math.floor(pollutionSpent).." pollution.")
	else
		debug("Couldn't afford any bugs :(") -- Happens sometimes in low-pollution chunks with high evolution.
	end
	return {bugs, pollutionSpent, bugTypeToPollution}
end

------------------------------------------------------------------------
--- FUNCTIONS FOR CREATING ENEMY GROUPS

function spawnEnemyAt(bugName, pos, group, surface)
	local bug = surface.create_entity{name = bugName, position = pos}
	bug.ai_settings.allow_try_return_to_spawner = false
	group.add_member(bug)
end

function logBugPollutionToStats(bugTypeToPollution)
	for bugType, pollution in pairs(bugTypeToPollution) do
		game.pollution_statistics.on_flow(bugType, -pollution)
	end
end

function spawnEnemyGroupAt(centerPos, surface)
	debug("Spawning a swarm at " .. math.floor(centerPos.x) .. "," .. math.floor(centerPos.y))
	local bugPos = surface.find_non_colliding_position("behemoth-biter", centerPos, spawnPosTolerance, 0.1)
	if bugPos == nil then
		debug("Couldn't find a non-colliding position for bugs")
		return
	end
	local pollution = surface.get_pollution(centerPos)
	if pollution == 0 then
		debug("Pollution is zero, cannot spawn bugs")
		return
	end
	local bugsAndPollutionSpent = selectBugs(pollution, game.forces.enemy.evolution_factor)
	local bugs = bugsAndPollutionSpent[1]
	local pollutionSpent = bugsAndPollutionSpent[2]
	local bugTypeToPollution = bugsAndPollutionSpent[3]
	if #bugs == 0 then return end
	surface.pollute(centerPos, -pollutionSpent)
	logBugPollutionToStats(bugTypeToPollution)
	local group = surface.create_unit_group{position = centerPos}
	for i = 1, #bugs do
		spawnEnemyAt(bugs[i], bugPos, group, surface)
	end
	group.set_autonomous()
end

function considerSpawningEnemiesOnChunk(chunk, surface)
	local pollution = surface.get_pollution(chunk.area.left_top)
	local spawnChance = getSpawnChance(pollution)
	if spawnChance == 0 then
		debug("Chunk pollution ("..math.floor(pollution)..") is too low to spawn; minimum is "..rg("min-pollution-for-spawn")..".")
		return
	end
	if math.random() > spawnChance then
		debug("Pollution-based per-chunk spawn chance prevented spawning; spawn chance was "..math.floor(spawnChance*100).."%, pollution was "..math.floor(pollution)..".")
		return
	end

	local spawnPos = randomPosInside(chunk.area)
	if not positionAllowsSpawn(spawnPos, surface) then return end
	spawnEnemyGroupAt(spawnPos, surface)
end

------------------------------------------------------------------------

script.on_nth_tick(spawnEveryTicks,
	function (event)
		if rg("player-pos-debug") then
			playerPosDebug()
			return
		end
		if rg("debug-printing") then
			debugPrint("--------------------")
			debugPrint("BREAM: debug printing enabled, checking.")
		end
		local spawnAtAllChance = rg("spawn-at-all-chance")
		if (spawnAtAllChance < 1.0) and (math.random() > spawnAtAllChance) then
			debug("Spawn-at-all-chance prevented spawn.")
			return
		end

		for i, surfaceName in pairs(surfacesForSpawns) do
			local surface = game.get_surface(surfaceName)
			if surface == nil then
				debug("Surface is nil")
				return
			end
			if not lightLevelAllowsSpawn(surface) then
				debug("Surface / time-of-day isn't dark enough to spawn.")
				return
			end
			if startingPeaceActive() then
				debug("Starting peace time prevented spawn.")
				return
			end

			debug("Time allows spawn, checking chunks.")
			local numChunksToCheck = rg("num-chunks-to-check")
			if numChunksToCheck == 0 then -- check all of them
				for chunk in surface.get_chunks() do
					if surface.is_chunk_generated{chunk.x, chunk.y} then
						considerSpawningEnemiesOnChunk(chunk, surface)
					else
						debug("Spawn prevented by chunk not being generated.")
					end
				end
			else -- check only a few random chunks
				for chunkNum = 1, numChunksToCheck do
					if numChunksToCheck > 1 then debug("Spawn attempt #"..chunkNum) end
					local chunkPos = surface.get_random_chunk()
					if surface.is_chunk_generated{chunkPos.x, chunkPos.y} then
						considerSpawningEnemiesOnChunk(getChunkPosAndArea(chunkPos), surface)
					else
						debug("Spawn prevented by chunk not being generated.")
					end
				end
			end
		end
	end
)
