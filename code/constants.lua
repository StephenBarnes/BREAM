local Export = {}

local function listToSet(l)
	-- Convert a list to a table with those list elements mapping to true. So that we can quickly check membership.
	local set = {}
	for _, v in pairs(l) do
		set[v] = true
	end
	return set
end

Export.safetyCategoryToTypes = { -- Types of entities controlled by the safety settings.
	["lamps"] = listToSet{"lamp"},
	["power-poles"] = listToSet{"electric-pole"},
	["railways"] = listToSet{
		"straight-rail",
		"curved-rail", -- I think this still exists if you load a game from before 2.0.
		"curved-rail-a",
		"curved-rail-b",
		"half-diagonal-rail",
		"rail-ramp",
		"rail-support",
		"elevated-straight-rail",
		"elevated-curved-rail",
		"elevated-curved-rail-a",
		"elevated-curved-rail-b",
		"elevated-half-diagonal-rail",
	},
	["rail-signals"] = listToSet{"rail-signal", "rail-chain-signal"},
}
Export.safetyCategoryToSpecial = { -- Entities that belong in these safety categories, but are not in the expected type.
	["lamps"] = {
		--["assembling-machine"] = listToSet{"deadlock-copper-lamp", "copper-aetheric-lamp-straight", "copper-aetheric-lamp-end"},
	},
}

return Export