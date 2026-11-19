-- ProgressionServer: rebirth, upgrades, eggs and pets.
-- Rebirth resets cash + collection for a permanent income multiplier.
-- Upgrades are 5 tracks x 5 levels. Eggs hatch a random brainrot.
-- Pets are companions with passive bonuses. One job only: progression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotCatalog = require(Shared.BrainrotCatalog)
local GameConfig = require(Shared.GameConfig)
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RebirthRemote = Remotes:WaitForChild("Rebirth")
local UpgradeRemote = Remotes:WaitForChild("BuyUpgrade")
local EggRemote = Remotes:WaitForChild("HatchEgg")
local PetRemote = Remotes:WaitForChild("BuyPet")
local StateUpdate = Remotes:WaitForChild("StateUpdate")

local rng = Random.new(777)

local function refresh(player)
	local state = StateStore.getState(player)
	if state ~= nil then
		StateUpdate:FireClient(player, StateStore.snapshotForClient(state))
	end
end

function ProgressionServer_rebirth(player)
	local state = StateStore.getState(player)
	if state == nil or state.rebirth >= #GameConfig.REBIRTHS then
		return
	end
	local tier = GameConfig.REBIRTHS[state.rebirth + 1]
	if state.cash < tier.needCash or #state.collection < tier.needCount then
		return
	end
	-- Rebirth resets cash, collection and base slots — but keeps upgrades
	-- and pets, so every rebirth starts faster than the last one did.
	state.rebirth += 1
	state.cash = GameConfig.START_CASH
	state.collection = {}
	state.baseSlots = GameConfig.BASE_SLOTS_START
	refresh(player)
end

function ProgressionServer_buyUpgrade(player, upgradeIndex)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	local level = state.upgrades[upgradeIndex]
	local def = GameConfig.UPGRADES[upgradeIndex]
	if level == nil or def == nil or level >= def.maxLevel then
		return
	end
	local cost = GameConfig.upgradeCost(upgradeIndex, level)
	if state.cash < cost then
		return
	end
	state.cash -= cost
	state.upgrades[upgradeIndex] = level + 1
	if upgradeIndex == 5 then
		state.baseSlots = math.min(GameConfig.BASE_SLOTS_MAX, state.baseSlots + 1)
	end
	refresh(player)
end

function ProgressionServer_hatchEgg(player, eggIndex)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	local egg = GameConfig.EGGS[eggIndex]
	if egg == nil or state.cash < egg.price then
		return
	end
	state.cash -= egg.price
	local rarity = rng:NextInteger(egg.minRarity, egg.maxRarity)
	local pool = BrainrotCatalog.listByRarity(rarity)
	local entry = pool[rng:NextInteger(1, #pool)]
	local mutation = BrainrotCatalog.rollMutation(rng)
	-- A hatched brainrot that cannot fit in a full base refunds the whole
	-- egg price: the player loses nothing for an egg that could not hatch.
	local ok, err = StateStore.addBrainrot(state, entry.id, mutation)
	if not ok then
		state.cash += egg.price
	end
	refresh(player)
end

function ProgressionServer_buyPet(player, petIndex)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	local pet = GameConfig.PETS[petIndex]
	if pet == nil or state.cash < pet.price then
		return
	end
	-- Buying a pet already owned only switches it active again — no second
	-- charge for a companion the player already paid for.
	for _, owned in ipairs(state.pets) do
		if owned == petIndex then
			state.activePet = petIndex
			refresh(player)
			return
		end
	end
	state.cash -= pet.price
	table.insert(state.pets, petIndex)
	state.activePet = petIndex
	refresh(player)
end

RebirthRemote.OnServerEvent:Connect(function(player)
	ProgressionServer_rebirth(player)
end)
UpgradeRemote.OnServerEvent:Connect(function(player, upgradeIndex)
	ProgressionServer_buyUpgrade(player, upgradeIndex)
end)
EggRemote.OnServerEvent:Connect(function(player, eggIndex)
	ProgressionServer_hatchEgg(player, eggIndex)
end)
PetRemote.OnServerEvent:Connect(function(player, petIndex)
	ProgressionServer_buyPet(player, petIndex)
end)
