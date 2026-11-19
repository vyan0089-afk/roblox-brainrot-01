-- init.server: bootstrap for Warung Brainrot Bazaar.
-- Spawns every player with a base, hands them starting cash, and keeps
-- the server's single StateStore as the only source of truth.
-- The other server scripts each own one job (conveyor, economy, steal,
-- hazards, progression); this one only wires players in and out.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StateUpdate = Remotes:WaitForChild("StateUpdate")

local BASE_POSITIONS = {
	Vector3.new(-80, 1, 70),
	Vector3.new(-27, 1, 70),
	Vector3.new(27, 1, 70),
	Vector3.new(80, 1, 70),
	Vector3.new(-80, 1, -70),
	Vector3.new(-27, 1, -70),
	Vector3.new(27, 1, -70),
	Vector3.new(80, 1, -70),
}

local function assignBase(player)
	local taken = {}
	for _, other in ipairs(Players:GetPlayers()) do
		local s = StateStore.getState(other)
		if s ~= nil and s.baseIndex ~= nil then
			taken[s.baseIndex] = true
		end
	end
	for i = 1, #BASE_POSITIONS do
		if taken[i] == nil then
			return i
		end
	end
	return 1
end

local function onPlayerAdded(player)
	StateStore.addPlayer(player)
	local state = StateStore.getState(player)
	state.baseIndex = assignBase(player)
	player.CharacterAdded:Connect(function(character)
		local spawn = BASE_POSITIONS[state.baseIndex] or BASE_POSITIONS[1]
		task.wait(0.2)
		local root = character:WaitForChild("HumanoidRootPart")
		root.CFrame = CFrame.new(spawn + Vector3.new(0, 3, 0))
		StateUpdate:FireClient(player, StateStore.snapshotForClient(state))
	end)
	StateUpdate:FireClient(player, StateStore.snapshotForClient(state))
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	StateStore.removePlayer(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

print("Warung Brainrot Bazaar server ready: 60 brainrots, 7 rarities, 8 mutations.")
