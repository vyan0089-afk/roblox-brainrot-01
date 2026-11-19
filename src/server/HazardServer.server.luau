-- HazardServer: the two map hazards that force a dash home.
-- (1) The Runaway Food Cart (Gerobak Liar) tears across the market on a
-- warning, knocking players and cash loose. (2) The Sambal Tsunami wave
-- sweeps the plaza; only players inside their base (or with Bebek Karet)
-- keep their cash. One job only: warn, sweep, punish, repeat.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").GameConfig)
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HazardAlert = Remotes:WaitForChild("HazardAlert")

local cart = Workspace:WaitForChild("HazardCart")

-- The cart crosses diagonally from (-90, 30) to (90, -30) in 60 steps of
-- 3 studs; anyone still loitering in the middle lane (Z within 12 studs)
-- when it finishes its run is knocked flying and loses $150.
function HazardServer_runawayCart()
	HazardAlert:FireAllClients({ kind = "cart", message = "GEROBAK LIAR! Runaway food cart incoming — get out of the lane!" })
	task.wait(GameConfig.CART_WARNING_SECONDS)
	for step = 1, 60 do
		cart.Position = Vector3.new(-90 + step * 3, 3, 30 - step * 1)
		task.wait(0.05)
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character ~= nil then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root ~= nil and math.abs(root.Position.Z - 0) < 12 and math.abs(root.Position.X) < 90 then
				local state = StateStore.getState(player)
				if state ~= nil then
					state.cash = math.max(0, state.cash - GameConfig.CART_DAMAGE_CASH)
				end
				root.AssemblyLinearVelocity = Vector3.new(0, 25, -30)
			end
		end
	end
	cart.Position = Vector3.new(-90, 3, 30)
end

function HazardServer_sambalTsunami()
	HazardAlert:FireAllClients({ kind = "wave", message = "TSUNAMI SAMBAL! Wave coming — run to your BASE!" })
	task.wait(GameConfig.WAVE_WARNING_SECONDS)
	local wave = Workspace:WaitForChild("TsunamiWave")
	for step = 1, 40 do
		wave.Position = Vector3.new(0, 2 + step * 0.4, -110 + step * 5)
		task.wait(0.05)
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local state = StateStore.getState(player)
		local character = player.Character
		if state ~= nil and character ~= nil then
			local root = character:FindFirstChild("HumanoidRootPart")
			-- Bebek Karet makes its owner wave-proof; everyone else is safe
			-- only past X = 60, inside their own base. Caught outside, the
			-- wave takes 10% of the player's cash and throws them forward.
			local hasDuck = StateStore.hasPetByName(state, "Bebek Karet")
			local inBase = root ~= nil and math.abs(root.Position.X) > 60
			if not inBase and not hasDuck then
				state.cash = math.floor(state.cash * 0.9)
				if root ~= nil then
					root.AssemblyLinearVelocity = Vector3.new(0, 20, 40)
				end
			end
		end
	end
	wave.Position = Vector3.new(0, -20, -110)
end

task.spawn(function()
	while true do
		task.wait(GameConfig.CART_INTERVAL_SECONDS)
		HazardServer_runawayCart()
	end
end)

task.spawn(function()
	while true do
		task.wait(GameConfig.WAVE_INTERVAL_SECONDS)
		HazardServer_sambalTsunami()
	end
end)
