local C = require("code/constants")

local toMakeSafe = {} -- Maps typeName to either true (for everything of that type) or a set of entity names, to make safe when built.
for category, types in pairs(C.safetyCategoryToTypes) do
	if settings.startup["BREAM-safety-"..category].value == "safe" then
		for typeName, _ in pairs(types) do
			toMakeSafe[typeName] = true
		end
	end
end
for category, specialEnts in pairs(C.safetyCategoryToSpecial) do
	if settings.startup["BREAM-safety-"..category].value == "safe" then
		for typeName, entNameSet in pairs(specialEnts) do
			if toMakeSafe[typeName] == nil then
				toMakeSafe[typeName] = entNameSet
			end
		end
	end
end

local eventFilters = {}
for eventFilterType, _ in pairs(toMakeSafe) do
	table.insert(eventFilters, {filter = "type", type = eventFilterType})
end

local function onBuilt(event)
	local entity = event.created_entity
	local safeSet = toMakeSafe[entity.type]
	if safeSet ~= nil then
		if safeSet == true or safeSet[entity.name] then
			entity.destructible = false
		end
	end
end

local Export = {}
Export.registerHandlers = function()
	script.on_event(defines.events.on_built_entity, onBuilt, eventFilters)
	script.on_event(defines.events.on_robot_built_entity, onBuilt, eventFilters)
end
return Export