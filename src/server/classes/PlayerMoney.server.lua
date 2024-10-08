local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PyScript = require(ReplicatedStorage.PyClass)

PyScript:new("PlayerMoney", {
	__init__ = function(self, money: number)
		self.defaultMoney = money
		self.Players = {}

		return self
	end,

	add_player = function(self, player: Player)
		print(self.defaultMoney)
		self.Players[player] = self.defaultMoney
	end,

	give = function(self, player: Player, target: Player, give: number)
		if target == player then return end
		if not self.Players[target] or not self.Players[player] then return end

		print(self.Players[player])
		if self.Players[player] < give then return end

		self.Players[player] -= give
		self.Players[target] += give

		print(`Added {give} Cash to {target.Name}!`)
	end,
})
