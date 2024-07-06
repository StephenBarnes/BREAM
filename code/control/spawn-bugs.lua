--- FUNCTIONS FOR SPAWNING ENEMY GROUPS

local U = require("code/util")
local CC = require("code/control/control-constants")
local ChooseBugs = require("code/control/choose-bugs")

local Export = {}

local function spawnEnemyAt(bugName, pos, group, surface)
	local bug = surface.create_entity{name = bugName, position = pos}
	bug.ai_settings.allow_try_return_to_spawner = false
	group.add_member(bug)
end

local function logBugPollutionToStats(bugTypeToPollution)
	for bugType, pollution in pairs(bugTypeToPollution) do
		game.pollution_statistics.on_flow(bugType, -pollution)
	end
end

Export.spawnEnemyGroupAt = function(centerPos, surface)
	U.printIfDebug("Spawning a swarm at " .. math.floor(centerPos.x) .. "," .. math.floor(centerPos.y))
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
	local bugsAndPollutionSpent = ChooseBugs.selectBugs(pollution, game.forces.enemy.evolution_factor)
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

return Export