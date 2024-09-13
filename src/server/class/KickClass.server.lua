local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PyScript = require(ReplicatedStorage.PyScript)

PyScript:new("KillAll", {
	__init__ = function(self)
		self.productId = 01939301
		self.toKill = {}

		return self
	end,

	add_player = function(self, player: Player)
		self.toKill[player] = player
		return self
	end,

	apply = function(self)
		print(self.toKill)
		for _, player: Player in self.toKill do
			local char = player.Character
			if not char then continue end

			local humanoid = char:FindFirstChild("Humanoid")
			if not humanoid then continue end

			humanoid:TakeDamage(math.huge)
		end
	end,
})
