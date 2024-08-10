--- Functions for choosing which bug classes and sizes to put in a swarm.
--- To add support for mods that create new enemy classes, add them here, specifically in the bugClassesData table.

local U = require("code/util")

-- Table mapping bug class name to a table with:
-- * fromMod: id of mod that added this bug class, so we only spawn bugs from mods that are enabled
-- * minEvolution: minimum evolution to start spawning this bug class
-- * sizes: table mapping unit-size id to list of {evolution factor, weight}.
--     The evolution factors and weights work the same way as base game's SpawnPointDefinition.
--     For example, biter size "small-biter" has spawn points {{0, .3}, {.6, 0}} for the spawn points.
--     This means, at evolution 0, small-biter has weight .3, and at evolution 60%, it has weight 0.
--     For evolution in between those, we linearly interpolate the weight.
--     Given current evolution value, we decide which bug classes to spawn, then use these weights to decide which sizes to spawn.
--  Note each size's spawn points must be ordered by first value (evolution factor).
local bugClassesData = {
	["biter"] = {
		fromMod = "base",
		minEvolution = 0,
		sizes = {
			-- These values are copied from the vanilla game's biter spawner prototype.
			["small-biter"] = { {0, .3}, {.6, 0} },
			["medium-biter"] = { {.2, 0}, {.6, .3}, {.7, .1} },
			["big-biter"] = { {.5, 0}, {1, .4} },
			["behemoth-biter"] = { {.9, 0}, {1, .3} },
		},
	},
	["spitter"] = {
		fromMod = "base",
		minEvolution = 0,
		sizes = {
			-- These values are copied from the vanilla game's spitter spawner prototype.
			-- At low evolution, we spawn biters even when spitter is the class chosen, as the vanilla spitter-spawner does.
			["small-biter"] = { {0, .3}, {.35, 0} },
			["small-spitter"] = { {.25, 0}, {.5, .3}, {.7, 0} },
			["medium-spitter"] = { {.4, 0}, {.7, .3}, {.9, .1} },
			["big-spitter"] = { {.5, 0}, {1, .4} },
			["behemoth-spitter"] = { {.9, 0}, {1, .3} },
		},
	},
	["armoured-biter"] = {
		fromMod = "ArmouredBiters",
		minEvolution = .05,
		sizes = {
			-- These values are copied from the values in the Armoured Biters mod.
			["small-armoured-biter"] = { {0, .225}, {.6, 0} },
			["medium-armoured-biter"] = { {.2, 0}, {.6, .225}, {.7, .075} },
			["big-armoured-biter"] = { {.5, 0}, {1, .3} },
			["behemoth-armoured-biter"] = { {.9, 0}, {1, .225} },
			["leviathan-armoured-biter"] = { {.965, 0}, {1, .03} },
		},
	},
	["toxic"] = {
		fromMod = "Toxic_biters",
		minEvolution = .1,
		sizes = {
			-- These values are copied from the values in the Toxic Biters mod.
			["small-toxic-biter"] = { {0, .3}, {.6, 0} },
			["medium-toxic-biter"] = { {.2, 0}, {.6, .3}, {.7, .1} },
			["big-toxic-biter"] = { {.5, 0}, {1, .4} },
			["behemoth-toxic-biter"] = { {.9, 0}, {1, .3} },
			["leviathan-toxic-biter"] = { {.965, 0}, {1, .03} },

			["small-toxic-spitter"] = { {.25, 0}, {.5, .3}, {.7, 0} },
			["medium-toxic-spitter"] = { {.4, 0}, {.7, .3}, {.9, .1} },
			["big-toxic-spitter"] = { {.5, 0}, {1, .4} },
			["behemoth-toxic-spitter"] = { {.9, 0}, {1, .3} },
			["leviathan-toxic-spitter"] = { {.965, 0}, {1, .03} },

			["mother-toxic-spitter"] = U.ifThenElse(
				settings.startup["tb-disable-mother"] and settings.startup["tb-disable-mother"].value,
				nil,
				{{0.98, 0.0}, {1.0, 0.02}}
			),
		},
	},
	["cold"] = {
		fromMod = "Cold_biters",
		minEvolution = .1,
		sizes = {
			-- These values are copied from the values in the Cold Biters mod.
			["small-cold-biter"] = { {0, .3}, {.6, 0} },
			["medium-cold-biter"] = { {.2, 0}, {.6, .3}, {.7, .1} },
			["big-cold-biter"] = { {.5, 0}, {1, .4} },
			["behemoth-cold-biter"] = { {.9, 0}, {1, .3} },
			["leviathan-cold-biter"] = { {.965, 0}, {1, .03} },

			["small-cold-spitter"] = { {.25, 0}, {.5, .3}, {.7, 0} },
			["medium-cold-spitter"] = { {.4, 0}, {.7, .3}, {.9, .1} },
			["big-cold-spitter"] = { {.5, 0}, {1, .4} },
			["behemoth-cold-spitter"] = { {.9, 0}, {1, .3} },
			["leviathan-cold-spitter"] = { {.965, 0}, {1, .03} },

			["mother-cold-spitter"] = U.ifThenElse(
				settings.startup["cb-disable-mother"] and settings.startup["cb-disable-mother"].value,
				nil,
				{{0.98, 0.0}, {1.0, 0.02}}
			),
		},
	},
	["explosive"] = {
		fromMod = "Explosive_biters",
		minEvolution = .1,
		sizes = {
			-- These values are copied from the values in the Explosive Biters mod.
			["small-explosive-biter"] = { {0, .3}, {.6, 0} },
			["medium-explosive-biter"] = { {.2, 0}, {.6, .3}, {.7, .1} },
			["big-explosive-biter"] = { {.5, 0}, {1, .4} },
			["behemoth-explosive-biter"] = { {.9, 0}, {1, .3} },
			-- ["leviathan-explosive-biter"] -- Does not exist.

			["small-explosive-spitter"] = { {.25, 0}, {.5, .3}, {.7, 0} },
			["medium-explosive-spitter"] = { {.4, 0}, {.7, .3}, {.9, .1} },
			["big-explosive-spitter"] = { {.5, 0}, {1, .4} },
			["behemoth-explosive-spitter"] = { {.9, 0}, {1, .3} },
			["leviathan-explosive-spitter"] = { {.965, 0}, {1, .03} },

			["mother-explosive-spitter"] = U.ifThenElse(
				settings.startup["eb-disable-mother"] and settings.startup["eb-disable-mother"].value,
				nil,
				{{0.98, 0.0}, {1.0, 0.02}}
			),
		},
	},
}

local function getPossibleBugClasses(evolutionFactor)
	-- Makes a list of all bug classes that can be spawned at current evolution level and with currently installed mods.
	local classes = {}
	for bugClassName, bugClassData in pairs(bugClassesData) do
		if game.active_mods[bugClassData.fromMod] ~= nil and bugClassData.minEvolution <= evolutionFactor then
			table.insert(classes, bugClassName)
		end
	end
	return classes
end

local function selectBugClasses(evolutionFactor)
	-- Makes a list of bug classes to spawn, which is a subset of the list of possible bug classes.
	local classes = {}
	local possibleClasses = getPossibleBugClasses(evolutionFactor)
	if #possibleClasses == 0 then return {} end
	if #possibleClasses == 1 then return possibleClasses end

	-- Always choose at least 1 bug class to include.
	local guaranteedBugClass = possibleClasses[math.random(#possibleClasses)]
	table.insert(classes, guaranteedBugClass)

	-- Then add each additional bug class with some probability.
	for _, class in pairs(possibleClasses) do
		if class ~= guaranteedBugClass then
			if math.random() < U.mapSetting("extra-bug-class-chance") then
				table.insert(classes, class)
			end
		end
	end

	return classes
end

local function getBugClassSizeWeights(bugClass, evolutionFactor)
	-- Given bug class and current evolution, returns a map from size id to probability weight.
	-- These weights are normalized to sum to 1.
	-- So, it looks up the spawn points and linearly interpolates, etc.
	local bugClassData = bugClassesData[bugClass]
	local results = {}
	for sizeId, spawnPoints in pairs(bugClassData.sizes) do
		if spawnPoints[1][1] > evolutionFactor then
			results[sizeId] = spawnPoints[1][2]
		elseif spawnPoints[#spawnPoints][1] <= evolutionFactor then
			results[sizeId] = spawnPoints[#spawnPoints][2]
		else
			-- If we're not completely on one side of all spawn points, we need to linearly interpolate.
			for leftIdx = 1, #spawnPoints - 1 do
				local rightIdx = leftIdx + 1
				if spawnPoints[leftIdx][1] <= evolutionFactor and spawnPoints[rightIdx][1] > evolutionFactor then
					local interpolationFactor = (evolutionFactor - spawnPoints[leftIdx][1]) / (spawnPoints[rightIdx][1] - spawnPoints[leftIdx][1])
					results[sizeId] = spawnPoints[leftIdx][2] * (1.0 - interpolationFactor) + spawnPoints[rightIdx][2] * interpolationFactor
					break
				end
			end
		end
	end

	-- Normalize to sum to 1.
	local sum = 0
	for _, weight in pairs(results) do
		sum = sum + weight
	end
	for sizeId, weight in pairs(results) do
		results[sizeId] = weight / sum
	end
	return results
end

local function pollutionForBug(bugName)
	if game.entity_prototypes[bugName] == nil or game.entity_prototypes[bugName].pollution_to_join_attack == nil then
		log("Error: bug "..bugName.." has no prototype or no pollution_to_join_attack")
		return 1000000
	end
	return game.entity_prototypes[bugName].pollution_to_join_attack * U.mapSetting("pollution-cost-multiplier")
end

local function getPollutionBudget(pollutionInChunk)
	-- Given pollution in chunk, returns the pollution budget for this swarm.
	local pollutionFraction = U.randomBetween(
		U.mapSetting("pollution-fraction-per-swarm-min"),
		U.mapSetting("pollution-fraction-per-swarm-max"))
	return pollutionInChunk * pollutionFraction
end

local selectBugSize = function(bugClassSizeWeights)
	-- Given the result of getBugClassSizeWeights, returns id of bug to spawn, selected according to weights.
	local r = math.random()
	for sizeId, weight in pairs(bugClassSizeWeights) do
		r = r - weight
		if r <= 0 then
			return sizeId
		end
	end

	log("Error: could not select from bug size weights: "..serpent.line(bugClassSizeWeights))
	for sizeId, _ in pairs(bugClassSizeWeights) do
		return sizeId
	end
end

local selectBugs = function(pollutionInChunk, evolutionFactor)
	-- Given pollution in chunk and current evolution, returns a list of bug ids to spawn, the total pollution spent, and a map from bug id to pollution spent (for stats panel).
	local bugClassSubset = selectBugClasses(evolutionFactor)
	if #bugClassSubset == 0 then
		log("Error: empty bug class subset")
		return {{}, 0, {}}
	end
	U.printIfDebug("Selected bug classes: "..serpent.line(bugClassSubset))

	local classSizeWeights = {} -- Map from bug class name to (map from size id to weight).
	for _, bugClass in pairs(bugClassSubset) do
		classSizeWeights[bugClass] = getBugClassSizeWeights(bugClass, evolutionFactor)
	end

	local pollutionBudget = getPollutionBudget(pollutionInChunk)
	U.printIfDebug("Pollution budget is "..math.floor(pollutionBudget).." for a chunk with pollution "..math.floor(pollutionInChunk)..".")

	local pollutionSpent = 0.0
	local bugs = {}
	local bugIdToPollution = {}

	for _ = 1, U.mapSetting("max-bugs-per-swarm") do
		local bugClass = bugClassSubset[math.random(#bugClassSubset)]
		local bugSize = selectBugSize(classSizeWeights[bugClass])
		local pollutionForThisBug = pollutionForBug(bugSize)
		if (pollutionSpent + pollutionForThisBug) > pollutionBudget then
			U.printIfDebug("Couldn't afford next bug "..bugSize.." for "..pollutionForThisBug.." pollution.")
			break
		end
		bugIdToPollution[bugSize] = (bugIdToPollution[bugSize] or 0) + pollutionForThisBug
		pollutionSpent = pollutionSpent + pollutionForThisBug
		U.printIfDebug("Bought "..bugSize.." for "..pollutionForThisBug.." pollution, remaining budget: "..math.floor(pollutionBudget-pollutionSpent))
		table.insert(bugs, bugSize)
	end

	if #bugs > 0 then
		if U.mapSetting("debug-printing") == "all" then
			U.debugPrint("Purchased a swarm of "..#bugs.." bugs for "..math.floor(pollutionSpent).." pollution.")
		elseif U.mapSetting("debug-printing") == "report-spawns" then
			U.debugPrint("Spawned "..#bugs.." bugs.")
		end
	else
		U.printIfDebug("Couldn't afford any bugs :(") -- Happens sometimes in low-pollution chunks with high evolution.
	end
	return {bugs, pollutionSpent, bugIdToPollution}
end

return {
	selectBugs = selectBugs,
}