local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local PyScript = require(ReplicatedStorage.PyScript)

local Cash = PyScript:import("PlayerMoney", 400)
local killAll = PyScript:import("KillAll")

for _, Player in Players:GetPlayers() do
	Cash.add_player(Player)
end

Players.PlayerAdded:Connect(function(Player: Player)
	Cash.add_player(Player)
end)

local Test: TextChatCommand = TextChatService.Test

Test.Triggered:Connect(function(Source: TextSource, Message: string)
	local Content = Message:split(" ")
	if not Content[2] then return end

	local Money = tonumber(Content[3]) or 200

	local Target = Players:FindFirstChild(Content[2])
	local Player = Players:FindFirstChild(Source.Name)

	if not Target or not Player then return end
	Cash.give(Player, Target, Money)
end)

MarketplaceService.ProcessReceipt = function(Receipt: { [string]: any })
	for _, player in Players:GetPlayers() do
		print(player.Name)
		killAll.add_player(player)
	end

	killAll.apply()
end
