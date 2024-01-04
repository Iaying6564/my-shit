local cubesize = ... and tonumber(...) or 3
local file = fs.open('pos' .. cubesize, 'r')
local rfile = fs.open('rpos' .. cubesize, 'r')

local directionsLookup = {
	['north'] = 0,
	['east'] = 1,
	['south'] = 2,
	['west'] = 3,
}

local found = true
local realPos = { { 0, 0, 0 }, 0 }
local simulator = { { 0, 0, 0 }, 0 }
local simulatorExpected = { { 0, 0, 0 }, 0 }
if file and rfile then
	print('recovery files found')
	file = file.readAll()
	rfile = rfile.readAll()
	found = false

	local parse = {}
	file:gsub('([^,]+)', function(k) table.insert(parse, tonumber(k)) end)
	simulatorExpected = { { parse[1], parse[2], parse[3] }, parse[4] }

	print('start condition: ' .. cubesize .. ',' .. parse[1] .. ',' .. parse[2] .. ',' .. parse[3] .. ',' .. parse[4])

	local parse = {}
	rfile:gsub('([^,]+)', function(k) table.insert(parse, tonumber(k)) end)
	realPos = { { parse[1], parse[2], parse[3] }, parse[4] }

	print('real condition: ' .. cubesize .. ',' .. parse[1] .. ',' .. parse[2] .. ',' .. parse[3] .. ',' .. parse[4])
elseif file or rfile then
	print('only 1 of 2 recovery files found, restart failed')
	return
end

local relativeVector = { -1, 0, 0 } -- it starts slightly 1 block behind where it mines
local relativeDirection = 0 -- forward
-- 0 = forward
-- 1 = right
-- 2 = backward
-- 3 = left

function updateRawPos()
	local file = fs.open('rpos' .. cubesize, 'w')
	file.write(relativeVector[1] .. ',' .. relativeVector[2] .. ',' .. relativeVector[3] .. ',' .. relativeDirection)
	file.close()
end

function proxy(callback, transformation)
	local function applyTransformation(vector, direction)
		vector[1] = vector[1] + (transformation[1] * ((-direction + 1) * ((direction + 1) % 2)))
		vector[2] = vector[2] + transformation[2]
		vector[3] = vector[3] + (transformation[1] * ((-direction + 2) * ((direction + 2) % 2)))

		direction = (direction + transformation[3]) % 4
		return direction
	end

	return function(...)
		if found then
			local result = { callback(...) }
			if result[1] then
				updateRawPos()
				relativeDirection = applyTransformation(relativeVector, relativeDirection)
			end

			return unpack(result)
		else
			simulator[2] = applyTransformation(simulator[1], simulator[2])
			return true
		end
	end
end

local forward = proxy(turtle.forward, { 1, 0, 0 })
local back = proxy(turtle.back, { -1, 0, 0 })
local up = proxy(turtle.up, { 0, 1, 0 })
local down = proxy(turtle.down, { 0, -1, 0 })
local left = proxy(turtle.turnLeft, { 0, 0, -1 })
local right = proxy(turtle.turnRight, { 0, 0, 1 })

function savePos()
	local saved = {}
	for i = 1, #relativeVector do
		saved[i] = relativeVector[i]
	end

	return { saved, relativeDirection }
end

function FUCKINGGRAVEL(isBack) -- FUCKING GRAVEL BLOCKING OUR WAY
	if isBack then
		left()
		left()
	end

	repeat
		turtle.dig()
	until forward() -- finally

	if relativeVector[2] > 0 then -- it fell down probably
		local originalY = relativeVector[2]
		while isGravel(turtle.inspectDown()) do
			turtle.digDown()
			down()
		end

		-- go back to original position
		for i = relativeVector[2], originalY - 1 do
			if not up() then
				repeat
					turtle.digUp() -- stupid bad tps and shit api lets us walk through gravel like jesus walks on water
				until up()
			end
		end

		-- fuck yeah no more gravel
	end

	if isBack then
		left()
		left()
	end
end

function chest()
	for i = relativeVector[2], 1, -1 do
		if not down() then
			local originalY = relativeVector[2]
			while isGravel(turtle.inspectDown()) do
				turtle.digDown()
				down()
			end

			for i = relativeVector[2], originalY - 1 do
				if not up() then
					repeat
						turtle.digUp()
					until up()
				end
			end
		end
	end

	local moveFunc = back
	if relativeDirection == 0 then
		right()
	elseif relativeDirection == 2 then
		left()
	elseif relativeDirection == 3 then
		moveFunc = forward
	end

	for i = relativeVector[3], 1, -1 do
		if not moveFunc() then
			FUCKINGGRAVEL(moveFunc == back)
		end
	end

	left()
	for i = relativeVector[1], 1, -1 do
		if not moveFunc() then
			FUCKINGGRAVEL(moveFunc == back)
		end
	end

	if moveFunc == back then
		left()
	else
		right()
	end
end

function back2pos(pos)
	local vector = pos[1]
	local dir = pos[2]

	local moveFunc = back
	if relativeDirection == 0 then
		moveFunc = forward
	elseif relativeDirection == 1 then
		right()
	elseif relativeDirection == 3 then
		left()
	end

	for i = relativeVector[1], vector[1] - 1 do
		if not moveFunc() then
			FUCKINGGRAVEL(moveFunc == back)
		end
	end

	if relativeDirection == 0 then
		left()
	else
		right()
	end

	for i = relativeVector[3], vector[3] - 1 do
		if not back() then
			FUCKINGGRAVEL(true)
		end
	end

	for i = relativeVector[2], vector[2] - 1 do
		if not up() then
			while isGravel(turtle.inspectUp()) do
				turtle.digUp()
				up()
			end

			for i = relativeVector[2], originalY + 1, -1 do
				if not down() then
					repeat
						turtle.digDown()
					until down()
				end
			end
		end
	end

	if dir ~= relativeDirection then
		local diff = (((dir - 1) % 4) + 1) - (((relativeDirection - 1) % 4) + 1)
		if math.abs(diff) > 1 then
			left()
			left()
		elseif diff < 0 then
			left()
		else
			right()
		end
	end
end

function deposit()
	local totalItems = 0
	repeat
		local totalItems = 0
		for i = 1, 16 do
			local count = turtle.getItemCount(i)
			if count > 0 then
				totalItems = totalItems + count
				turtle.select(i)
				turtle.refuel() -- if we can refuel we should
				turtle.drop()
			end
		end
	until totalItems == 0
end

function isGravel(exists, data)
	return exists and data.name == "minecraft:gravel"
end

function fullInventory() -- somehow this is the most effecient method
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then
			return false
		end
	end

	return true
end

function mineForward()
	if not forward() then
		turtle.dig()
		if not forward() then -- its fucking gravel
			FUCKINGGRAVEL()
		end

		if fullInventory() then
			local oldPos = savePos()
			chest()
			deposit()
			back2pos(oldPos)
		end
	end
end

function checkPos()
	local vector = simulator[1]
	local vectorExpected = simulatorExpected[1]
	if vector[1] == vectorExpected[1] and vector[2] == vectorExpected[2] and vector[3] == vectorExpected[3] and simulator[2] == simulatorExpected[2] then
		relativeVector = realPos[1]
		relativeDirection = realPos[2]

		while true do
			if not down() then
				if isGravel(turtle.inspectDown()) then
					local originalY = relativeVector[2]
					while isGravel(turtle.inspectDown()) do
						turtle.digDown()
						down()
					end

					for i = relativeVector[2], originalY - 1 do
						if not up() then
							repeat
								turtle.digUp()
							until up()
						end
					end
				else
					break
				end
			end
		end

		local moveFunc = back
		if relativeDirection == 0 then
			right()
		elseif relativeDirection == 2 then
			left()
		elseif relativeDirection == 3 then
			moveFunc = forward
		end

		while true do
			if not moveFunc() then
				if isGravel(turtle.inspect()) then
					FUCKINGGRAVEL(moveFunc == back)
				else
					break
				end
			end
		end

		local sinceLastChest = 0
		for i = relativeVector[1], 0, -1 do
			sinceLastChest = sinceLastChest + 1

			local exists, inspectData = turtle.inspect()
			if exists and inspectData.name:find('chest') then
				sinceLastChest = 0
			end

			left()
			if not moveFunc() and i > 0 then
				FUCKINGGRAVEL(moveFunc == back)
			end
			right()
		end

		left()
		local moveOtherFunc = moveFunc == back and forward or back
		for i = 1, sinceLastChest do
			moveOtherFunc()
		end

		relativeVector = { 0, 0, 0 }

		if moveFunc == back then
			left()
		else
			right()
		end

		found = true
	end
end

local forwardDirection = 0
function updatePos()
	local file = fs.open('pos' .. cubesize, 'w')
	file.write(forwardDirection .. ',' .. relativeVector[1] .. ',' .. relativeVector[2] .. ',' .. relativeVector[3] .. ',' .. relativeDirection)
	file.close()
end

function minePlane(isLast)
	for x2 = 1, cubesize - 1 do
		for x3 = 1, cubesize - 1 do
			if found then
				updatePos()
			else
				checkPos()
			end

			mineForward()
		end

		local turnFunc = x2 % 2 == 0 and left or right
		turnFunc()
		mineForward()
		turnFunc()
	end

	for x4 = 1, cubesize - 1 do
		if found then
			updatePos()
		else
			checkPos()
		end

		mineForward()
	end

	if not isLast then
		if not up() then
			turtle.digUp()
			up()
		end

		if cubesize % 2 == 0 then
			right()
		else
			left()
			left()
		end
	end
end

function checkDir(offset)
	local _, inspectData = turtle.inspect()
	local facing = inspectData.facing
	forwardDirection = (directionsLookup[facing] + offset) % 4
end

function ridExtraChest()
	right()
	mineForward()
	left()

	turtle.select(15)
	if not turtle.place() then
		repeat
			turtle.dig()
		until turtle.place()
	end
end

if found then
	left()
	if forward() then
		right()

		local exists, inspectData = turtle.inspect()
		local isChest = exists and inspectData.name:find('chest')
		if exists and inspectData.name:find('chest') then
			turtle.select(14)
			turtle.dig()
		end

		forward()
		right()
		forward()
		left()
		left()

		if isChest then
			turtle.place()
			ridExtraChest()

			checkDir(-1)
		else
			turtle.select(15)
			turtle.place()

			checkDir(-1)
		end

		right()
	else
		right()
		forward()
		left()

		local exists, inspectData = turtle.inspect()
		if exists and inspectData.name:find('chest') then
			turtle.select(14) -- empty slot
			turtle.dig() -- get chest
			turtle.place() -- reset direction

			ridExtraChest()

			checkDir(-1)
		else
			turtle.select(15)
			turtle.place()

			checkDir(-1)
		end

		right()
	end

	mineForward()
	left()
	deposit()
	right()
end

-- main
--[[
if file then
	left()
	left()

	back2pos({{ bx, by, bz }, bd})
end
]]

for x1 = 1, cubesize do
	minePlane(x1 == cubesize)
end

if found then
	-- return home (the place where I belong)
	chest()
else
	print('simulator failed to find expected route')
end
