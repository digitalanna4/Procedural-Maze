local SS = game:GetService("ServerStorage")
local folder = SS:WaitForChild("Games"):WaitForChild("Maze")
local pathPiece = folder:WaitForChild("Path")
local eventLoaded = SS:WaitForChild("GameLoaded")

--Client side
local RS = game:GetService("ReplicatedStorage")
local eventNotif = RS:WaitForChild("SendNotificationsToClients")

--Game
local map = script.Parent --Stores everything needed for the map. Easy clean up with :Destroy() 
local size = Vector2.new(map:WaitForChild("MazeSize").Value.X, map.MazeSize.Value.Z)
local pathSize = map.MazeSize.Value.Y
local height = pathPiece:WaitForChild("Wall_F").Size.Y
local winCollision = SS:WaitForChild("WinCollision")

--Local
local location = Vector3.new(0, 0, 0)
local MAZEARRAY = {} --Don't @ me on casing, its basically a constant.
local unusedPoints = {}
local completedPoints = {}
local createdIndex = {} --Keeps track of the correlation between createdPoints and unusedPoints.
local createdPoints = {}
local invalidDir = {}

--Code - runs when the Maze is spawned.

delay(3, function()
	eventNotif:FireAllClients("Generating Maze...", "title")
end)

--Create an array of the maze, with the distance between points equaling the size of the path model.
for x = 0-size.X/2, size.X/2 do
	for z = 0-size.Y/2, size.Y/2 do
		table.insert(MAZEARRAY, location + Vector3.new(pathSize*x, height/2, pathSize*z))
	end
end
for _, d in pairs(MAZEARRAY) do
	table.insert(unusedPoints, d)
end

--Start at the center of the maze.
local startIndex = math.round(#unusedPoints/2)
local startLocation = unusedPoints[startIndex]

table.remove(unusedPoints, startIndex)
table.insert(completedPoints, startLocation)

--Keep creating paths until there are no more points.
while #unusedPoints > 0 do
	--Create a random start point using an unused point.
	local r = math.random(#unusedPoints)
	table.insert(createdPoints, unusedPoints[r])

	local point --Represents the newest point created that attaches to the end of createdPoints. Could be accepted or not.

	while not table.find(completedPoints, point) do
		--Choose a random direction to try to find a point in.
		local direction = math.random(4)
		if direction == 1 then
			--X-
			point = createdPoints[#createdPoints] + Vector3.new(-pathSize, 0, 0)
		elseif direction == 2 then
			--Z+
			point = createdPoints[#createdPoints] + Vector3.new(0, 0, pathSize)
		elseif direction == 3 then
			--Z-
			point = createdPoints[#createdPoints] + Vector3.new(0, 0, -pathSize)
		elseif direction == 4 then
			--X+
			point = createdPoints[#createdPoints] + Vector3.new(pathSize, 0, 0)
		end
		--Determine if this point should be added
		if table.find(createdPoints, point) then --Point is part of the path being created, meaning it has looped over itself.
			local i = table.find(createdPoints, point)
			for d = #createdPoints, i+1, -1 do --Remove points in reverse order.
				table.remove(createdPoints, d)
			end
			
		elseif table.find(unusedPoints, point) then --Point is unused and should be added.
			table.insert(createdPoints, point)
			invalidDir = {direction}
		elseif not table.find(MAZEARRAY, point) then 
			--Outside the bounds of the maze, in which case we want to put a note to not test that direction again.
			table.insert(invalidDir, direction)
		end

		wait()
	end
	--Add the new path to the completedPoints
	for i = #createdPoints, 1, -1 do
		local p = pathPiece:Clone()
		p:SetPrimaryPartCFrame(CFrame.new(createdPoints[i]))
		p.Parent = map

		--Raycast to remove walls
		local isThereWalls = true
		while isThereWalls do
			local raycastResult = workspace:Raycast(point, createdPoints[i]-point)
			if raycastResult and raycastResult.Distance < pathSize then
				raycastResult.Instance:Destroy()
			else
				isThereWalls = false
			end
		end

		point = createdPoints[i] --Used here to give a location for the raycast.

		table.insert(completedPoints, createdPoints[i])
		table.remove(unusedPoints, table.find(unusedPoints, createdPoints[i]))
		table.remove(createdPoints, i)
	end
	local percent = math.round(#completedPoints/#MAZEARRAY*100)
	if percent == 100 then
		percent = 99
	end
	eventNotif:FireAllClients(percent.."%", "timer")
	wait()
end

--Create an exit on a random side of the maze.
local r = math.random(4)
local l, d
if r == 1 then
	l = location+Vector3.new(0, height/2, (size.Y*pathSize/2)+pathSize)
	d = Vector3.new(0,0,-pathSize)
elseif r == 2 then
	l = location-Vector3.new(0, -height/2, (size.Y*pathSize/2)+pathSize)
	d = Vector3.new(0,0,pathSize)
elseif r == 3 then
	l = location+Vector3.new((size.X*pathSize/2)+pathSize, height/2, 0)
	d = Vector3.new(-pathSize,0,0)
elseif r == 4 then
	l = location-Vector3.new((size.X*pathSize/2)+pathSize, -height/2, 0)
	d = Vector3.new(pathSize,0,0)
end

local raycastResult = workspace:Raycast(l, d)
if raycastResult and raycastResult.Distance < pathSize then
	raycastResult.Instance:Destroy()
end

local exit = winCollision:Clone()
exit.Size = Vector3.new(pathSize, height, pathSize)
exit.Position = l
exit.Parent = map

eventLoaded:Fire()

