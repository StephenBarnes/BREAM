--- FUNCTIONS FOR CHOOSING WHICH BUG TYPES AND SIZES TO PUT IN A SWARM.
--- TO ADD SUPPORT FOR MODS THAT CREATE NEW ENEMY TYPES, ADD THEM HERE.
--- TODO If you add compat for more enemy mods, you should add a way to specify minimum evolution for each bug class, so that eg Rampant's new enemy types only start appearing at a certain evolution level.

local U = require("code/util")

local Export = {}

local function getBugClasses()
	local bugClasses = {"biter", "spitter"}
	-- Include enemies from Armoured Biters mod
	if game.entity_prototypes["small-armoured-biter"] ~= nil then
		table.insert(bugClasses, "armoured-biter")
	end
	return bugClasses
end

local bugClassToSizes = {
	biter = {"small", "small", "medium", "big", "behemoth"},
	spitter = {"small", "small", "medium", "big", "behemoth"},
	["armoured-biter"] = {"small", "small", "medium", "big", "behemoth", "leviathan"},
	-- NOTE The chosen size is linear in evolution, over these lists; for example biters will be small or medium if evolution is between 0 and 0.33, between medium and big if evolution is 0.33 to 0.67, etc.
	-- The "small" size is repeated so that all bugs spawned under ~20% evolution are small.
	-- This mod currently chooses sizes in different ratios than the ones in vanilla.
}
local function getBugSize(bugClass, evolutionFactor)
	-- Instead of choosing size like the bug nests do, I'll instead just make it linear.
	local numSizes = #(bugClassToSizes[bugClass])
	local minSizeIdx = math.floor(evolutionFactor * (numSizes - 1)) + 1
	local maxSizeIdx = minSizeIdx + 1
	if maxSizeIdx > numSizes then return bugClassToSizes[bugClass][minSizeIdx] end
	if (bugClassToSizes[bugClass][minSizeIdx] == bugClassToSizes[bugClass][maxSizeIdx]) then
		return bugClassToSizes[bugClass][minSizeIdx]
	end
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

local function pollutionForBug(bugName)
	return game.entity_prototypes[bugName].pollution_to_join_attack * U.mapSetting("pollution-cost-multiplier")
end

Export.selectBugs = function(pollutionInChunk, evolutionFactor)
	local bugClasses = getBugClasses()
	local bugClassSubset = {} -- Subset of bug classes to use for this swarm.
	-- Always choose at least 1 bug class to include.
	guaranteedBugClass = bugClasses[math.random(#bugClasses)]
	table.insert(bugClassSubset, guaranteedBugClass)
	-- Then add each additional bug class with some probability.
	for i, class in pairs(bugClasses) do
		if class ~= guaranteedBugClass then
			if math.random() < U.mapSetting("extra-bug-class-chance") then
				table.insert(bugClassSubset, class)
			end
		end
	end

	local pollutionFraction = U.randomBetween(U.mapSetting("pollution-fraction-per-swarm-min"), U.mapSetting("pollution-fraction-per-swarm-max"))
	local pollutionBudget = pollutionInChunk * pollutionFraction
	U.printIfDebug("Pollution budget is "..math.floor(pollutionBudget).." for a chunk with pollution "..math.floor(pollutionInChunk)..".")
	local pollutionSpent = 0.0
	local bugs = {}
	local bugTypeToPollution = {}
	for _ = 1, U.mapSetting("max-bugs-per-swarm") do
		local bugClass = bugClassSubset[math.random(#bugClassSubset)]
		local bugSize = getBugSize(bugClass, evolutionFactor)
		local bugName = bugSize .. "-" .. bugClass
		local pollutionForThisBug = pollutionForBug(bugName)
		if (pollutionSpent + pollutionForThisBug) > pollutionBudget then
			U.printIfDebug("Couldn't afford next bug "..bugName.." for "..pollutionForThisBug.." pollution.")
			break
		end
		bugTypeToPollution[bugName] = (bugTypeToPollution[bugName] or 0) + pollutionForThisBug
		pollutionSpent = pollutionSpent + pollutionForThisBug
		U.printIfDebug("Bought "..bugName.." for "..pollutionForThisBug.." pollution, remaining budget: "..math.floor(pollutionBudget-pollutionSpent))
		table.insert(bugs, bugName)
	end
	if #bugs > 0 then
		U.printIfDebug("Purchased a swarm of "..#bugs.." bugs for "..math.floor(pollutionSpent).." pollution.")
	else
		U.printIfDebug("Couldn't afford any bugs :(") -- Happens sometimes in low-pollution chunks with high evolution.
	end
	return {bugs, pollutionSpent, bugTypeToPollution}
end

return Export