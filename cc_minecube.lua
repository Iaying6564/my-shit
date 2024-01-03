local cubesize = ... and tonumber(...) or 3
local file = fs.open('pos' .. cubesize, 'r')
local bx, by, bz, bd = 0, 0, 0, 0
if file then
	print('recovery file found')
	file = file.readAll()

	local parse = file.split(',')
	bx, by, bz, bd = tonumber(parse[1]), tonumber(parse[2]), tonumber(parse[3])
	print('start condition: ' .. cubesize .. ',' .. parse)
end

local relativeVector = { -1, 0, 0 } -- it starts slightly 1 block behind where it mines
local relativeDirection = 0 -- forward
-- 0 = forward
-- 1 = right
-- 2 = backward
-- 3 = left

function proxy(callback, transformation)
	return function(...)
		local result = { callback(...) }
		if result[1] then
			relativeVector[1] = relativeVector[1] + (transformation[1] * ((-relativeDirection + 1) * ((relativeDirection + 1) % 2)))
			relativeVector[2] = relativeVector[2] + transformation[2]
			relativeVector[3] = relativeVector[3] + (transformation[1] * ((-relativeDirection + 2) * ((relativeDirection + 2) % 2)))

			relativeDirection = (relativeDirection + transformation[3]) % 4
		end

		return unpack(result)
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
		turnLeft()
		turnLeft()
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
		turnLeft()
		turnLeft()
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
	local direction = relativeDirection
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
	if relativeDirection == 1 then
		right()
	elseif relativeDirection == 2 then
		moveFunc = forward
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

function updatePos(x, y, z, d)
	local file = fs.open('pos' .. cubesize, 'w')
	file.write(x .. ',' .. y .. ',' .. z .. ',' .. d)
	file.close()
end

function minePlane(plane, isLast)
	for x2 = 1, cubesize - 1 do
		for x3 = 1, cubesize - 1 do
			mineForward()
		end

		local planeVal = plane % 2 == 0
		local turnFunc = x2 % 2 == 0 and (planeVal and left or right) or (planeVal and right or left)
		turnFunc()
		mineForward()
		turnFunc()
	end

	for x4 = 1, cubesize - 1 do
		mineForward()
	end

	if not isLast then
		if not up() then
			turtle.digUp()
			up()
		end

		left()
		left()
	end
end

mineForward()
left()
deposit()
right()

-- main
if file then
	back2pos({ bx, by, bz }, bd)
end

for x1 = by + 1, cubesize do
	minePlane(x1, x1 == cubesize)
end

-- return home (the place where I belong)
chest()
