-- ShopClient: the shop panels — conveyor buys, eggs, upgrades, pets and
-- rebirth — plus the Index / collection book (all 60 brainrots in a grid).
-- One job only: shop UI and the buttons that fire the server remotes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local BrainrotCatalog = require(Shared.BrainrotCatalog)

local ShopClient = {}

local function makeButton(parent, name, text, y)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = UDim2.new(0, 8, 0, y)
	button.Size = UDim2.new(1, -16, 0, 34)
	button.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(30, 20, 0)
	button.TextSize = 17
	button.Font = Enum.Font.SourceSansBold
	button.Parent = parent
	return button
end

function ShopClient.buildShop(playerGui)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BazaarShop"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local panel = Instance.new("Frame")
	panel.Name = "ShopPanel"
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -12, 0, 110)
	panel.Size = UDim2.new(0, 260, 0, 430)
	panel.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	panel.BackgroundTransparency = 0.15
	panel.Parent = gui

	local title = Instance.new("TextLabel")
	title.Name = "ShopTitle"
	title.Position = UDim2.new(0, 8, 0, 6)
	title.Size = UDim2.new(1, -16, 0, 28)
	title.BackgroundTransparency = 1
	title.Text = "WARUNG SHOP"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 22
	title.Font = Enum.Font.SourceSansBold
	title.Parent = panel

	local y = 42
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	for i, egg in ipairs(GameConfig.EGGS) do
		local b = makeButton(panel, "Egg" .. tostring(i), "🥚 " .. egg.name .. "  $" .. tostring(egg.price), y)
		b.MouseButton1Click:Connect(function()
			remotes.HatchEgg:FireServer(i)
		end)
		y += 40
	end
	for i, pet in ipairs(GameConfig.PETS) do
		local b = makeButton(panel, "Pet" .. tostring(i), "🐾 " .. pet.name .. "  $" .. tostring(pet.price), y)
		b.MouseButton1Click:Connect(function()
			remotes.BuyPet:FireServer(i)
		end)
		y += 40
	end
	local rebirth = makeButton(panel, "RebirthButton", "♻ REBIRTH — reset for x2+ income", y)
	rebirth.BackgroundColor3 = Color3.fromRGB(140, 90, 255)
	rebirth.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirth.MouseButton1Click:Connect(function()
		remotes.Rebirth:FireServer()
	end)
	y += 40
	for i, up in ipairs(GameConfig.UPGRADES) do
		local b = makeButton(panel, "Upgrade" .. tostring(i), "⬆ " .. up.name, y)
		b.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
		b.MouseButton1Click:Connect(function()
			remotes.BuyUpgrade:FireServer(i)
		end)
		y += 40
	end
	panel.Size = UDim2.new(0, 260, 0, y + 8)
	return gui
end

function ShopClient.buildIndexBook(playerGui, seen)
	local gui = Instance.new("ScreenGui")
	gui.Name = "IndexBook"
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "IndexFrame"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 640, 0, 420)
	frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	frame.Parent = gui
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 36)
	title.BackgroundTransparency = 1
	title.Text = "INDEX BOOK — 60 BRAINROTS  |  7 RARITIES  |  8 MUTATIONS"
	title.TextColor3 = Color3.fromRGB(255, 215, 0)
	title.TextSize = 20
	title.Font = Enum.Font.SourceSansBold
	title.Parent = frame
	local grid = Instance.new("TextLabel")
	grid.Name = "IndexGrid"
	grid.Position = UDim2.new(0, 12, 0, 44)
	grid.Size = UDim2.new(1, -24, 1, -56)
	grid.BackgroundTransparency = 1
	grid.TextXAlignment = Enum.TextXAlignment.Left
	grid.TextYAlignment = Enum.TextYAlignment.Top
	grid.TextWrapped = true
	grid.TextSize = 15
	grid.Font = Enum.Font.SourceSans
	grid.TextColor3 = Color3.fromRGB(255, 255, 255)
	local lines = {}
	for _, b in ipairs(BrainrotCatalog.BRAINROTS) do
		local mark = (seen ~= nil and seen[b.id]) and "✓" or "·"
		table.insert(lines, mark .. " " .. b.name .. " (" .. b.rarityName .. ", $" .. tostring(b.income) .. "/s)")
	end
	grid.Text = table.concat(lines, "\n")
	grid.Parent = frame
	return gui
end

return ShopClient
