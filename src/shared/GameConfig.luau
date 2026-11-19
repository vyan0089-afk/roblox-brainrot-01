-- GameConfig: every tuning number for Warung Brainrot Bazaar in one place.
-- Economy, rebirth tiers, upgrades, eggs, pets, hazards, bases, conveyor.
-- One job only: constants. Server code reads these; it never hard-codes them.

local GameConfig = {}

GameConfig.GAME_NAME = "Warung Brainrot Bazaar"
GameConfig.START_CASH = 250
GameConfig.CONVEYOR_SPAWN_SECONDS = 6
GameConfig.CONVEYOR_SLOTS = 8
GameConfig.CONVEYOR_LENGTH = 120
GameConfig.BASE_SLOTS_START = 6
GameConfig.BASE_SLOTS_MAX = 12
GameConfig.MAX_BASES = 8

-- Stealing: lock the base, slap the thief, carry the catch home.
GameConfig.LOCK_SECONDS = 20
GameConfig.LOCK_COOLDOWN_SECONDS = 60
GameConfig.SLAP_RANGE = 10
GameConfig.SLAP_KNOCKBACK = 28
GameConfig.SLAP_COOLDOWN_SECONDS = 1.5
GameConfig.STEAL_CARRY_SECONDS = 12
GameConfig.STEAL_PENALTY_CASH = 100

-- Hazards: BOTH a runaway cart and a sambal tsunami wave, on timers.
GameConfig.CART_WARNING_SECONDS = 5
GameConfig.CART_INTERVAL_SECONDS = 75
GameConfig.CART_DAMAGE_CASH = 150
GameConfig.WAVE_WARNING_SECONDS = 8
GameConfig.WAVE_INTERVAL_SECONDS = 120
GameConfig.WAVE_SAFE_ZONE = "Base"

-- Rebirth ladder: 5 tiers. Each resets cash + collection, multiplies income.
GameConfig.REBIRTHS = {
	{ name = "Pedagang Kaki Lima", needCash = 25000, needCount = 6, incomeMult = 2 },
	{ name = "Juragan Warung", needCash = 150000, needCount = 12, incomeMult = 3 },
	{ name = "Sultan Pasar", needCash = 750000, needCount = 20, incomeMult = 5 },
	{ name = "Raja Brainrot", needCash = 3000000, needCount = 30, incomeMult = 8 },
	{ name = "Dewa Warung", needCash = 12000000, needCount = 45, incomeMult = 12 },
}

-- Upgrades: 5 tracks, 5 levels each. Cost grows; effect stacks.
GameConfig.UPGRADES = {
	{ name = "Speed Boots", desc = "+12% walk speed / level", baseCost = 500, costMult = 2.2, maxLevel = 5 },
	{ name = "Slap Power", desc = "+40% knockback / level", baseCost = 800, costMult = 2.2, maxLevel = 5 },
	{ name = "Lock Duration", desc = "+8s base lock / level", baseCost = 1000, costMult = 2.4, maxLevel = 5 },
	{ name = "Income Boost", desc = "+25% all income / level", baseCost = 1500, costMult = 2.5, maxLevel = 5 },
	{ name = "Base Slots", desc = "+1 brainrot slot / level", baseCost = 2000, costMult = 2.6, maxLevel = 5 },
}

function GameConfig.upgradeCost(upgradeIndex, level)
	local u = GameConfig.UPGRADES[upgradeIndex]
	if u == nil then
		return 0
	end
	return math.floor(u.baseCost * (u.costMult ^ level))
end

-- Eggs: 3 kinds. Hatching rolls a brainrot of at least the egg's rarity floor.
GameConfig.EGGS = {
	{ name = "Telur Warung", price = 1000, minRarity = 1, maxRarity = 3, color = { 245, 230, 180 } },
	{ name = "Telur Pasar Malam", price = 10000, minRarity = 2, maxRarity = 5, color = { 180, 140, 255 } },
	{ name = "Telur Sultan", price = 100000, minRarity = 4, maxRarity = 7, color = { 255, 215, 0 } },
}

-- Pets: 6 companions. Each gives a passive bonus and chases thieves.
GameConfig.PETS = {
	{ name = "Kucing Warung", price = 2000, bonus = "Income +10%", incomeMult = 1.1 },
	{ name = "Anjing Satpam", price = 5000, bonus = "Slap +50%, guards base", incomeMult = 1.0 },
	{ name = "Bebek Karet", price = 8000, bonus = "Wave-proof: no wave loss", incomeMult = 1.05 },
	{ name = "Capybara Kasir", price = 15000, bonus = "Income +25%", incomeMult = 1.25 },
	{ name = "Monyet Maling", price = 30000, bonus = "Steal 2x faster", incomeMult = 1.0 },
	{ name = "Burung Hantu", price = 50000, bonus = "Income +40%, sees Secrets", incomeMult = 1.4 },
}

-- Index / collection book milestones: completing rarities pays a bonus.
GameConfig.INDEX_BONUSES = {
	{ rarity = 1, bonus = 500 },
	{ rarity = 2, bonus = 2000 },
	{ rarity = 3, bonus = 8000 },
	{ rarity = 4, bonus = 30000 },
	{ rarity = 5, bonus = 120000 },
	{ rarity = 6, bonus = 500000 },
	{ rarity = 7, bonus = 2000000 },
}

function GameConfig.formatMoney(n)
	if n >= 1000000 then
		return string.format("$%.2fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("$%.1fK", n / 1000)
	else
		return string.format("$%d", math.floor(n))
	end
end

return GameConfig
