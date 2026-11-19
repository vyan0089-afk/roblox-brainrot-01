-- BrainrotModels: builds the 3D body of one brainrot from Parts.
-- One job only: turn a catalog entry (+ mutation) into a visible Model
-- with a name billboard, rarity colour and a mutation aura. Used by the
-- conveyor (parade) and by bases, so the same character is seen in both.

local BrainrotCatalog = require(script.Parent.BrainrotCatalog)

local BrainrotModels = {}

local MUTATION_AURA = {
	Spicy = { 255, 80, 40 },
	Golden = { 255, 215, 0 },
	Frozen = { 150, 220, 255 },
	Rainbow = { 200, 100, 255 },
	Shadow = { 80, 80, 120 },
	Lava = { 255, 110, 0 },
	Cosmic = { 120, 80, 255 },
}

function BrainrotModels.buildModel(brainrotId, mutationName)
	local entry = BrainrotCatalog.getBrainrot(brainrotId)
	if entry == nil then
		return nil
	end
	local model = Instance.new("Model")
	model.Name = entry.name

	local rarity = BrainrotCatalog.RARITIES[entry.rarity]
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(3, 3, 3)
	body.Color = Color3.fromRGB(entry.color[1], entry.color[2], entry.color[3])
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model

	local hat = Instance.new("Part")
	hat.Name = "Hat_" .. entry.accessory
	hat.Size = Vector3.new(2.2, 1, 2.2)
	hat.Position = Vector3.new(0, 1.8, 0)
	hat.Color = Color3.fromRGB(rarity.color[1], rarity.color[2], rarity.color[3])
	hat.Material = Enum.Material.Neon
	hat.Anchored = true
	hat.CanCollide = false
	hat.Parent = model

	local eyeL = Instance.new("Part")
	eyeL.Name = "EyeLeft"
	eyeL.Size = Vector3.new(0.5, 0.7, 0.2)
	eyeL.Position = Vector3.new(-0.6, 0.4, 1.5)
	eyeL.Color = Color3.fromRGB(20, 20, 20)
	eyeL.Anchored = true
	eyeL.CanCollide = false
	eyeL.Parent = model

	local eyeR = eyeL:Clone()
	eyeR.Name = "EyeRight"
	eyeR.Position = Vector3.new(0.6, 0.4, 1.5)
	eyeR.Parent = model

	if mutationName ~= nil and mutationName ~= "Normal" then
		local auraColor = MUTATION_AURA[mutationName]
		if auraColor ~= nil then
			local aura = Instance.new("Part")
			aura.Name = "Aura_" .. mutationName
			aura.Shape = Enum.PartType.Ball
			aura.Size = Vector3.new(3.8, 3.8, 3.8)
			aura.Color = Color3.fromRGB(auraColor[1], auraColor[2], auraColor[3])
			aura.Material = Enum.Material.Neon
			aura.Transparency = 0.6
			aura.Anchored = true
			aura.CanCollide = false
			aura.Parent = model
		end
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Label"
	billboard.Size = UDim2.new(0, 160, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 3.2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = body

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "BrainrotName"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = entry.name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Parent = billboard

	local income = BrainrotCatalog.mutatedIncome(brainrotId, mutationName)
	local subLabel = Instance.new("TextLabel")
	subLabel.Name = "BrainrotStats"
	subLabel.Position = UDim2.new(0, 0, 0.5, 0)
	subLabel.Size = UDim2.new(1, 0, 0.5, 0)
	subLabel.BackgroundTransparency = 1
	if mutationName ~= nil and mutationName ~= "Normal" then
		subLabel.Text = rarity.name .. " " .. mutationName .. "  $" .. tostring(income) .. "/s"
	else
		subLabel.Text = rarity.name .. "  $" .. tostring(income) .. "/s"
	end
	subLabel.TextColor3 = Color3.fromRGB(rarity.color[1], rarity.color[2], rarity.color[3])
	subLabel.TextScaled = true
	subLabel.Font = Enum.Font.SourceSansBold
	subLabel.Parent = billboard

	-- The ball body is the PrimaryPart, so the conveyor moves a brainrot by
	-- its body and the name billboard (AlwaysOnTop) stays readable through
	-- the market crowd. Eyes sit on the +Z face, the side that faces buyers.
	model.PrimaryPart = body
	return model
end

return BrainrotModels
