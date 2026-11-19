-- EconomyServer: money ticks up. Every second, each player's base earns
-- the combined $/s of its brainrots, and the client HUD is updated.
-- One job only: the income loop and selling a brainrot back.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)
local BrainrotCatalog = require(ReplicatedStorage:WaitForChild("Shared").BrainrotCatalog)
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").GameConfig)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StateUpdate = Remotes:WaitForChild("StateUpdate")
local SellRemote = Remotes:WaitForChild("SellBrainrot")

-- Income ticks once a second, adding the whole $/s at once, so cash never
-- drifts by fractions between ticks and the HUD always shows whole dollars.
function EconomyServer_tickIncome()
	for _, player in ipairs(Players:GetPlayers()) do
		local state = StateStore.getState(player)
		if state ~= nil then
			local earned = StateStore.incomePerSecond(state)
			state.cash += earned
			state.totalEarned += earned
			StateUpdate:FireClient(player, StateStore.snapshotForClient(state))
		end
	end
end

function EconomyServer_sellBrainrot(player, collectionIndex)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	local owned = state.collection[collectionIndex]
	if owned == nil then
		return
	end
	local entry = BrainrotCatalog.getBrainrot(owned.brainrotId)
	if entry == nil then
		return
	end
	-- Selling pays back half the mutated price (GameConfig.SELL_REFUND):
	-- a misclick costs half, not everything.
	StateStore.removeBrainrot(state, collectionIndex)
	state.cash += math.floor(BrainrotCatalog.priceFor(owned.brainrotId, owned.mutation) * GameConfig.SELL_REFUND)
	StateUpdate:FireClient(player, StateStore.snapshotForClient(state))
end

SellRemote.OnServerEvent:Connect(function(player, collectionIndex)
	EconomyServer_sellBrainrot(player, collectionIndex)
end)

task.spawn(function()
	while true do
		task.wait(1)
		EconomyServer_tickIncome()
	end
end)
