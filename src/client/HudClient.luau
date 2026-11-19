-- HudClient: the heads-up display. Cash, income per second, rebirth tier,
-- base lock state, hazard banner and the Index count (60 brainrots).
-- One job only: build and update the HUD. Kept clear of the top-left
-- corner, where Roblox's own menu buttons sit.

local HudClient = {}

function HudClient.buildHud(playerGui)
	local gui = Instance.new("ScreenGui")
	gui.Name = "BazaarHud"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = playerGui

	local cash = Instance.new("TextLabel")
	cash.Name = "CashLabel"
	cash.AnchorPoint = Vector2.new(0.5, 0)
	cash.Position = UDim2.new(0.5, 0, 0.02, 0)
	cash.Size = UDim2.new(0, 420, 0, 44)
	cash.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	cash.BackgroundTransparency = 0.2
	cash.Text = "WARUNG BRAINROT BAZAAR  |  $250"
	cash.TextColor3 = Color3.fromRGB(255, 215, 0)
	cash.TextSize = 26
	cash.Font = Enum.Font.SourceSansBold
	cash.Parent = gui

	local income = Instance.new("TextLabel")
	income.Name = "IncomeLabel"
	income.AnchorPoint = Vector2.new(0.5, 0)
	income.Position = UDim2.new(0.5, 0, 0.02, 48)
	income.Size = UDim2.new(0, 420, 0, 30)
	income.BackgroundTransparency = 1
	income.Text = "$0/s  |  Index 0/60  |  New Trader"
	income.TextColor3 = Color3.fromRGB(255, 255, 255)
	income.TextSize = 20
	income.Font = Enum.Font.SourceSansBold
	income.Parent = gui

	local banner = Instance.new("TextLabel")
	banner.Name = "HazardBanner"
	banner.AnchorPoint = Vector2.new(0.5, 0)
	banner.Position = UDim2.new(0.5, 0, 0.16, 0)
	banner.Size = UDim2.new(0, 640, 0, 44)
	banner.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
	banner.BackgroundTransparency = 0.25
	banner.Text = ""
	banner.TextColor3 = Color3.fromRGB(255, 255, 255)
	banner.TextSize = 24
	banner.Font = Enum.Font.SourceSansBold
	banner.Visible = false
	banner.Parent = gui

	local hint = Instance.new("TextLabel")
	hint.Name = "HintLabel"
	hint.AnchorPoint = Vector2.new(0.5, 1)
	hint.Position = UDim2.new(0.5, 0, 0.98, 0)
	hint.Size = UDim2.new(0, 700, 0, 28)
	hint.BackgroundTransparency = 1
	hint.Text = "Buy brainrots on the conveyor  |  E = slap  |  L = lock base  |  Run home when the cart or wave comes!"
	hint.TextColor3 = Color3.fromRGB(255, 255, 255)
	hint.TextSize = 18
	hint.Font = Enum.Font.SourceSans
	hint.Parent = gui

	return gui
end

function HudClient.updateHud(gui, snapshot)
	local cash = gui:FindFirstChild("CashLabel")
	local income = gui:FindFirstChild("IncomeLabel")
	if cash ~= nil then
		cash.Text = "WARUNG BRAINROT BAZAAR  |  $" .. tostring(snapshot.cash)
	end
	if income ~= nil then
		local lockText = snapshot.locked and "  |  BASE LOCKED" or ""
		income.Text = "$" .. tostring(snapshot.incomePerSecond) .. "/s  |  Index "
			.. tostring(snapshot.indexSeenCount) .. "/60  |  " .. snapshot.rebirthName .. lockText
	end
end

function HudClient.showHazard(gui, message)
	local banner = gui:FindFirstChild("HazardBanner")
	if banner == nil then
		return
	end
	banner.Text = message
	banner.Visible = true
	task.delay(9, function()
		banner.Visible = false
	end)
end

return HudClient
