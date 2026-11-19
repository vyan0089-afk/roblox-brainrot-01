-- StateStore: the ONE place all player state lives. Server owns it.
-- Cash, collection, bases, locks, rebirths, upgrades, eggs, pets, index.
-- Every other server script reads/writes state only through this module,
-- so the economy can never drift between two copies of the truth.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotCatalog = require(Shared.BrainrotCatalog)
local GameConfig = require(Shared.GameConfig)

local StateStore = {}
StateStore.Players = {}

function StateStore.newPlayerState(player)
	return {
		player = player,
		cash = GameConfig.START_CASH,
		collection = {},
		baseSlots = GameConfig.BASE_SLOTS_START,
		lockedUntil = 0,
		lockCooldownUntil = 0,
		rebirth = 0,
		upgrades = { 0, 0, 0, 0, 0 },
		pets = {},
		activePet = nil,
		indexSeen = {},
		indexBonusPaid = {},
		carrying = nil,
		stealStartedAt = 0,
		lastSlapAt = 0,
		totalEarned = 0,
	}
end

function StateStore.addPlayer(player)
	StateStore.Players[player.UserId] = StateStore.newPlayerState(player)
end

function StateStore.removePlayer(player)
	StateStore.Players[player.UserId] = nil
end

function StateStore.getState(player)
	return StateStore.Players[player.UserId]
end

function StateStore.incomeMultiplier(state)
	local mult = 1
	if state.rebirth > 0 then
		mult *= GameConfig.REBIRTHS[state.rebirth].incomeMult
	end
	mult *= 1 + 0.25 * state.upgrades[4]
	if state.activePet ~= nil then
		local pet = GameConfig.PETS[state.activePet]
		if pet ~= nil then
			mult *= pet.incomeMult
		end
	end
	return mult
end

function StateStore.incomePerSecond(state)
	local total = 0
	for _, owned in ipairs(state.collection) do
		total += BrainrotCatalog.mutatedIncome(owned.brainrotId, owned.mutation)
	end
	return total * StateStore.incomeMultiplier(state)
end

function StateStore.addBrainrot(state, brainrotId, mutation)
	if #state.collection >= state.baseSlots then
		return false, "Base full! Buy more slots."
	end
	table.insert(state.collection, { brainrotId = brainrotId, mutation = mutation or "Normal" })
	state.indexSeen[brainrotId] = true
	StateStore.checkIndexBonus(state, brainrotId)
	return true
end

function StateStore.removeBrainrot(state, index)
	if state.collection[index] == nil then
		return nil
	end
	local owned = state.collection[index]
	table.remove(state.collection, index)
	return owned
end

function StateStore.checkIndexBonus(state, brainrotId)
	local entry = BrainrotCatalog.getBrainrot(brainrotId)
	if entry == nil then
		return
	end
	if state.indexBonusPaid[entry.rarity] then
		return
	end
	local ownedOfRarity = {}
	for _, owned in ipairs(state.collection) do
		local e = BrainrotCatalog.getBrainrot(owned.brainrotId)
		if e ~= nil and e.rarity == entry.rarity then
			ownedOfRarity[e.id] = true
		end
	end
	local all = BrainrotCatalog.listByRarity(entry.rarity)
	local complete = true
	for _, b in ipairs(all) do
		if ownedOfRarity[b.id] == nil then
			complete = false
		end
	end
	-- The bonus pays once per completed rarity, not once per brainrot, so
	-- finishing Common pays $500 exactly once no matter how many Commons
	-- the player buys afterwards.
	if complete then
		state.indexBonusPaid[entry.rarity] = true
		state.cash += GameConfig.INDEX_BONUSES[entry.rarity].bonus
	end
end

function StateStore.isBaseLocked(state)
	return os.clock() < state.lockedUntil
end

function StateStore.lockDuration(state)
	return GameConfig.LOCK_SECONDS + 8 * state.upgrades[3]
end

function StateStore.snapshotForClient(state)
	local collection = {}
	for i, owned in ipairs(state.collection) do
		local entry = BrainrotCatalog.getBrainrot(owned.brainrotId)
		collection[i] = {
			brainrotId = owned.brainrotId,
			name = entry and entry.name or "?",
			rarity = entry and entry.rarityName or "?",
			mutation = owned.mutation,
			income = BrainrotCatalog.mutatedIncome(owned.brainrotId, owned.mutation),
		}
	end
	return {
		cash = math.floor(state.cash),
		incomePerSecond = math.floor(StateStore.incomePerSecond(state)),
		collection = collection,
		baseSlots = state.baseSlots,
		locked = StateStore.isBaseLocked(state),
		lockedUntil = state.lockedUntil,
		rebirth = state.rebirth,
		rebirthName = state.rebirth > 0 and GameConfig.REBIRTHS[state.rebirth].name or "New Trader",
		upgrades = state.upgrades,
		pets = state.pets,
		activePet = state.activePet,
		indexSeenCount = StateStore.indexCount(state),
	}
end

function StateStore.indexCount(state)
	local n = 0
	for _ in pairs(state.indexSeen) do
		n += 1
	end
	return n
end

-- True when the player owns (and may have active) a pet with this name.
-- Hazards ask this instead of scanning the pet list themselves.
function StateStore.hasPetByName(state, petName)
	for _, petIndex in ipairs(state.pets) do
		local pet = GameConfig.PETS[petIndex]
		if pet ~= nil and pet.name == petName then
			return true
		end
	end
	return false
end

return StateStore
