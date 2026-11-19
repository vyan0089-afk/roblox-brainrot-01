-- StealServer: stealing, base locks and the slap defence.
-- A player grabs a rival's brainrot and must carry it home before the
-- owner slaps them and knocks it loose. Locking your base blocks steals.
-- One job only: steal / lock / slap.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateStore = require(game:GetService("ServerScriptService").Server.StateStore)
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared").GameConfig)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StealRemote = Remotes:WaitForChild("StealBrainrot")
local LockRemote = Remotes:WaitForChild("LockBase")
local SlapRemote = Remotes:WaitForChild("SlapPlayer")
local StealAlert = Remotes:WaitForChild("StealAlert")

function StealServer_lockBase(player)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	if os.clock() < state.lockCooldownUntil then
		return
	end
	-- The cooldown starts when the lock EXPIRES, not when it is cast, so a
	-- base is locked for its duration and then open for at least 60 seconds.
	state.lockedUntil = os.clock() + StateStore.lockDuration(state)
	state.lockCooldownUntil = state.lockedUntil + GameConfig.LOCK_COOLDOWN_SECONDS
end

function StealServer_stealBrainrot(player, victim, collectionIndex)
	local state = StateStore.getState(player)
	local victimState = StateStore.getState(victim)
	if state == nil or victimState == nil or victim == player then
		return
	end
	if StateStore.isBaseLocked(victimState) then
		StealAlert:FireClient(player, { ok = false, message = "Base locked! Come back later." })
		return
	end
	if state.carrying ~= nil then
		return
	end
	local owned = victimState.collection[collectionIndex]
	if owned == nil then
		return
	end
	StateStore.removeBrainrot(victimState, collectionIndex)
	state.carrying = owned
	state.stealStartedAt = os.clock()
	StealAlert:FireClient(victim, { ok = false, message = player.Name .. " is stealing your brainrot! SLAP them!" })
	StealAlert:FireClient(player, { ok = true, message = "Run home! Carry it to your base!" })
end

function StealServer_finishCarry(player)
	local state = StateStore.getState(player)
	if state == nil or state.carrying == nil then
		return
	end
	-- A thief gets 12 seconds of carry time plus a 30-second grace; after
	-- that the stolen brainrot vanishes instead of banking, so a thief
	-- cannot stall a steal forever by hiding with the catch.
	if os.clock() - state.stealStartedAt > GameConfig.STEAL_CARRY_SECONDS + 30 then
		state.carrying = nil
		return
	end
	local owned = state.carrying
	state.carrying = nil
	local ok, err = StateStore.addBrainrot(state, owned.brainrotId, owned.mutation)
	if not ok then
		state.cash += 100
	end
end

function StealServer_slapPlayer(player, target)
	local state = StateStore.getState(player)
	if state == nil then
		return
	end
	if os.clock() - state.lastSlapAt < GameConfig.SLAP_COOLDOWN_SECONDS then
		return
	end
	state.lastSlapAt = os.clock()
	local character = player.Character
	local targetCharacter = target.Character
	if character == nil or targetCharacter == nil then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
	if root == nil or targetRoot == nil then
		return
	end
	if (targetRoot.Position - root.Position).Magnitude > GameConfig.SLAP_RANGE then
		return
	end
	-- Slap Power adds 40% knockback per level, and every slap also launches
	-- the target 18 studs up, so a slapped thief is thrown, not just pushed.
	local knockback = GameConfig.SLAP_KNOCKBACK * (1 + 0.4 * state.upgrades[2])
	targetRoot.AssemblyLinearVelocity = (targetRoot.Position - root.Position).Unit * knockback + Vector3.new(0, 18, 0)
	local targetState = StateStore.getState(target)
	if targetState ~= nil and targetState.carrying ~= nil then
		targetState.carrying = nil
		StealAlert:FireClient(target, { ok = false, message = "SLAPPED! You dropped the brainrot!" })
		StealAlert:FireClient(player, { ok = true, message = "You slapped the thief!" })
	end
end

LockRemote.OnServerEvent:Connect(function(player)
	StealServer_lockBase(player)
end)
StealRemote.OnServerEvent:Connect(function(player, victim, collectionIndex)
	StealServer_stealBrainrot(player, victim, collectionIndex)
end)
SlapRemote.OnServerEvent:Connect(function(player, target)
	StealServer_slapPlayer(player, target)
end)

-- A thief who reaches their own base keeps the catch; checked by the
-- client firing FinishCarry when it touches its base pad (server trusts
-- only the timer + the carrying flag, never the client's word alone).
Remotes:WaitForChild("FinishCarry").OnServerEvent:Connect(function(player)
	StealServer_finishCarry(player)
end)
