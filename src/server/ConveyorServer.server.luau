-- ConveyorServer: the night-market parade. Spawns brainrots on the
-- conveyor belt, walks them along it in 3D, and sells the one a player
-- clicks to buy. One job only: spawn, move, sell from the conveyor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotCatalog = require(Shared.BrainrotCatalog)
local BrainrotModels = require(Shared.BrainrotModels)
local GameConfig = require(Shared.GameConfig)
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuyRemote = Remotes:WaitForChild("BuyBrainrot")
local ConveyorUpdate = Remotes:WaitForChild("ConveyorUpdate")

local conveyorFolder = Instance.new("Folder")
conveyorFolder.Name = "ConveyorBrainrots"
conveyorFolder.Parent = Workspace

local live = {}
local rng = Random.new(20261119)

local function spawnConveyorBrainrot()
	if #live >= GameConfig.CONVEYOR_SLOTS then
		return
	end
	local rarity = BrainrotCatalog.rollRarity(rng)
	local pool = BrainrotCatalog.listByRarity(rarity)
	local entry = pool[rng:NextInteger(1, #pool)]
	local mutation = BrainrotCatalog.rollMutation(rng)
	local model = BrainrotModels.buildModel(entry.id, mutation)
	if model == nil then
		return
	end
	model.Parent = conveyorFolder
	local record = {
		model = model,
		brainrotId = entry.id,
		mutation = mutation,
		price = BrainrotCatalog.priceFor(entry.id, mutation),
		x = -GameConfig.CONVEYOR_LENGTH / 2,
	}
	table.insert(live, record)
	ConveyorUpdate:FireAllClients({
		brainrotId = entry.id,
		name = entry.name,
		rarity = entry.rarityName,
		mutation = mutation,
		income = BrainrotCatalog.mutatedIncome(entry.id, mutation),
		price = record.price,
	})
end

function ConveyorServer_tick(dt)
	for i = #live, 1, -1 do
		local record = live[i]
		record.x += 6 * dt
		local body = record.model.PrimaryPart
		if body ~= nil then
			body.Position = Vector3.new(record.x, 2.5, -18)
		end
		if record.x > GameConfig.CONVEYOR_LENGTH / 2 then
			record.model:Destroy()
			table.remove(live, i)
		end
	end
end

function ConveyorServer_buyBrainrot(player, brainrotName)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	local slotIndex = nil
	for i, record in ipairs(live) do
		if BrainrotCatalog.getBrainrot(record.brainrotId).name == brainrotName then
			slotIndex = i
			break
		end
	end
	local record = slotIndex ~= nil and live[slotIndex] or nil
	if record == nil then
		return
	end
	if state.cash < record.price then
		return
	end
	local ok, err = StateStore.addBrainrot(state, record.brainrotId, record.mutation)
	if not ok then
		BuyRemote:FireClient(player, { ok = false, message = err })
		return
	end
	state.cash -= record.price
	record.model:Destroy()
	table.remove(live, slotIndex)
	BuyRemote:FireClient(player, { ok = true, name = BrainrotCatalog.getBrainrot(record.brainrotId).name })
end

BuyRemote.OnServerEvent:Connect(function(player, brainrotName)
	ConveyorServer_buyBrainrot(player, brainrotName)
end)

task.spawn(function()
	while true do
		spawnConveyorBrainrot()
		task.wait(GameConfig.CONVEYOR_SPAWN_SECONDS)
	end
end)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function(dt)
	ConveyorServer_tick(dt)
end)
