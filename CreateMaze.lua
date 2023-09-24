--[[This script makes a procedurally generated maze.
Should be run before the player spawns/can see the map.]]

-->>:Variables
local SS = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local sizeX = SS.MazeSizeX.Value --Must be an even number
local sizeY = SS.MazeSizeY.Value
local height = SS.Path.Wall.Size.Y
local pathSize = SS.Path.Wall_F.Size.X + (SS.Path.Corner.Size.X*2)

local start = Vector3.new(0, height/2, 0)--Floor level position of the center of the maze.

local locX = -sizeX*pathSize/2 --Finds a starting position that will center the maze around spawn.
local locY = -sizeY*pathSize/2

local unusedT = {} --Table that holds all points not in the completed map.
local nNumT = {} --Table that holds the path being created.
local nPosT = {}
local mazeT = {} --Table that holds the completed map.
local pathT = {} --Table that holds all of the path pieces using mazeT.

-->>:Functions

--[[]]
function createPath(mazeConnection)
	local prev = mazeConnection
	--Working backwards from the maze, insert new pieces into the maze and delete them from the unused.
	for i = #nNumT, 1, -1 do
		--Create the path piece and place it in the world.
		local p = SS.Path:Clone()
		p:SetPrimaryPartCFrame(CFrame.new(nPosT[i]))
		p.Parent = workspace.Maze
		
		--Raycast between the current path piece and the previous.
		--This boolean stops the loop if walls have been deleted between the two paths.
		local isThereWalls = true
		while isThereWalls do
			local raycastResult = workspace:Raycast(prev, nPosT[i]-prev)
			if raycastResult and raycastResult.Distance < pathSize then
				raycastResult.Instance:Destroy()
			else
				isThereWalls = false
			end
		end
		
		prev = nPosT[i]
		
		table.insert(mazeT, nPosT[i])
		table.remove(unusedT, table.find(unusedT, nPosT[i]))
		table.remove(nNumT, i)
		table.remove(nPosT, i)
	end
	--After all positions have been added, check and see if there are more positions in unused.
	--If there are, generate a new point from unused.
	if #unusedT > 0 then
		table.insert(nNumT, math.random(#unusedT))
		table.insert(nPosT, unusedT[nNumT[1]])
	end
end

-->>:Code

--Add all points in the maze, based on pathSize and sizeX and sizeY.
for x = 0, sizeX do
	for y = 0, sizeY do
		table.insert(unusedT, Vector3.new((pathSize*x)+locX+start.X, height/2, (pathSize*y)+locY+start.Z))
	end
end

--Remove the start (spawn) location from the unused, and add it to the maze.
local rem = table.find(unusedT, start)
table.remove(unusedT, rem)
table.insert(mazeT, start)

--Find a random unused, and start the new path with it.
table.insert(nNumT, math.random(#unusedT))
table.insert(nPosT, unusedT[nNumT[#nNumT]])

while #unusedT > 0 do
	--Use a random number to find a direction to move in.
	local rand = math.random(4)
	--This will hold the new position value, to check if it is valid before adding it to the path.
	local neighbor
	
	--Determines which direction to move in, moving by pathSize.
	if rand == 1 then
		-- +X
		neighbor = nPosT[#nPosT]+Vector3.new(pathSize, 0, 0)
	elseif rand == 2 then
		-- -X
		neighbor = nPosT[#nPosT]+Vector3.new(-pathSize, 0, 0)
	elseif rand == 3 then
		-- +Z
		neighbor = nPosT[#nPosT]+Vector3.new(0, 0, pathSize)
	elseif rand == 4 then
		-- -Z
		neighbor = nPosT[#nPosT]+Vector3.new(0, 0, -pathSize)
	end
	
	--Determines if the neighbor is:
	--already a part of the new path, and therefore should delete everything in this newly created loop.
	--a new location, and should be added to the new path.
	--part of the maze, and the new path should all be added to the maze.
	--out of the maze parameters, and the program should find another direction to move in.
	if table.find(nPosT, neighbor) then
		--For everything between the last recorded position and the refound point (the entire loop), delete them from the table.
		for i = #nPosT, table.find(nPosT, neighbor)+1, -1 do
			table.remove(nNumT, i)
			table.remove(nPosT, i)
		end
	elseif table.find(unusedT, neighbor) then
		table.insert(nNumT, table.find(unusedT, neighbor))
		table.insert(nPosT, neighbor)
	elseif table.find(mazeT, neighbor) then
		createPath(neighbor)
	else
		--Out of bounds needs to run again to find a new direction, no additional code is needed.
	end
	wait()
end

--Create the exit for the maze.
local endPos = start+Vector3.new(0, 0, sizeY*pathSize/2 + pathSize)
local raycastResult = workspace:Raycast(endPos, Vector3.new(0, 0, -pathSize))
raycastResult.Instance:Destroy()

--Add a block to act as the finish line.
local endBlock = SS.EndBlock:Clone()
endBlock.Size = Vector3.new(pathSize, height, pathSize)
endBlock.Position = endPos
endBlock.Parent = workspace.Maze

--Add a ceiling the size of the maze.
--local ceiling = Instance.new("Part")
--ceiling.Name = "Ceiling"
--ceiling.Size = Vector3.new((sizeX+1)*pathSize, 1, (sizeY+1)*pathSize)
--ceiling.Position = Vector3.new(start.X, height+.5, start.Z)
--ceiling.Anchored = true
--ceiling.Parent = workspace.Maze

SS.MapGenerated:Fire()