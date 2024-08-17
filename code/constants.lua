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
	["large-power-poles"] = {},
	["nonlarge-power-poles"] = {},
	["railways"] = listToSet{"straight-rail", "curved-rail"},
	["rail-signals"] = listToSet{"rail-signal", "rail-chain-signal"},
}
Export.safetyCategoryToSpecial = { -- Entities that belong in these safety categories, but we're not including the entire type.
	["lamps"] = {
		["assembling-machine"] = listToSet{"deadlock-copper-lamp", "copper-aetheric-lamp-straight", "copper-aetheric-lamp-end"},
	},
	["large-power-poles"] = {
		["electric-pole"] = listToSet{"big-electric-pole"},
	},
	["nonlarge-power-poles"] = {
		["electric-pole"] = listToSet {
			"small-electric-pole", "medium-electric-pole", "substation", -- vanilla
			"big-wooden-pole", "small-iron-pole", "small-bronze-pole", -- IR3
		},
	},
}

return Export