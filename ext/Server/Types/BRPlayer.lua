class "BRPlayer"

local m_InventoryManager = require "BRInventoryManager"
local m_GameStateManager = require "GameStateManager"
local m_Logger = Logger("BRPlayer", true)

function BRPlayer:__init(p_Player)
	-- the vanilla player instance of the player
	self.m_Player = p_Player

	-- the BRTeam that the player is part of
	self.m_Team = nil

	-- indicates if the player is the leader of the team
	self.m_IsTeamLeader = false

	-- indicates if the player joined the team by code
	self.m_JoinedByCode = false

	-- if a player quits per esc menu this will be set to true
	self.m_QuitManually = false

	-- the name of the player who killed this BRPlayer
	self.m_KillerName = nil

	-- the names of players who spectate this BRPlayer
	self.m_SpectatedPlayerName = nil
	self.m_SpectatorNames = {}

	-- the position of the player in the squad
	self.m_PosInSquad = 1

	-- the user selected strategy that is used when the teams are formed
	self.m_TeamJoinStrategy = TeamJoinStrategy.AutoJoin

	-- the player's inventory
	self.m_Inventory = nil

	-- The kill count of the player
	self.m_Kills = 0

	-- The score count of the player
	self.m_Score = 0

	-- The appearance name
	self.m_Appearance = "Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Assault_Appearance_Wood01"

	-- Apply the Appearance so the client has the correct soldiermodel in the deploy screen when joining
	self:SetAppearance(nil, true)
end

-- =============================================
-- Hooks
-- =============================================

function BRPlayer:OnDamaged(p_Damage, p_Giver, p_IsHeadShot)
	-- check if giver isnt a teammate or the player himself
	if p_Giver ~= nil and self:IsTeammate(p_Giver) and not self:Equals(p_Giver) then
		return 0
	end

	if p_Giver ~= nil then
		NetEvents:SendToLocal(DamageEvent.Hit, p_Giver.m_Player, p_Damage)
	end

	local s_Soldier = self:GetSoldier()
	if s_Soldier == nil then
		return p_Damage
	end

	local s_Health = s_Soldier.health
	if s_Soldier.isInteractiveManDown and p_Damage >= s_Health then
		self:Kill(true)
		Events:DispatchLocal(TeamManagerEvent.RegisterKill, self, p_Giver)

		return s_Health
	elseif not s_Soldier.isInteractiveManDown then
		s_Health = s_Health - 100

		-- apply damage to helmet and armor
		if p_Giver ~= nil and not self:Equals(p_Giver) then
			p_Damage = self:ApplyDamageToProtectiveItem(p_IsHeadShot and self:GetHelmet(), p_Damage, p_Giver)
			p_Damage = self:ApplyDamageToProtectiveItem(self:GetArmor(), p_Damage, p_Giver)
		end

		self.m_Inventory:DeferSendState()

		if p_Damage >= s_Health then
			-- kill instantly if no teammates left
			if self:HasAliveTeammates() then
				if p_Giver ~= nil then
					self.m_KillerName = p_Giver:GetName()
					NetEvents:SendToLocal(DamageEvent.PlayerDown, p_Giver.m_Player, self:GetName())
				else
					self.m_KillerName = nil
				end

				-- start mandown damage timer
				g_Timers:Interval(1, self, self.OnManDownDamage)
			else
				self.m_KillerName = nil -- TODO move to onRevive
				self:Kill(true)

				-- finish the mandown teammates
				self:FinishTeammates()

				Events:DispatchLocal(TeamManagerEvent.RegisterKill, self, p_Giver)
			end

			return s_Health
		end
	end

	return math.max(0.001, p_Damage)
end

function BRPlayer:ApplyDamageToProtectiveItem(p_Item, p_Damage, p_Giver)
	if not p_Item then
		return p_Damage
	end

	local s_WasDestroyed
	p_Damage, s_WasDestroyed = p_Item:ApplyDamage(p_Damage)

	-- if item was destroyed, remove it from inventory
	if s_WasDestroyed then
		-- if it's armor, send an event that it broke
		if p_Item.m_Definition.m_Type == ItemType.Armor then
			NetEvents:SendToLocal("Player:BrokeShield", p_Giver.m_Player, self:GetName())
		end

		self.m_Inventory:DestroyItem(p_Item.m_Id)
	end

	return p_Damage
end

-- =============================================
-- Functions
-- =============================================

-- =============================================
	-- Player Damage/ Kill Functions
-- =============================================

-- Increments the kill counter of the player
function BRPlayer:IncrementKills(p_Victim)
	if p_Victim == nil or not self:Equals(p_Victim) then
		self.m_Kills = self.m_Kills + 1
		self:SendState()
	end

	-- send related net events
	NetEvents:SendToLocal(DamageEvent.PlayerKill, self:GetPlayer(), p_Victim:GetName())
	NetEvents:SendToLocal(DamageEvent.PlayerKilled, p_Victim.m_Player, self:GetName())
end

function BRPlayer:OnManDownDamage(p_Timer)
	local s_Soldier = self:GetSoldier()

	-- check if not in interactiveManDown
	if s_Soldier == nil or not s_Soldier.isInteractiveManDown then
		local s_Player = self:GetPlayer()

		-- check if dead
		if s_Player ~= nil and not s_Player.alive then
			Events:DispatchLocal(TeamManagerEvent.RegisterKill, self, nil)
		end

		p_Timer:Destroy()
		return
	end

	-- apply damage
	s_Soldier.health = math.max(0, s_Soldier.health - 1)
end

-- Kills the player
-- @param p_Forced (optional) calls :ForceDead() instead of :Kill()
function BRPlayer:Kill(p_Forced)
	-- check if alive
	if not self.m_Player.alive then
		return false
	end

	p_Forced = not (not p_Forced)

	-- get soldier entity
	local s_Soldier = self:GetSoldier()

	if s_Soldier == nil then
		return true -- TODO maybe should return false
	end

	-- TODO removed ForceDead(), it causes crashes
	if p_Forced then
		s_Soldier:ForceDead()
	else
		s_Soldier:Kill()
	end

	return true
end

function BRPlayer:FinishTeammates()
	return self.m_Team ~= nil and self.m_Team:FinishPlayers(self)
end

-- =============================================
	-- Player Spawn Functions
-- =============================================

function BRPlayer:Spawn(p_Trans, p_MatchStarted)
	-- check if alive
	if self:IsAlive() then
		return
	end

	if p_Trans == nil then
		m_Logger:Write("Spawn transform is invalid.")
		return
	end

	if self.m_Player.selectedKit == nil then
		local s_SoldierBlueprint = ResourceManager:SearchForDataContainer("Characters/Soldiers/MpSoldier")

		if s_SoldierBlueprint == nil then
			m_Logger:Error("Couldn\'t find the SoldierBlueprint")
			return
		end

		self.m_Player.selectedKit = s_SoldierBlueprint
	end

	self:SetAppearance(nil, true)

	local s_Pistol = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
		Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),
		Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B")))
	self.m_Player:SelectWeapon(WeaponSlot.WeaponSlot_0, s_Pistol, {})

	local s_Inventory = m_InventoryManager:GetOrCreateInventory(self.m_Player)
	s_Inventory:DeferUpdateSoldierCustomization(0.85)
	s_Inventory:SendState()

	local s_Event = ServerPlayerEvent("Spawn", self.m_Player, true, false, false, false, false, false, self.m_Player.teamId)
	local s_EntityIterator = EntityManager:GetIterator("ServerCharacterSpawnEntity")
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("67A2C146-9CC0-E7EC-5227-B2DCB9D316C1") then
			local s_CharacterSpawnReferenceObjectData = CharacterSpawnReferenceObjectData(s_Entity.data)
			s_CharacterSpawnReferenceObjectData:MakeWritable()
			s_CharacterSpawnReferenceObjectData.blueprintTransform = p_Trans

			-- spawn the player
			s_Entity:FireEvent(s_Event)

			m_Logger:Write("Spawning player " .. self.m_Player.name)
			break
		end

		s_Entity = s_EntityIterator:Next()
	end

	g_Timers:Interval(0.01, self.m_Player, function(p_Player, p_Timer)
		if p_Player.soldier ~= nil then
			-- the ApplyCustomization is needed otherwise the transform will reset to Vec3(1,0,0) Vec3(0,1,0) Vec3(0,0,1)
			p_Player.soldier:ApplyCustomization(self:CreateCustomizeSoldierData())
			p_Player.soldier:SetTransform(p_Trans)

			if p_MatchStarted then
				-- we need this to replace crashed/ disconnected players with bots
				self:RegisterUnspawnCallback(p_Player.soldier)
			end

			-- we are done, so we can destroy this timer
			p_Timer:Destroy()
		end
	end)
end

function BRPlayer:RegisterUnspawnCallback(p_Soldier)
	p_Soldier:RegisterUnspawnCallback(function(p_Entity)
		if m_GameStateManager:IsGameState(GameStates.EndGame) then
			return
		end

		p_Entity = SoldierEntity(p_Entity)

		if p_Entity.player ~= nil and not self.m_QuitManually and p_Entity.isAlive then
			self:ReplaceSoldierWithBot(p_Entity)
		else
			-- TODO: drop his loot
		end
	end)
end

function BRPlayer:ReplaceSoldierWithBot(p_Soldier)
	local s_Bot = PlayerManager:CreatePlayer(p_Soldier.player.name, p_Soldier.player.teamId, p_Soldier.player.squadId)

	if s_Bot == nil then
		m_Logger:Warning("Couldn't create bot player: " .. p_Soldier.player.name)
		return
	end

	local s_SoldierBlueprint = SoldierBlueprint(ResourceManager:SearchForDataContainer("Characters/Soldiers/MpSoldier"))
	local s_VeniceSoldierCustomizationAsset = VeniceSoldierCustomizationAsset(ResourceManager:SearchForDataContainer("Gameplay/Kits/RUAssault"))

	-- Get it from BRPlayer.m_Appearance
	local s_VisualUnlockAsset = UnlockAsset(ResourceManager:SearchForDataContainer("persistence/unlocks/soldiers/visual/mp/us/mp_us_assault_appearance01"))

	local s_Pistol = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
		Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),
		Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B")))
	self.m_Player:SelectWeapon(WeaponSlot.WeaponSlot_0, s_Pistol, {})

	local s_Inventory = m_InventoryManager:GetOrCreateInventory(self.m_Player)
	s_Inventory:DeferUpdateSoldierCustomization(0.85)
	s_Inventory:SendState()

	s_Bot:SelectUnlockAssets(s_VeniceSoldierCustomizationAsset, {s_VisualUnlockAsset})
	local s_Soldier = s_Bot:CreateSoldier(s_SoldierBlueprint, p_Soldier.transform)

	-- copy health
	s_Soldier.health = p_Soldier.health

	-- copy transform & characterpose
	s_Bot:SpawnSoldierAt(s_Soldier, p_Soldier.transform, p_Soldier.pose)
	s_Bot:AttachSoldier(s_Soldier)

	self.m_Player = s_Bot

	m_Logger:Write("Replaced player with bot: " .. s_Bot.name)
end

function BRPlayer:ReplaceBotSoldierWithPlayer(p_BotSoldier)
	local s_SoldierBlueprint = SoldierBlueprint(ResourceManager:SearchForDataContainer("Characters/Soldiers/MpSoldier"))
	local s_VeniceSoldierCustomizationAsset = VeniceSoldierCustomizationAsset(ResourceManager:SearchForDataContainer("Gameplay/Kits/RUAssault"))

	-- Get it from BRPlayer.m_Appearance
	local s_VisualUnlockAsset = UnlockAsset(ResourceManager:SearchForDataContainer("persistence/unlocks/soldiers/visual/mp/us/mp_us_assault_appearance01"))

	local s_Pistol = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
		Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),
		Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B")))
	self.m_Player:SelectWeapon(WeaponSlot.WeaponSlot_0, s_Pistol, {})

	local s_Inventory = m_InventoryManager:GetOrCreateInventory(self.m_Player)
	s_Inventory:DeferUpdateSoldierCustomization(0.85)
	s_Inventory:SendState()

	self.m_Player:SelectUnlockAssets(s_VeniceSoldierCustomizationAsset, {s_VisualUnlockAsset})
	local s_Soldier = self.m_Player:CreateSoldier(s_SoldierBlueprint, p_BotSoldier.transform)

	-- copy health
	s_Soldier.health = p_BotSoldier.health

	-- copy transform & characterpose
	self.m_Player:SpawnSoldierAt(s_Soldier, p_BotSoldier.transform, p_BotSoldier.pose)
	self.m_Player:AttachSoldier(s_Soldier)

	m_Logger:Write("Replaced bot with player: " .. self.m_Player.name)
end

-- TODO move to a util
function BRPlayer:CreateCustomizeSoldierData()
	local s_CustomizeSoldierData = CustomizeSoldierData()
	s_CustomizeSoldierData.restoreToOriginalVisualState = false
	s_CustomizeSoldierData.clearVisualState = true
	s_CustomizeSoldierData.overrideMaxHealth = -1.0
	s_CustomizeSoldierData.overrideCriticalHealthThreshold = -1.0

	local s_UnlockWeaponAndSlot7 = UnlockWeaponAndSlot()
	s_UnlockWeaponAndSlot7.weapon = SoldierWeaponUnlockAsset(
		ResourceManager:FindInstanceByGuid(Guid("0003DE1B-F3BA-11DF-9818-9F37AB836AC2"),Guid("8963F500-E71D-41FC-4B24-AE17D18D8C73"))
	)
	s_UnlockWeaponAndSlot7.slot = WeaponSlot.WeaponSlot_7
	s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot7)

	local s_UnlockWeaponAndSlot9 = UnlockWeaponAndSlot()
	s_UnlockWeaponAndSlot9.weapon = SoldierWeaponUnlockAsset(
		ResourceManager:FindInstanceByGuid(Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B"))
	)
	s_UnlockWeaponAndSlot9.slot = WeaponSlot.WeaponSlot_9
	s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot9)

	s_CustomizeSoldierData.activeSlot = WeaponSlot.WeaponSlot_7
	s_CustomizeSoldierData.removeAllExistingWeapons = true
	s_CustomizeSoldierData.disableDeathPickup = false

	return s_CustomizeSoldierData
end

-- =============================================
	-- Spectator Functions
-- =============================================

function BRPlayer:SpectatePlayer(p_BrPlayer)
	if p_BrPlayer == nil then
		self.m_SpectatedPlayerName = nil
		return
	end

	self.m_SpectatedPlayerName = p_BrPlayer:GetName()

	-- send inventory data of the spectated player
	if p_BrPlayer.m_Inventory ~= nil then
		local _, s_SpectatorData = p_BrPlayer.m_Inventory:AsTable(true)
		m_Logger:Write(json.encode(s_SpectatorData))
		NetEvents:SendToLocal(InventoryNetEvent.InventoryState, self:GetPlayer(), s_SpectatorData)
	end
end

function BRPlayer:AddSpectator(p_PlayerName)
	if self.m_SpectatorNames[p_PlayerName] == nil then
		table.insert(self.m_SpectatorNames, p_PlayerName)
	end

	NetEvents:SendToLocal("UpdateSpectatorCount", self.m_Player, #self.m_SpectatorNames)
end

function BRPlayer:RemoveSpectator(p_PlayerName)
	for i, l_PlayerName in pairs(self.m_SpectatorNames) do
		if l_PlayerName == p_PlayerName then
			table.remove(self.m_SpectatorNames, i)
			NetEvents:SendToLocal("UpdateSpectatorCount", self.m_Player, #self.m_SpectatorNames)
			return
		end
	end
end

-- =============================================
	-- Other Functions
-- =============================================

-- Updates the vanilla player team/squad Ids
function BRPlayer:ApplyTeamSquadIds()
	-- ensure that the player is dead
	if self.m_Player ~= nil and not self.m_Player.alive then
		self.m_Player.teamId = (self.m_Team ~= nil and self.m_Team.m_TeamId) or TeamId.Team1
		self.m_Player.squadId = (self.m_Team ~= nil and self.m_Team.m_SquadId) or SquadId.SquadNone
	end
end

function BRPlayer:SendEventToSpectators(p_EventName, ...)
	for i, l_SpectatorName in pairs(self.m_SpectatorNames) do
		local s_Spectator = PlayerManager:GetPlayerByName(l_SpectatorName)

		if s_Spectator ~= nil then
			m_Logger:WriteF("Send '%s' to spectator '%s'", p_EventName, s_Spectator.name)
			NetEvents:SendToLocal(p_EventName, s_Spectator, table.unpack({...}))
		else
			table.remove(self.m_SpectatorNames, i)
			NetEvents:SendToLocal("UpdateSpectatorCount", self.m_Player, #self.m_SpectatorNames)
		end
	end
end

function BRPlayer:SendState(p_Simple, p_TeamData)
	local s_Data = self:AsTable(p_Simple, p_TeamData)
	NetEvents:SendToLocal(TeamManagerNetEvent.PlayerState, self.m_Player, s_Data)
end

-- Resets the state of a player
function BRPlayer:Reset()
	self.m_Kills = 0
	self.m_Score = 0
	self.m_KillerName = nil
	self.m_SpectatedPlayerName = nil
	self.m_SpectatorNames = {}

	self:SendState()
end

function BRPlayer:Destroy()
	self:LeaveTeam(true)

	self.m_KillerName = nil
	self.m_Player = nil
	self.m_Team = nil
	self.m_SpectatedPlayerName = nil
	self.m_SpectatorNames = {}
end

-- Alias for `BRTeam:RemovePlayer()`
function BRPlayer:LeaveTeam(p_Forced, p_IgnoreBroadcast)
	if self.m_Team ~= nil then
		return self.m_Team:RemovePlayer(self, p_Forced, p_IgnoreBroadcast)
	end

	return false
end

-- =============================================
-- Set Functions
-- =============================================

function BRPlayer:SetTeamJoinStrategy(p_Strategy)
	if self.m_TeamJoinStrategy == p_Strategy then
		return
	end

	self.m_TeamJoinStrategy = p_Strategy

	if p_Strategy ~= TeamJoinStrategy.Custom then
		if self:LeaveTeam() then
			Events:DispatchLocal(TeamManagerEvent.PutOnATeam, self)
		else
			self.m_Team:SetLock(self, true)
		end
	else
		self.m_Team:SetLock(self, false)
	end

	self:SendState()
end

function BRPlayer:SetAppearance(p_AppearanceName, p_RefreshPlayer)
	if p_AppearanceName ~= nil then
		self.m_Appearance = p_AppearanceName
	end

	if p_RefreshPlayer then
		local s_SoldierAsset = ResourceManager:SearchForDataContainer("Gameplay/Kits/RUAssault")
		local s_Appearance = ResourceManager:SearchForDataContainer(self.m_Appearance)

		if s_SoldierAsset == nil or s_Appearance == nil then
			return
		end

		self.m_Player:SelectUnlockAssets(s_SoldierAsset, {s_Appearance})
	end
end

function BRPlayer:SetQuitManually(p_QuitManually)
	self.m_QuitManually = p_QuitManually
end

-- =============================================
	-- Get Functions
-- =============================================

-- Returns the username of the player
function BRPlayer:GetName()
	local s_Player = self:GetPlayer()
	return (s_Player ~= nil and s_Player.name) or nil
end

-- TODO
-- This should be used instead of keeping player reference
function BRPlayer:GetPlayer()
	-- return PlayerManager:GetPlayerByName(self.m_PlayerName)
	return self.m_Player
end

-- Returns the soldier object, if exists, or nil
function BRPlayer:GetSoldier()
	local s_Player = self:GetPlayer()
	return (s_Player ~= nil and s_Player.soldier) or nil
end

-- Returns the position of the player if alive
-- @return Vec3|nil
function BRPlayer:GetPosition()
	local s_Soldier = self:GetSoldier()

	if s_Soldier == nil then
		return nil
	end

	return s_Soldier.transform.trans
end

-- Returns the current armor item equipped by the player
function BRPlayer:GetArmor()
	return (self.m_Inventory ~= nil and self.m_Inventory:GetSlot(InventorySlot.Armor).m_Item) or nil
end

-- Returns the current helmet item equipped by the player
function BRPlayer:GetHelmet()
	return (self.m_Inventory ~= nil and self.m_Inventory:GetSlot(InventorySlot.Helmet).m_Item) or nil
end

-- Checks if the player is alive
function BRPlayer:IsAlive()
	local s_Player = self:GetPlayer()
	return s_Player ~= nil and s_Player.alive
end

-- Checks if the player and `p_OtherBrPlayer` are on the same team
function BRPlayer:IsTeammate(p_OtherBrPlayer)
	return self.m_Team ~= nil and self.m_Team:Equals(p_OtherBrPlayer.m_Team)
end

-- Checks if the player has any alive teammates
function BRPlayer:HasAliveTeammates()
	return self.m_Team ~= nil and self.m_Team:HasAlivePlayers(self, true)
end

-- Compare two BRPlayer instances for equality
function BRPlayer:Equals(p_OtherBrPlayer)
	return p_OtherBrPlayer ~= nil and self:GetName() == p_OtherBrPlayer:GetName()
end

-- `==` metamethod
function BRPlayer:__eq(p_OtherBrPlayer)
	return self:Equals(p_OtherBrPlayer)
end

function BRPlayer:AsTable(p_Simple, p_TeamData)
	-- state used for squad members
	if p_Simple then
		-- TODO remove it
		local s_State = BRPlayerState.Dead
		local s_Soldier = self:GetSoldier()

		if self:IsAlive() and s_Soldier ~= nil then
			if s_Soldier.isAlive then
				s_State = BRPlayerState.Alive
			elseif s_Soldier.isInteractiveManDown then
				s_State = BRPlayerState.Down
			end
		end

		return {
			Name = self:GetName(),
			IsTeamLeader = self.m_IsTeamLeader,
			State = s_State,
			PosInSquad = self.m_PosInSquad
		}
	end

	-- get team data
	local s_Team = p_TeamData
	if s_Team == nil and self.m_Team ~= nil then
		s_Team = self.m_Team:AsTable()
	end

	-- state used for local player
	return {
		Team = s_Team,
		Data = {
			TeamJoinStrategy = self.m_TeamJoinStrategy,
			IsTeamLeader = self.m_IsTeamLeader,
			Kills = self.m_Kills,
			Score = self.m_Score,
			PosInSquad = self.m_PosInSquad
		}
	}
end

-- A helper function to get the name of the player
-- * p_Player is string			--> p_Player
-- * p_Player is vanilla player --> p_Player.name
-- * p_Player is BRPlayer		--> p_Player.m_Player.name
-- * else						--> nil
function BRPlayer.static:GetPlayerName(p_Player)
	return (type(p_Player) == "string" and p_Player) or (type(p_Player) == "userdata" and p_Player.name) or
				(type(p_Player) == "table" and p_Player:GetName()) or nil
end

-- Garbage collector metamethod
function BRPlayer:__gc()
	self:Destroy()
end
