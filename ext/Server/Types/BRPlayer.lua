---@class BRPlayer
---@field GetPlayerName fun(p_Player : Player|BRPlayer|string)
BRPlayer = class "BRPlayer"

---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
---@type BRInventoryManager
local m_InventoryManager = require "BRInventoryManager"
---@type Logger
local m_Logger = Logger("BRPlayer", true)

---@param p_Player Player
function BRPlayer:__init(p_Player)
	-- the vanilla player instance of the player
	self.m_Player = p_Player

	-- the BRTeam that the player is part of
	---@type BRTeam|nil
	self.m_Team = nil

	-- indicates if the player is the leader of the team
	self.m_IsTeamLeader = false

	-- indicates if the player joined the team by code
	self.m_JoinedByCode = false

	-- the name of the player who killed this BRPlayer
	---@type string|nil
	self.m_KillerName = nil

	-- the name of player who this BRPlayer is spectating
	---@type string|nil
	self.m_SpectatedPlayerName = nil
	-- the names of players who spectate this BRPlayer
	---@type string[]
	self.m_SpectatorNames = {}

	-- the position of the player in the squad
	self.m_PosInSquad = 1

	-- the user selected strategy that is used when the teams are formed
	---@type TeamJoinStrategy|integer
	self.m_TeamJoinStrategy = TeamJoinStrategy.AutoJoin

	-- the player's inventory
	---@type BRInventory
	self.m_Inventory = nil

	-- The kill count of the player
	self.m_Kills = 0

	-- The score count of the player
	self.m_Score = 0

	-- The received revive count of the player
	self.m_ReceivedRevives = 0

	-- The given revive count of the player
	self.m_GivenRevives = 0

	-- The headshot count of the player (when downing/killing an enemy)
	self.m_Headshots = 0

	-- The amount of damage this player dealt
	self.m_DamageDealt = 0.0

	-- The downed enemies count
	self.m_DownedEnemies = 0

	-- The appearance name
	self.m_Appearance = "Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Assault_Appearance_Wood01"

	-- Apply the Appearance so the client has the correct soldiermodel in the deploy screen when joining
	self:SetAppearance(nil, true)
end

-- =============================================
-- Hooks
-- =============================================

---Calculate the new damage
---@param p_Damage number
---@param p_Giver BRPlayer|nil
---@param p_IsHeadShot boolean
---@return number
function BRPlayer:OnDamaged(p_Damage, p_Giver, p_IsHeadShot)
	-- check if giver isnt a teammate or the player himself
	if p_Giver ~= nil and self:IsTeammate(p_Giver) and not self:Equals(p_Giver) then
		return 0.0
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
			-- for stats
			if p_IsHeadShot and p_Giver ~= nil and not self:Equals(p_Giver) then
				p_Giver:IncreaseHeadshotCount()
			end

			-- kill instantly if no teammates left
			if self:HasAliveTeammates() then
				if p_Giver ~= nil and not self:Equals(p_Giver) then
					self.m_KillerName = p_Giver:GetName()
					NetEvents:SendToLocal(DamageEvent.PlayerDown, p_Giver.m_Player, self:GetName())
					p_Giver:IncreaseDownedEnemies()
				else
					self.m_KillerName = nil
				end

				-- start mandown damage timer
				m_TimerManager:Interval(1, self, self.OnManDownDamage)
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

---@param p_Item BRItemArmor|BRItemHelmet|nil
---@param p_Damage number
---@param p_Giver BRPlayer
---@return number
function BRPlayer:ApplyDamageToProtectiveItem(p_Item, p_Damage, p_Giver)
	if not p_Item then
		return p_Damage
	end

	---@type boolean
	local s_WasDestroyed = nil
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

---Increments the kill counter of the player
---@param p_Victim BRPlayer
function BRPlayer:IncrementKills(p_Victim)
	if p_Victim == nil or not self:Equals(p_Victim) then
		self.m_Kills = self.m_Kills + 1
		self:SendState()
	end

	-- send related net events
	NetEvents:SendToLocal(DamageEvent.PlayerKill, self:GetPlayer(), p_Victim:GetName())
	NetEvents:SendToLocal(DamageEvent.PlayerKilled, p_Victim.m_Player, self:GetName())
end

---Gets called every second if mandown
---@param p_Timer Timer
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

---Kills the player
---@param p_Forced boolean (optional) calls :ForceDead() instead of :Kill()
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

	if p_Forced then
		s_Soldier:ForceDead()
	else
		s_Soldier:Kill()
	end

	return true
end

---Finish all teammates.
---Doesn't really return something
function BRPlayer:FinishTeammates()
	return self.m_Team ~= nil and self.m_Team:FinishPlayers(self)
end

-- =============================================
	-- Player Spawn Functions
-- =============================================

---@param p_Transform LinearTransform
function BRPlayer:Spawn(p_Transform)
	-- check if alive
	if self:IsAlive() then
		return
	end

	if p_Transform == nil then
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
	local s_CustomizeSoldierData = s_Inventory:CreateCustomizeSoldierData()
	s_Inventory:SendState()

	local s_Event = ServerPlayerEvent("Spawn", self.m_Player, true, false, false, false, false, false, self.m_Player.teamId)
	local s_EntityIterator = EntityManager:GetIterator("ServerCharacterSpawnEntity")
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("67A2C146-9CC0-E7EC-5227-B2DCB9D316C1") then
			local s_CharacterSpawnReferenceObjectData = CharacterSpawnReferenceObjectData(s_Entity.data)
			s_CharacterSpawnReferenceObjectData:MakeWritable()
			s_CharacterSpawnReferenceObjectData.blueprintTransform = p_Transform

			-- spawn the player
			s_Entity:FireEvent(s_Event)

			m_Logger:Write("Spawning player " .. self.m_Player.name)
			break
		end

		s_Entity = s_EntityIterator:Next()
	end

	---@param p_PlayerName string
	---@param p_Timer Timer
	m_TimerManager:Interval(0.01, self.m_Player.name, function(p_PlayerName, p_Timer)
		local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)

		if s_Player == nil then
			m_Logger:Error("We couldn\'t find the player " .. p_PlayerName)
			p_Timer:Destroy()
		elseif s_Player.soldier ~= nil then
			-- the ApplyCustomization is needed otherwise the transform will reset to Vec3(1,0,0) Vec3(0,1,0) Vec3(0,0,1)
			s_Player.soldier:ApplyCustomization(s_CustomizeSoldierData)
			s_Player.soldier:SetTransform(p_Transform)
			-- we are done, so we can destroy this timer
			p_Timer:Destroy()
		end
	end)
end

-- =============================================
	-- Spectator Functions
-- =============================================

---@param p_BRPlayer BRPlayer|nil
function BRPlayer:SpectatePlayer(p_BRPlayer)
	if p_BRPlayer == nil then
		self.m_SpectatedPlayerName = nil
		return
	end

	self.m_SpectatedPlayerName = p_BRPlayer:GetName()

	-- send inventory data of the spectated player
	if p_BRPlayer.m_Inventory ~= nil then
		local _, s_SpectatorData = p_BRPlayer.m_Inventory:AsTable(true)
		m_Logger:Write(json.encode(s_SpectatorData))
		NetEvents:SendToLocal(InventoryNetEvent.InventoryState, self:GetPlayer(), s_SpectatorData)
	end
end

---@param p_PlayerName string|nil
function BRPlayer:AddSpectator(p_PlayerName)
	if self.m_SpectatorNames[p_PlayerName] == nil then
		table.insert(self.m_SpectatorNames, p_PlayerName)
	end

	NetEvents:SendToLocal("UpdateSpectatorCount", self.m_Player, #self.m_SpectatorNames)
end

---@param p_PlayerName string
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

---Updates the vanilla player team/squad Ids
function BRPlayer:ApplyTeamSquadIds()
	-- ensure that the player is dead
	if self.m_Player ~= nil and not self.m_Player.alive then
		self.m_Player.teamId = (self.m_Team ~= nil and self.m_Team.m_TeamId) or TeamId.Team1
		self.m_Player.squadId = (self.m_Team ~= nil and self.m_Team.m_SquadId) or SquadId.SquadNone
	end
end

---@param p_EventName string
---@vararg any
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
	self.m_ReceivedRevives = 0
	self.m_GivenRevives = 0
	self.m_Headshots = 0
	self.m_DamageDealt = 0.0
	self.m_DownedEnemies = 0
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
---@param p_Forced boolean
---@param p_IgnoreBroadcast boolean
---@return boolean
function BRPlayer:LeaveTeam(p_Forced, p_IgnoreBroadcast)
	if self.m_Team ~= nil then
		return self.m_Team:RemovePlayer(self, p_Forced, p_IgnoreBroadcast)
	end

	return false
end

-- =============================================
	-- Some stat functions
-- =============================================

function BRPlayer:IncreaseReceivedRevives()
	self.m_ReceivedRevives = self.m_ReceivedRevives + 1
end

function BRPlayer:IncreaseGivenRevives()
	self.m_GivenRevives = self.m_GivenRevives + 1
end

function BRPlayer:IncreaseHeadshotCount()
	self.m_Headshots = self.m_Headshots + 1
end

function BRPlayer:IncreaseDamageDealt(p_Damage)
	self.m_DamageDealt = self.m_DamageDealt + p_Damage
end

function BRPlayer:IncreaseDownedEnemies()
	self.m_DownedEnemies = self.m_DownedEnemies + 1
end

-- =============================================
	-- Set Functions
-- =============================================

---@param p_Strategy TeamJoinStrategy|integer
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

---@param p_AppearanceName string|nil
---@param p_RefreshPlayer boolean
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

-- =============================================
	-- Get Functions
-- =============================================

---Returns the username of the player
---@return string|nil
function BRPlayer:GetName()
	local s_Player = self:GetPlayer()
	return (s_Player ~= nil and s_Player.name) or nil
end

-- TODO
-- This should be used instead of keeping player reference
---@return Player
function BRPlayer:GetPlayer()
	-- return PlayerManager:GetPlayerByName(self.m_PlayerName)
	return self.m_Player
end

---Returns the soldier object, if exists, or nil
---@return SoldierEntity|nil
function BRPlayer:GetSoldier()
	local s_Player = self:GetPlayer()
	return (s_Player ~= nil and s_Player.soldier) or nil
end

---Returns the position of the player if alive
---@return Vec3|nil
function BRPlayer:GetPosition()
	local s_Soldier = self:GetSoldier()

	if s_Soldier == nil then
		return nil
	end

	return s_Soldier.transform.trans
end

---Returns the current armor item equipped by the player
---@return BRItemArmor|nil
function BRPlayer:GetArmor()
	return (self.m_Inventory ~= nil and self.m_Inventory:GetSlot(InventorySlot.Armor).m_Item) or nil
end

---Returns the current helmet item equipped by the player
---@return BRItemHelmet|nil
function BRPlayer:GetHelmet()
	return (self.m_Inventory ~= nil and self.m_Inventory:GetSlot(InventorySlot.Helmet).m_Item) or nil
end

---Checks if the player is alive
---@return boolean
function BRPlayer:IsAlive()
	local s_Player = self:GetPlayer()
	return s_Player ~= nil and s_Player.alive
end

---Checks if the player and `p_OtherBRPlayer` are on the same team
---@param p_OtherBRPlayer BRPlayer
---@return boolean
function BRPlayer:IsTeammate(p_OtherBRPlayer)
	return self.m_Team ~= nil and self.m_Team:Equals(p_OtherBRPlayer.m_Team)
end

---Checks if the player has any alive teammates
---@return boolean
function BRPlayer:HasAliveTeammates()
	return self.m_Team ~= nil and self.m_Team:HasAlivePlayers(self, true)
end

---Compare two BRPlayer instances for equality
---@param p_OtherBRPlayer BRPlayer
---@return boolean
function BRPlayer:Equals(p_OtherBRPlayer)
	return p_OtherBRPlayer ~= nil and self:GetName() == p_OtherBRPlayer:GetName()
end

---`==` metamethod
---@param p_OtherBRPlayer BRPlayer
---@return boolean
function BRPlayer:__eq(p_OtherBRPlayer)
	return self:Equals(p_OtherBRPlayer)
end

---@class BRSimplePlayerTable
---@field Name string
---@field IsTeamLeader boolean
---@field State BRPlayerState|integer
---@field PosInSquad integer

---@class BRPlayerDataTable
---@field TeamJoinStrategy integer|TeamJoinStrategy
---@field IsTeamLeader boolean
---@field Kills integer
---@field Score integer
---@field PosInSquad integer

---@class BRPlayerTable
---@field Data BRPlayerDataTable
---@field Team BRTeamTable

---@param p_Simple boolean|nil
---@param p_TeamData BRTeamTable|nil
---@return BRSimplePlayerTable|BRPlayerTable
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
-- * `p_Player` is string			--> `p_Player`
-- * `p_Player` is vanilla player --> `p_Player.name`
-- * `p_Player` is BRPlayer		--> `p_Player.m_Player.name`
-- * `else`						--> `nil`
---@param p_Player string|Player|BRPlayer|nil
---@return string
function BRPlayer.static:GetPlayerName(p_Player)
	return (type(p_Player) == "string" and p_Player) or (type(p_Player) == "userdata" and p_Player.name) or
				(type(p_Player) == "table" and p_Player:GetName()) or nil
end

-- Garbage collector metamethod
function BRPlayer:__gc()
	self:Destroy()
end
