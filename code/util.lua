local Util = {}

Util.randomPosInside = function(box)
	return {
		x = box.left_top.x + math.random() * (box.right_bottom.x - box.left_top.x),
		y = box.left_top.y + math.random() * (box.right_bottom.y - box.left_top.y),
	}
end

Util.getChunkPosAndArea = function(c)
	-- Turns a ChunkPosition into a ChunkPositionAndArea.
	return {x = c.x, y = c.y,
		area = {
			left_top = { x = c.x * 32, y = c.y * 32 },
			right_bottom = { x = (c.x + 1) * 32, y = (c.y + 1) * 32},
		}
	}
end

Util.randomBetween = function(a, b)
	return a + math.random() * (b - a)
end

Util.mapSetting = function(s)
	-- Fetch runtime-global setting
	local val = settings.global["BREAM-"..s].value
	return val
end

Util.debugPrint = function(s)
	-- Factorio suppresses duplicate prints, so I'm adding random numbers at the start to stop debug lines from being deleted as duplicate.
	-- It's stupid, but it works, and it's only for debugging.
	game.print(math.random(1000, 9999).." BREAM: "..s)
end

Util.printIfDebug = function(s)
	if Util.mapSetting("debug-printing") == "all" then
		Util.debugPrint(s)
	end
end

Util.printIfDebugAllOrSpawns = function(s)
	if Util.mapSetting("debug-printing") == "all" or Util.mapSetting("debug-printing") == "report-spawns" then
		Util.debugPrint(s)
	end
end

Util.boolStr = function(b)
	if (b) then return "TRUE" else return "FALSE" end
end

return Util