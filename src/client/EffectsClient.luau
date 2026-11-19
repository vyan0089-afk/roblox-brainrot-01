-- EffectsClient: juice. Screen flash on a slap, a gold pop when cash
-- ticks, a red pulse on a hazard warning, and a sparkle on a rare buy.
-- One job only: feedback effects. No game state lives here.

local TweenService = game:GetService("TweenService")

local EffectsClient = {}

-- Flashes are full-screen frames tweened to fully transparent and then
-- destroyed (gold 0.7s, red 0.9s), so repeated effects never pile up
-- invisible frames on the HUD.
function EffectsClient.flashGold(gui)
	local flash = Instance.new("Frame")
	flash.Name = "GoldFlash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	flash.BackgroundTransparency = 0.85
	flash.BorderSizePixel = 0
	flash.Parent = gui
	TweenService:Create(flash, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
	task.delay(0.7, function()
		flash:Destroy()
	end)
end

function EffectsClient.flashRed(gui)
	local flash = Instance.new("Frame")
	flash.Name = "RedFlash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
	flash.BackgroundTransparency = 0.8
	flash.BorderSizePixel = 0
	flash.Parent = gui
	TweenService:Create(flash, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	task.delay(0.9, function()
		flash:Destroy()
	end)
end

-- A pop label rises from 40% to 30% of the screen height while fading out
-- over 1.2 seconds, then destroys itself.
function EffectsClient.popLabel(gui, text)
	local label = Instance.new("TextLabel")
	label.Name = "PopLabel"
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, 0, 0.4, 0)
	label.Size = UDim2.new(0, 500, 0, 50)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(255, 215, 0)
	label.TextSize = 32
	label.Font = Enum.Font.SourceSansBold
	label.Parent = gui
	TweenService:Create(label, TweenInfo.new(1.2), { Position = UDim2.new(0.5, 0, 0.3, 0), TextTransparency = 1 }):Play()
	task.delay(1.3, function()
		label:Destroy()
	end)
end

return EffectsClient
