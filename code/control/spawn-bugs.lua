--- FUNCTIONS FOR SPAWNING ENEMY GROUPS

local U = require("code/util")
local CC = require("code/control/control-constants")
local ChooseBugs = require("code/control/choose-bugs")

local Export = {}

---@param bugName string
---@param pos table
---@param commandable LuaCommandable
---@param surface LuaSurface
local function spawnEnemyAt(bugName, pos, commandable, surface)
	local bug = surface.create_entity{name = bugName, position = pos}
	if bug == nil then
		U.printIfDebug("Failed to create bug")
		return
	end
	bug.ai_settings.allow_try_return_to_spawner = false
	commandable.add_member(bug)
end

---@param bugTypeToPollution table<string, number>
---@param surface LuaSurface
local function logBugPollutionToStats(bugTypeToPollution, surface)
	for bugType, pollution in pairs(bugTypeToPollution) do
		game.get_pollution_statistics(surface).on_flow(bugType, -pollution)
	end
end

---@param centerPos table
---@param surface LuaSurface
---@param enemyPhylum string
Export.spawnEnemyGroupAt = function(centerPos, surface, enemyPhylum)
	U.printIfDebugAllOrSpawns("Spawning a swarm on " .. surface.name .. ": " .. math.floor(centerPos.x) .. "," .. math.floor(centerPos.y))
	local bugPos = surface.find_non_colliding_position("behemoth-biter", centerPos, CC.spawnPosTolerance, 0.1)
	if bugPos == nil then
		U.printIfDebug("Couldn't find a non-colliding position for bugs")
		return
	end
	local pollution = surface.get_pollution(centerPos)
	if pollution == 0 then
		U.printIfDebug("Pollution is zero, cannot spawn bugs")
		return
	end
	local bugsAndPollutionSpent = ChooseBugs.selectBugs(pollution, game.forces.enemy.get_evolution_factor(surface), surface.pollutant_type.name, enemyPhylum)
	local bugs = bugsAndPollutionSpent[1]
	local pollutionSpent = bugsAndPollutionSpent[2]
	local bugTypeToPollution = bugsAndPollutionSpent[3]
	if #bugs == 0 then
		U.printIfDebug("No bugs selected")
		return
	end
	U.printIfDebug("Selected "..#bugs.." bugs, total pollution spent: "..math.floor(pollutionSpent)..".")
	surface.pollute(centerPos, -pollutionSpent)
	logBugPollutionToStats(bugTypeToPollution, surface)
	local group = surface.create_unit_group{position = centerPos}
	for i = 1, #bugs do
		spawnEnemyAt(bugs[i], bugPos, group, surface)
	end
	group.set_autonomous()
end

return Export