-- BrainrotCatalog: the whole cast of Warung Brainrot Bazaar.
-- 60 original named brainrots across 7 rarities, each with a base income
-- ($/second), a buy price and a body colour. One job only: data + lookup.
-- Beat-the-top-3 note: Big Top Brainrots has 36, Brainrot Bay v2 has 55.
-- This bazaar has 60, plus 8 mutations (they have 6).

local BrainrotCatalog = {}

BrainrotCatalog.RARITIES = {
	{ name = "Common", color = { 180, 180, 180 }, chance = 38, incomeMult = 1 },
	{ name = "Uncommon", color = { 110, 220, 110 }, chance = 26, incomeMult = 2.5 },
	{ name = "Rare", color = { 90, 160, 255 }, chance = 17, incomeMult = 6 },
	{ name = "Epic", color = { 190, 110, 255 }, chance = 10, incomeMult = 15 },
	{ name = "Legendary", color = { 255, 190, 40 }, chance = 6, incomeMult = 40 },
	{ name = "Mythic", color = { 255, 80, 120 }, chance = 2.5, incomeMult = 120 },
	{ name = "Secret", color = { 60, 240, 220 }, chance = 0.5, incomeMult = 400 },
}

-- The rarity chances add to exactly 100 (38+26+17+10+6+2.5+0.5), so every
-- roll lands in exactly one tier — no roll ever falls through the table.
-- Mutation ladder: 8 mutations, each a real income multiplier.
BrainrotCatalog.MUTATIONS = {
	{ name = "Normal", mult = 1, chance = 62 },
	{ name = "Spicy", mult = 2, chance = 14 },
	{ name = "Golden", mult = 3, chance = 9 },
	{ name = "Frozen", mult = 4, chance = 6 },
	{ name = "Rainbow", mult = 5, chance = 4 },
	{ name = "Shadow", mult = 6, chance = 2.5 },
	{ name = "Lava", mult = 8, chance = 1.7 },
	{ name = "Cosmic", mult = 10, chance = 0.8 },
}

-- Mutation chances also add to exactly 100, same guarantee as rarities.
-- Income climbs about 4x per rarity tier: $5/s for the cheapest Common to
-- $50,000/s for the Tsunami Sambal Titan, four orders of magnitude to chase.
-- name, rarity index (1-7), income $/s, price $, colour, hat/accessory
local ROWS = {
	-- Common (12)
	{ "Nasi Goreng Goblin", 1, 5, 50, { 230, 170, 60 }, "Wok" },
	{ "Es Teh Manis Slime", 1, 6, 60, { 200, 120, 40 }, "Straw" },
	{ "Kerupuk Crunch Cat", 1, 7, 70, { 245, 220, 180 }, "Cracker" },
	{ "Bakso Bulat Boy", 1, 8, 80, { 190, 140, 100 }, "Bowl" },
	{ "Tempeh Titan Mini", 1, 9, 90, { 210, 180, 120 }, "Apron" },
	{ "Pisang Goreng Phantom", 1, 10, 100, { 250, 210, 80 }, "Peel" },
	{ "Tahu Bulat Bounce", 1, 11, 110, { 245, 240, 220 }, "TofuHat" },
	{ "Mie Ayam Noodle Snake", 1, 12, 120, { 240, 200, 90 }, "Noodle" },
	{ "Sate Skewered Sloth", 1, 13, 130, { 180, 120, 70 }, "Skewer" },
	{ "Kopi Tubruk Toad", 1, 14, 140, { 90, 60, 40 }, "Cup" },
	{ "Cireng Crispy Crab", 1, 15, 150, { 235, 190, 130 }, "Shell" },
	{ "Es Campur Cloud", 1, 16, 160, { 255, 180, 200 }, "Umbrella" },
	-- Uncommon (11)
	{ "Martabak Manis Monster", 2, 22, 350, { 200, 140, 60 }, "Chocolate" },
	{ "Gado-Gado Golem", 2, 26, 420, { 120, 200, 90 }, "Peanut" },
	{ "Soto Ayam Siren", 2, 30, 500, { 250, 220, 120 }, "Spoon" },
	{ "Rendang Rhino", 2, 34, 580, { 150, 80, 40 }, "Horn" },
	{ "Pecel Lele Lizard", 2, 38, 650, { 90, 180, 120 }, "Tail" },
	{ "Nasi Padang Panda", 2, 42, 720, { 240, 240, 240 }, "BananaLeaf" },
	{ "Klepon Green Gremlin", 2, 46, 800, { 80, 220, 110 }, "Coconut" },
	{ "Dadar Gulung Dragon", 2, 50, 880, { 100, 200, 90 }, "Pandan" },
	{ "Bubur Ayam Blob", 2, 54, 950, { 245, 230, 180 }, "Cracker" },
	{ "Lontong Sayur Shark", 2, 58, 1020, { 140, 200, 230 }, "Fin" },
	{ "Serabi Solo Sprite", 2, 62, 1100, { 230, 200, 160 }, "Coconut" },
	-- Rare (10)
	{ "Ayam Geprek Griffin", 3, 95, 2200, { 240, 120, 50 }, "Chilli" },
	{ "Ikan Bakar Inferno", 3, 110, 2600, { 230, 90, 40 }, "Flame" },
	{ "Sop Buntut Basilisk", 3, 125, 3000, { 180, 120, 60 }, "Bone" },
	{ "Ketoprak Kraken", 3, 140, 3400, { 200, 160, 90 }, "Tentacle" },
	{ "Rawon Black Knight", 3, 155, 3800, { 60, 60, 60 }, "Keluak" },
	{ "Opor Ayam Owl", 3, 170, 4200, { 245, 235, 200 }, "Feather" },
	{ "Pempek Palembang Phoenix", 3, 185, 4600, { 240, 180, 60 }, "Vinegar" },
	{ "Gudeg Jogja Giant", 3, 200, 5000, { 190, 130, 50 }, "Jackfruit" },
	{ "Coto Makassar Cyclops", 3, 215, 5400, { 200, 150, 90 }, "Eye" },
	{ "Papeda Papua Python", 3, 230, 5800, { 220, 220, 220 }, "Sago" },
	-- Epic (9)
	{ "Tumpeng Tower Titan", 4, 380, 12000, { 250, 200, 60 }, "Cone" },
	{ "Wayang Kulit Wraith", 4, 430, 14000, { 80, 60, 50 }, "ShadowPuppet" },
	{ "Barong Bali Beast", 4, 480, 16000, { 230, 60, 60 }, "BarongMask" },
	{ "Ondel-Ondel Ogre", 4, 530, 18000, { 240, 100, 140 }, "OndelHat" },
	{ "Kecak Fire Monkey", 4, 580, 20000, { 200, 90, 50 }, "Torch" },
	{ "Reog Ponorogo Roarer", 4, 640, 23000, { 220, 50, 50 }, "Peacock" },
	{ "Jaranan Horse Hero", 4, 700, 26000, { 180, 120, 60 }, "HorseHead" },
	{ "Topeng Monyet Trickster", 4, 760, 29000, { 150, 100, 60 }, "Mask" },
	{ "Gamelan Gong Golem", 4, 820, 32000, { 220, 180, 80 }, "Gong" },
	-- Legendary (8)
	{ "Sultan Sambal Serpent", 5, 1400, 60000, { 230, 40, 40 }, "ChilliCrown" },
	{ "Ratu Rujak Rainbow", 5, 1600, 70000, { 255, 120, 180 }, "FruitCrown" },
	{ "Dewa Durian Destroyer", 5, 1800, 80000, { 200, 180, 60 }, "SpikeCrown" },
	{ "Naga Nasi Uduk", 5, 2000, 90000, { 240, 220, 150 }, "Dragon" },
	{ "Garuda Gorengan", 5, 2200, 100000, { 230, 170, 50 }, "Wings" },
	{ "Kuntilanak Kerupuk", 5, 2400, 110000, { 245, 245, 245 }, "GhostVeil" },
	{ "Genderuwo Gado-Gado", 5, 2600, 120000, { 90, 140, 90 }, "ShadowCape" },
	{ "Tuyul Tahu Bulat", 5, 2800, 130000, { 60, 200, 120 }, "CoinBag" },
	-- Mythic (6)
	{ "Jaka Tarub Time Traveller", 6, 5200, 300000, { 120, 180, 255 }, "Clock" },
	{ "Nyi Roro Kidul Wave Queen", 6, 6000, 350000, { 60, 200, 200 }, "WaveCrown" },
	{ "Semar Supreme Sage", 6, 6800, 400000, { 240, 200, 120 }, "SageHat" },
	{ "Bima Bakar Meteor", 6, 7600, 450000, { 255, 120, 40 }, "Meteor" },
	{ "Arjuna Ayam Geprek", 6, 8400, 500000, { 240, 100, 60 }, "Bow" },
	{ "Hanoman Hujan Emas", 6, 9200, 550000, { 250, 210, 90 }, "GoldTail" },
	-- Secret (4)
	{ "Warung Godfather", 7, 25000, 1500000, { 255, 215, 0 }, "GoldCrown" },
	{ "Pasar Malam Phantom King", 7, 30000, 1800000, { 150, 80, 255 }, "NeonCrown" },
	{ "Gerobak Liar Ghost Rider", 7, 35000, 2100000, { 255, 80, 80 }, "CartWheel" },
	{ "Tsunami Sambal Titan", 7, 50000, 3000000, { 255, 40, 40 }, "WaveThrone" },
}

BrainrotCatalog.BRAINROTS = {}
for i, row in ipairs(ROWS) do
	BrainrotCatalog.BRAINROTS[i] = {
		id = i,
		name = row[1],
		rarity = row[2],
		rarityName = BrainrotCatalog.RARITIES[row[2]].name,
		income = row[3],
		price = row[4],
		color = row[5],
		accessory = row[6],
	}
end

function BrainrotCatalog.getBrainrot(id)
	return BrainrotCatalog.BRAINROTS[id]
end

function BrainrotCatalog.rarityOf(id)
	local b = BrainrotCatalog.BRAINROTS[id]
	if b == nil then
		return nil
	end
	return BrainrotCatalog.RARITIES[b.rarity]
end

function BrainrotCatalog.mutatedIncome(brainrotId, mutationName)
	local b = BrainrotCatalog.BRAINROTS[brainrotId]
	if b == nil then
		return 0
	end
	for _, m in ipairs(BrainrotCatalog.MUTATIONS) do
		if m.name == mutationName then
			return b.income * m.mult
		end
	end
	return b.income
end

function BrainrotCatalog.rollMutation(random)
	local roll = random:NextNumber(0, 100)
	local acc = 0
	for _, m in ipairs(BrainrotCatalog.MUTATIONS) do
		acc += m.chance
		if roll <= acc then
			return m.name
		end
	end
	return "Normal"
end

function BrainrotCatalog.rollRarity(random)
	local roll = random:NextNumber(0, 100)
	local acc = 0
	for i, r in ipairs(BrainrotCatalog.RARITIES) do
		acc += r.chance
		if roll <= acc then
			return i
		end
	end
	return 1
end

function BrainrotCatalog.listByRarity(rarityIndex)
	local out = {}
	for _, b in ipairs(BrainrotCatalog.BRAINROTS) do
		if b.rarity == rarityIndex then
			table.insert(out, b)
		end
	end
	return out
end

function BrainrotCatalog.priceFor(brainrotId, mutationName)
	local b = BrainrotCatalog.BRAINROTS[brainrotId]
	if b == nil then
		return 0
	end
	for _, m in ipairs(BrainrotCatalog.MUTATIONS) do
		if m.name == mutationName then
			return math.floor(b.price * m.mult)
		end
	end
	return b.price
end

return BrainrotCatalog
