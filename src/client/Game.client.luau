-- Game.client: the client entry point for Warung Brainrot Bazaar.
-- Builds the HUD and shop, binds E (slap) and L (lock base), clicks on
-- conveyor brainrots to buy them, and shows hazard warnings.
-- The server owns all state; this script only shows it and asks for it.
-- Keys go through ContextActionService (never UserInputService.InputBegan),
-- so they never fight the default camera controls.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local HudClient = require(script.Parent.HudClient)
local ShopClient = require(script.Parent.ShopClient)
local EffectsClient = require(script.Parent.EffectsClient)

local hud = HudClient.buildHud(playerGui)
local shop = ShopClient.buildShop(playerGui)
local indexBook = nil

remotes.StateUpdate.OnClientEvent:Connect(function(snapshot)
	HudClient.updateHud(hud, snapshot)
end)

remotes.HazardAlert.OnClientEvent:Connect(function(alert)
	HudClient.showHazard(hud, alert.message)
	EffectsClient.flashRed(hud)
end)

remotes.BuyBrainrot.OnClientEvent:Connect(function(result)
	if result.ok then
		EffectsClient.popLabel(hud, "Got " .. result.name .. "!")
		EffectsClient.flashGold(hud)
	end
end)

remotes.StealAlert.OnClientEvent:Connect(function(alert)
	HudClient.showHazard(hud, alert.message)
end)

remotes.ConveyorUpdate.OnClientEvent:Connect(function(offer)
	-- The newest conveyor offer is shown in the HUD hint area.
	local hint = hud:FindFirstChild("HintLabel")
	if hint ~= nil then
		hint.Text = "NEW: " .. offer.name .. " (" .. offer.rarity .. " " .. offer.mutation .. ")  $"
			.. tostring(offer.income) .. "/s — $" .. tostring(offer.price) .. "  |  Click it on the belt to buy!"
	end
end)

local function slapPlayer(_action, state, _input)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local character = player.Character
	if character == nil then
		return Enum.ContextActionResult.Pass
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return Enum.ContextActionResult.Pass
	end
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character ~= nil then
			local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
			if otherRoot ~= nil and (otherRoot.Position - root.Position).Magnitude < 10 then
				remotes.SlapPlayer:FireServer(other)
			end
		end
	end
	return Enum.ContextActionResult.Sink
end

local function lockBase(_action, state, _input)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	remotes.LockBase:FireServer()
	EffectsClient.popLabel(hud, "Base LOCKED!")
	return Enum.ContextActionResult.Sink
end

local function toggleIndex(_action, state, _input)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if indexBook == nil then
		indexBook = ShopClient.buildIndexBook(playerGui, nil)
	end
	indexBook.Enabled = not indexBook.Enabled
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction("SlapThief", slapPlayer, false, Enum.KeyCode.E)
ContextActionService:BindAction("LockBase", lockBase, false, Enum.KeyCode.L)
ContextActionService:BindAction("ToggleIndex", toggleIndex, false, Enum.KeyCode.I)

-- Click a brainrot on the conveyor belt to buy it; click your base pad
-- while carrying a stolen brainrot to bank it. A click is routed by what it
-- hits: a model under ConveyorBrainrots buys, any part with "Pad" in its
-- name banks a steal, anything else is ignored.
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target == nil then
		return
	end
	local model = target:FindFirstAncestorOfClass("Model")
	if model ~= nil and model.Parent ~= nil and model.Parent.Name == "ConveyorBrainrots" then
		remotes.BuyBrainrot:FireServer(model.Name)
	elseif target.Name:find("Pad") ~= nil then
		remotes.FinishCarry:FireServer()
	end
end)
