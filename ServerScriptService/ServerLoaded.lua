local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local isMapGenerated = false
local loadedPlayers = {}

SS.MapGenerated.Event:Connect(function()
	isMapGenerated = true
		
	if #loadedPlayers == #Players:GetChildren() then
		for i, plr in pairs(Players:GetChildren()) do
			RS.RemoveLoadingScreen:FireClient(plr)
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	RS.ShowLoadingScreen:FireClient(player)
	
	--This function only fires when the character has fully loaded into the game.
	player.CharacterAppearanceLoaded:Connect(function()
		table.insert(loadedPlayers, player)
		
		--Once all players have fully loaded and the map is generated, remove the loading screen.
		--Usually won't fire, unless the maze loads in before a player.
		if #loadedPlayers == #Players:GetChildren() and isMapGenerated then
			RS.RemoveLoadingScreen:FireClient(player)
		end
	end)
end)