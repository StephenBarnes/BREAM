local U = require("code/util")
local Const = require("code/control/control-constants")
local Checks = require("code/control/check-spawn-suitability")
local Spawn = require("code/control/spawn-bugs")

local function getSpawnChance(pollution)
	-- Return probability that a swarm should spawn in a chunk, given pollution.
	if pollution < U.mapSetting("min-pollution-for-spawn") then
		return 0
	elseif pollution > U.mapSetting("pollution-for-max-spawn-chance") then
		return U.mapSetting("spawn-chance-at-max-pollution")
	else
		local x = (pollution - U.mapSetting("min-pollution-for-spawn")) / (U.mapSetting("pollution-for-max-spawn-chance")- U.mapSetting("min-pollution-for-spawn"))
		return U.mapSetting("spawn-chance-at-min-pollution") + (x * (U.mapSetting("spawn-chance-at-max-pollution") - U.mapSetting("spawn-chance-at-min-pollution")))
	end
end

---@param chunk ChunkPositionAndArea
---@param surface LuaSurface
---@param enemyPhylum string
local function considerSpawningEnemiesOnChunk(chunk, surface, enemyPhylum)
	local pollution = surface.get_pollution(chunk.area.left_top)
	local spawnChance = getSpawnChance(pollution)
	if spawnChance == 0 then
		U.printIfDebug("Chunk pollution ("..math.floor(pollution)..") is too low to spawn; minimum is "..U.mapSetting("min-pollution-for-spawn")..".")
		return
	end
	if math.random() > spawnChance then
		U.printIfDebug("Pollution-based per-chunk spawn chance prevented spawning; spawn chance was "..math.floor(spawnChance*100).."%, pollution was "..math.floor(pollution)..".")
		return
	end

	local spawnPos = U.randomPosInside(chunk.area)
	if not Checks.positionAllowsSpawn(spawnPos, surface) then return end
	Spawn.spawnEnemyGroupAt(spawnPos, surface, enemyPhylum)
end

---@param event EventData.on_tick
local function onNthTick(event)
	if U.mapSetting("debug-printing") == "player-pos" then
		Checks.playerPosDebug()
	elseif U.mapSetting("debug-printing") == "all" then
		U.debugPrint("--------------------")
		U.debugPrint("BREAM: debug printing enabled, checking.")
	end

	local spawnAtAllChance = U.mapSetting("spawn-at-all-chance")
	if (spawnAtAllChance < 1.0) and (math.random() > spawnAtAllChance) then
		U.printIfDebug("Spawn-at-all-chance prevented spawn.")
		return
	end

	for _, phylumSurfaces in pairs(Const.phylumSurfaces) do
		for _, surfaceName in pairs(phylumSurfaces.surfaceNames) do
			local surface = game.get_surface(surfaceName)
			if surface == nil then
				-- Could happen eg if Gleba hasn't been visited yet.
				U.printIfDebug("Surface "..surfaceName.." is nil")
				return
			end
			if not Checks.lightLevelAllowsSpawn(surface) then
				U.printIfDebug("Surface / time-of-day isn't dark enough to spawn.")
				return
			end
			if Checks.startingPeaceActive() then
				U.printIfDebug("Starting peace time prevented spawn.")
				return
			end

			U.printIfDebug("Time allows spawn, checking chunks.")
			local numChunksToCheck = U.mapSetting("num-chunks-to-check")
			if numChunksToCheck == 0 then -- check all of them
				for chunk in surface.get_chunks() do
					if surface.is_chunk_generated { chunk.x, chunk.y } then
						considerSpawningEnemiesOnChunk(chunk, surface, phylumSurfaces.phylum)
					else
						U.printIfDebug("Spawn prevented by chunk not being generated.")
					end
				end
			else -- check only a few random chunks
				for chunkNum = 1, numChunksToCheck do
					if numChunksToCheck > 1 then U.printIfDebug("["..surfaceName.."] Spawn attempt #" .. chunkNum) end
					local chunkPos = surface.get_random_chunk()
					if surface.is_chunk_generated { chunkPos.x, chunkPos.y } then
						considerSpawningEnemiesOnChunk(U.getChunkPosAndArea(chunkPos), surface, phylumSurfaces.phylum)
					else
						U.printIfDebug("Spawn prevented by chunk not being generated.")
					end
				end
			end
		end
	end
end

local Export = {}
Export.registerHandler = function()
	script.on_nth_tick(Const.spawnEveryTicks, onNthTick)
end
return Export