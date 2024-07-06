local C = require("code/constants")

local function makeTypeMilitaryTarget(typeName)
	for _, entity in pairs(data.raw[typeName]) do
		entity.is_military_target = true
	end
end

for category, types in pairs(C.safetyCategoryToTypes) do
	if settings.startup["BREAM-safety-"..category].value == "military-target" then
		for typeName, _ in pairs(types) do
			makeTypeMilitaryTarget(typeName)
		end
	end
end

for category, specialEnts in pairs(C.safetyCategoryToSpecial) do
    if settings.startup["BREAM-safety-"..category].value == "military-target" then
		for typeName, entityNameSet in pairs(specialEnts) do
			for entityName, _ in pairs(entityNameSet) do
				if data.raw[typeName][entityName] ~= nil then
					data.raw[typeName][entityName].is_military_target = true
				end
			end
        end
    end
end