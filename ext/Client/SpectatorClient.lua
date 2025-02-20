---@class SpectatorClient : TimersMixin
SpectatorClient = class("SpectatorClient", TimersMixin)

---@type MathHelper
local m_MathHelper = require "__shared/Utils/MathHelper"
---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
local m_Logger = Logger("SpectatorClient", false)

function SpectatorClient:__init()
	-- call TimersMixin's constructor
	TimersMixin.__init(self)

	self:RegisterVars()
end

function SpectatorClient:RegisterVars()
	self.m_Distance = 2.0
	self.m_Height = 1.75
	self.m_LookAtPos = nil

	self.m_SpectatingPlayerPitch = 0.0
	self.m_SpectatingPlayerYaw = 0.0

	self.m_LastPitch = 0.0
	self.m_LastYaw = 0.0

	---@type GameStates|nil
	self.m_GameState = nil
	self.m_IsSpectatingGunship = false

	self.m_IsDefaultFreeCamSet = false

	self.m_DisabledFreecamMovement = false
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function SpectatorClient:OnExtensionUnloading()
	WebUI:ExecuteJS("UpdateSpectatorCount(null);")
	self:Disable()
end

---VEXT Shared Level:Destroy Event
function SpectatorClient:OnLevelDestroy()
	WebUI:ExecuteJS("UpdateSpectatorCount(null);")
	self:Disable()
	self.m_SpectatingPlayerPitch = 0.0
	self.m_SpectatingPlayerYaw = 0.0
end

---VEXT Shared Engine:Update Event
---@param p_DeltaTime number
function SpectatorClient:OnEngineUpdate(p_DeltaTime)
	if not SpectatorManager:GetSpectating() then
		return
	end

	if SpectatorManager:GetCameraMode() ~= SpectatorCameraMode.ThirdPerson then
		return
	end

	-- Don't update if we don't have a player with an alive soldier.
	local s_Player = SpectatorManager:GetSpectatedPlayer()

	if s_Player == nil then
		return
	end

	if s_Player.soldier == nil or s_Player.id == nil then
		return
	end

	-- Request the spectating player's pitch and yaw
	NetEvents:Send(SpectatorEvents.RequestPitchAndYaw, s_Player.id)

	-- Get the soldier's aiming angles.
	local s_Yaw = m_MathHelper:LerpRadians(self.m_LastYaw, self.m_SpectatingPlayerYaw, p_DeltaTime * 10)
	self.m_LastYaw = s_Yaw

	local s_Pitch = MathUtils:Lerp(self.m_LastPitch, self.m_SpectatingPlayerPitch, p_DeltaTime * 10)
	self.m_LastPitch = s_Pitch

	-- Fix angles so we're looking at the right thing.
	s_Yaw = s_Yaw - math.pi / 2
	s_Pitch = s_Pitch + math.pi / 2

	-- Set the look at position above the soldier's feet.
	self.m_LookAtPos = s_Player.soldier.transform.trans:Clone()
	self.m_LookAtPos.x = self.m_LookAtPos.x + s_Player.soldier.transform.left.x * 0.5
	self.m_LookAtPos.z = self.m_LookAtPos.z + s_Player.soldier.transform.left.z * 0.5
	---@type QuatTransform|LinearTransform
	local s_HeadTransform = s_Player.soldier.ragdollComponent:GetActiveWorldTransform(46)

	if s_HeadTransform ~= nil then
		s_HeadTransform = s_HeadTransform:ToLinearTransform()
		self.m_LookAtPos.y = s_HeadTransform.trans.y
	else
		self.m_LookAtPos.y = self.m_LookAtPos.y + self.m_Height
	end

	-- Calculate where our camera has to be base on the angles.
	---@type number
	local s_Cosfi = math.cos(s_Yaw)
	local s_Sinfi = math.sin(s_Yaw)

	---@type number
	local s_Costheta = math.cos(s_Pitch)
	local s_Sintheta = math.sin(s_Pitch)

	---@type number
	local s_Cx = self.m_LookAtPos.x + (self.m_Distance * s_Sintheta * s_Cosfi)
	---@type number
	local s_Cy = self.m_LookAtPos.y + (self.m_Distance * s_Costheta)
	---@type number
	local s_Cz = self.m_LookAtPos.z + (self.m_Distance * s_Sintheta * s_Sinfi)

	local s_CameraLocation = Vec3(s_Cx, s_Cy, s_Cz)

	local s_Hit = RaycastManager:Raycast(self.m_LookAtPos, s_CameraLocation, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	-- If something does, then change the camera location to it.
	if s_Hit ~= nil then
		s_CameraLocation = s_Hit.position

		-- Move it just a bit forward so we're not actually inside geometry.
		---@type Vec3
		local s_Heading = self.m_LookAtPos - s_CameraLocation
		local s_Direction = s_Heading:Normalize()

		s_CameraLocation = s_CameraLocation + (s_Direction * 0.1)
	end

	local s_Transform = LinearTransform()
	s_Transform:LookAtTransform(s_CameraLocation, self.m_LookAtPos)
	s_Transform.left = s_Transform.left * -1
	s_Transform.forward = s_Transform.forward * -1
	SpectatorManager:SetFreecameraTransform(s_Transform)
end

---VEXT Client Client:UpdateInput Event
function SpectatorClient:OnClientUpdateInput()
	if not SpectatorManager:GetSpectating() then
		return
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_Space)
	or InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowRight)
	or InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_0) then
		self:SpectateNextPlayer()
	elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowLeft)
	or InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_1) then
		self:SpectatePreviousPlayer()
	end

	local s_CameraMode = SpectatorManager:GetCameraMode()

	if s_CameraMode == SpectatorCameraMode.ThirdPerson and not m_HudUtils:GetDisabledFreecamMovement() then
		m_HudUtils:OnDisableGameInput()
		m_HudUtils:SetDisabledFreecamMovement(true)
		m_Logger:Write("Disabled FreecamMovement")
	elseif s_CameraMode ~= SpectatorCameraMode.ThirdPerson and m_HudUtils:GetDisabledFreecamMovement() then
		m_HudUtils:SetDisabledFreecamMovement(false)
		m_HudUtils:HUDEnterUIGraph()
		m_Logger:Write("Enabled FreecamMovement")
	end
end

---VEXT Client Player:Respawn Event
---@param p_Player Player
function SpectatorClient:OnPlayerRespawn(p_Player)
	if not SpectatorManager:GetSpectating() then
		return
	end

	-- Disable spectator when the local player spawns.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer == p_Player then
		self:Disable()
		return
	end

	-- If we have nobody to spectate and this player is spectatable
	-- then switch to them.
	if s_LocalPlayer == SpectatorManager:GetSpectatedPlayer() or SpectatorManager:GetCameraMode() ~= SpectatorCameraMode.ThirdPerson then
		m_Logger:Write("SpectatePlayer OnPlayerRespawn")
		self:SpectatePlayer(p_Player)
	end
end

---VEXT Client Player:Deleted Event
---@param p_Player Player
function SpectatorClient:OnPlayerDeleted(p_Player)
	if not SpectatorManager:GetSpectating() then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if p_Player == s_LocalPlayer then
		m_Logger:Write("You are leaving, disabling spec now.")
		self:Disable()
		return
	end

	-- Handle disconnection of player being spectated.
	if p_Player == SpectatorManager:GetSpectatedPlayer() or SpectatorManager:GetCameraMode() ~= SpectatorCameraMode.ThirdPerson then
		self:SpectateNextPlayer()
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

---Custom Client ServerPlayer:Killed NetEvent
---@param p_PlayerId integer
---@param p_InflictorId integer|nil
function SpectatorClient:OnPlayerKilled(p_PlayerId, p_InflictorId)
	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	if s_Player.id == p_PlayerId then
		m_Logger:Write("you died. enabling spec in 5 secs")
		m_TimerManager:Timeout(5.0, p_InflictorId, function()
			if self.m_GameState ~= GameStates.None and self.m_GameState ~= GameStates.Warmup then
				self:Enable(p_InflictorId)
			end
		end)
		return
	-- Handle death of player being spectated.
	elseif SpectatorManager:GetSpectating() then
		local s_SpectatedPlayer = SpectatorManager:GetSpectatedPlayer()

		if SpectatorManager:GetCameraMode() ~= SpectatorCameraMode.ThirdPerson then
			m_Logger:Write("SpectateNextPlayer")
			self:SpectateNextPlayer()
			return
		elseif p_PlayerId == s_SpectatedPlayer.id then
			m_Logger:Write("SpectatedPlayer died")
			local s_NextPlayer = nil

			-- this check is needed otherwise it would repeat the function for all players
			if s_SpectatedPlayer.squadId ~= SquadId.SquadNone then
				-- get the next squad mate
				s_NextPlayer = self:GetNextPlayer(true)
			end

			-- if we find a squadmate we want to spectate him
			if s_NextPlayer ~= nil and s_NextPlayer.id ~= p_PlayerId then
				self:SpectatePlayer(s_NextPlayer)
				return
			-- otherwise spectate the inflictor if there is one
			elseif p_InflictorId ~= nil then
				local s_Inflictor = PlayerManager:GetPlayerById(p_InflictorId)

				if s_Inflictor ~= nil and p_InflictorId ~= s_Player.id then
					m_Logger:Write("SpectatePlayer OnPlayerKilled")
					self:SpectatePlayer(s_Inflictor)
					return
				end
			end

			-- no squad mate alive and also didn't find an inflictor
			-- so now we just search a random player
			s_NextPlayer = self:GetNextPlayer(false)

			if s_NextPlayer ~= nil and s_NextPlayer.id ~= p_PlayerId then
				self:SpectatePlayer(s_NextPlayer)
				return
			end

			-- we didn't find anyone
			WebUI:ExecuteJS("SpectatorTarget('');")
			self:EnableFreecam()
		end
	end
end

---Updates pitch & yaw
---@param p_Pitch number
---@param p_Yaw number
function SpectatorClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
	self.m_SpectatingPlayerPitch = p_Pitch
	self.m_SpectatingPlayerYaw = p_Yaw
end

---Updates the amount of spectators
---@param p_SpectatorCount integer
function SpectatorClient:OnUpdateSpectatorCount(p_SpectatorCount)
	WebUI:ExecuteJS("UpdateSpectatorCount(" .. tostring(p_SpectatorCount) .. ");")
end

---Custom Client PlayerEvents.GameStateChanged NetEvent
---@param p_GameState GameStates|integer
function SpectatorClient:OnGameStateChanged(p_GameState)
	if p_GameState == GameStates.None or p_GameState == GameStates.Warmup or p_GameState == GameStates.EndGame then
		WebUI:ExecuteJS("UpdateSpectatorCount(null);")
	end

	self.m_GameState = p_GameState
end

-- =============================================
-- Functions
-- =============================================

-- =============================================
	-- (Re-)Enable / Disable Camera
-- =============================================

---Enable the Spectator
---@param p_InflictorId integer|nil
function SpectatorClient:Enable(p_InflictorId)
	if SpectatorManager:GetSpectating() and SpectatorManager:GetCameraMode() == SpectatorCameraMode.ThirdPerson then
		m_Logger:Write("Is already enabled")
		return
	end

	-- If we're alive we don't allow spectating.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer.soldier ~= nil and not s_LocalPlayer.soldier.isDead then
		m_Logger:Write("You are not dead :o")
		return
	end

	if not SpectatorManager:GetSpectating() then
		SpectatorManager:SetSpectating(true)
		m_Logger:Write("Spectating should work at this point")
	end

	local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)

	if s_PlayerToSpectate == nil then
		s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false, p_InflictorId)
	end

	if s_PlayerToSpectate ~= nil then
		if self.m_IsSpectatingGunship then
			self:SpectateGunship(false)
		end

		m_Logger:Write("SpectatePlayer Enable")
		self:SpectatePlayer(s_PlayerToSpectate)

		return
	elseif self.m_GameState == GameStates.Plane then
		SpectatorManager:SetCameraMode(SpectatorCameraMode.Disabled)
		self:SpectateGunship(true)
		WebUI:ExecuteJS("SpectatorTarget('');")
		WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(true) .. ");")
	else
		if self.m_IsSpectatingGunship then
			self:SpectateGunship(false)
		end

		WebUI:ExecuteJS("SpectatorTarget('');")
		WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(true) .. ");")
		self:EnableFreecam()
	end

	-- if the match is already running nobody will spawn
	if self.m_GameState == nil or self.m_GameState >= GameStates.Match then
		return
	end

	self:SetTimer("NoPlayerFoundTimer", m_TimerManager:Timeout(4, self, self.ReEnable))
end

---Reenable the Spectator if we found no players
function SpectatorClient:ReEnable()
	self:Enable(nil)
end

---Disable the Spectator
function SpectatorClient:Disable()
	if not SpectatorManager:GetSpectating() then
		m_Logger:Write("Disable - GetSpectating its off already")
		return
	end

	local s_SpectatedPlayer = SpectatorManager:GetSpectatedPlayer()
	m_Logger:Write("Disable - GetSpectatedPlayer")

	if s_SpectatedPlayer ~= nil then
		m_Logger:Write("Disable - Sending NetEvent UpdateSpectator")
		NetEvents:SendLocal('UpdateSpectator', nil, s_SpectatedPlayer.name)
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil then
		SpectatorManager:SpectatePlayer(s_LocalPlayer, true)
	end

	SpectatorManager:SetCameraMode(SpectatorCameraMode.Disabled)
	SpectatorManager:SetSpectating(false)

	WebUI:ExecuteJS("SpectatorTarget('');")
	WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(false) .. ");")
end

-- =============================================
	-- Set Freecamera transform
-- =============================================

---Update the camera transform
---@param p_Timer Timer
function SpectatorClient:OnSetFreecameraTransform(p_Timer)
	local s_CameraTransform = ClientUtils:GetCameraTransform()
	---@type LinearTransform
	local s_Transform = MapsConfig[LevelNameHelper:GetLevelName()].DefaultFreecamTransform

	if s_Transform.trans:Distance(s_CameraTransform.trans) < 15.0 then
		self.m_IsDefaultFreeCamSet = true
		p_Timer:Destroy()
	else
		m_Logger:Write("Setting freecam transform failed.")
		m_Logger:Write(s_Transform.trans:Distance(s_CameraTransform.trans))
		m_Logger:Write(s_CameraTransform)

		SpectatorManager:SetFreecameraTransform(s_Transform)
	end
end

-- =============================================
	-- Spectate Player
-- =============================================

---Spectate this player
---@param p_Player Player
function SpectatorClient:SpectatePlayer(p_Player)
	if not SpectatorManager:GetSpectating() then
		return
	end

	-- probably not needed
	if p_Player == nil then
		self:Disable()
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	-- We can't spectate the local player.
	if s_LocalPlayer == p_Player then
		return
	end

	WebUI:ExecuteJS("SpectatorTarget('" .. tostring(p_Player.name) .. "');")
	WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(true) .. ");")

	local s_SpectatedPlayer = SpectatorManager:GetSpectatedPlayer()
	---@type string|nil
	local s_SpectatedPlayerName = nil
	m_Logger:Write("New player: " .. p_Player.name)

	if s_SpectatedPlayer ~= nil then
		s_SpectatedPlayerName = s_SpectatedPlayer.name
		m_Logger:Write("Old player: " .. s_SpectatedPlayerName)
	end

	NetEvents:SendLocal('UpdateSpectator', p_Player.name, s_SpectatedPlayerName)

	-- Dispatch a local event so phasemanager can toggle the OOC visuals
	SpectatorManager:SpectatePlayer(p_Player, false)

	-- Add a FadeOut + FadeIn event
	local s_EntityIterator = EntityManager:GetIterator("ClientFadeEntity")
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("B3E83182-483B-4E97-BC90-AB7E2813552A") then
			s_Entity:FireEvent("FadeOut")
			return
		end

		s_Entity = s_EntityIterator:Next()
	end
end

---Find a player to spectate
---@param p_OnlySquadMates boolean
---@param p_InflictorId integer|nil
---@return Player|nil
function SpectatorClient:FindFirstPlayerToSpectate(p_OnlySquadMates, p_InflictorId)
	local s_PlayerToSpectate = nil
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return nil
	end

	if p_OnlySquadMates then
		if s_LocalPlayer.squadId == SquadId.SquadNone then
			return s_PlayerToSpectate
		end

		s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)
	else
		if p_InflictorId ~= nil then
			local s_Inflictor = PlayerManager:GetPlayerById(p_InflictorId)

			if s_Inflictor ~= nil and p_InflictorId ~= s_LocalPlayer.id then
				return s_Inflictor
			end
		end
		s_Players = PlayerManager:GetPlayers()
	end

	for _, l_Player in pairs(s_Players) do
		-- We don't want to spectate the local player.
		if l_Player == s_LocalPlayer then
			goto continue_enable
		end

		-- We don't want to spectate dead players
		if l_Player.soldier == nil then
			goto continue_enable
		end

		s_PlayerToSpectate = l_Player
		break

		::continue_enable::
	end

	return s_PlayerToSpectate
end

-- =============================================
	-- Spectate Gunship
-- =============================================

---If nobody spawned spectate the gunship
---@param p_Enable boolean
function SpectatorClient:SpectateGunship(p_Enable)
	local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
	local s_CameraEntity = s_CameraEntityIterator:Next()

	while s_CameraEntity do
		if s_CameraEntity.data.instanceGuid == Guid("B19E172D-24EB-4513-9844-53ECA80A4FF9") then
			s_CameraEntity = Entity(s_CameraEntity)

			if p_Enable then
				self.m_IsSpectatingGunship = true
				s_CameraEntity:FireEvent("TakeControl")
			else
				self.m_IsSpectatingGunship = false
				s_CameraEntity:FireEvent("ReleaseControl")
			end

			return
		end

		s_CameraEntity = s_CameraEntityIterator:Next()
	end
end

-- =============================================
	-- Spectate Next Player
-- =============================================

---Spectate the next available Player if possible
function SpectatorClient:SpectateNextPlayer()
	if not SpectatorManager:GetSpectating() then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if s_LocalPlayer == SpectatorManager:GetSpectatedPlayer() then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)

		if s_PlayerToSpectate == nil then
			s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false)
		end

		if s_PlayerToSpectate ~= nil then
			m_Logger:Write("SpectatePlayer SpectateNextPlayer1")
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		m_Logger:Write("No Player found, stay in freecam")
		return
	end

	local s_NextPlayer = self:GetNextPlayer(true)

	if s_NextPlayer == nil then
		s_NextPlayer = self:GetNextPlayer(false)
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if s_NextPlayer ~= nil then
		m_Logger:Write("SpectatePlayer SpectateNextPlayer2")
		self:SpectatePlayer(s_NextPlayer)
	else
		WebUI:ExecuteJS("SpectatorTarget('');")
	end
end

---Get the next available Player or nil
---@param p_OnlySquadMates boolean
---@return Player|nil
function SpectatorClient:GetNextPlayer(p_OnlySquadMates)
	-- Find the index of the current player.
	local s_CurrentIndex = 0
	---@type Player[]
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return nil
	end

	if p_OnlySquadMates then
		if s_LocalPlayer.squadId == SquadId.SquadNone then
			return self:GetNextPlayer(false)
		end

		s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)
	else
		s_Players = PlayerManager:GetPlayers()
	end

	if s_Players == nil then
		return nil
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player == SpectatorManager:GetSpectatedPlayer() then
			s_CurrentIndex = i
			break
		end
	end

	-- Increment so we start from the next player.
	s_CurrentIndex = s_CurrentIndex + 1

	if s_CurrentIndex > #s_Players then
		s_CurrentIndex = 1
	end

	-- Find the next player we can spectate.
	---@type Player|nil
	local s_NextPlayer = nil

	for i = 1, #s_Players do
		---@type integer
		local s_PlayerIndex = (i - 1) + s_CurrentIndex

		if s_PlayerIndex > #s_Players then
			s_PlayerIndex = s_PlayerIndex - #s_Players
		end

		local s_Player = s_Players[s_PlayerIndex]

		if s_Player.soldier ~= nil and s_Player ~= s_LocalPlayer then
			s_NextPlayer = s_Player
			break
		end
	end

	return s_NextPlayer
end

-- =============================================
	-- Spectate Previous Player
-- =============================================

---Spectate the previous available Player if possible
function SpectatorClient:SpectatePreviousPlayer()
	if not SpectatorManager:GetSpectating() then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if s_LocalPlayer == SpectatorManager:GetSpectatedPlayer() then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)

		if s_PlayerToSpectate == nil then
			s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false)
		end

		if s_PlayerToSpectate ~= nil then
			m_Logger:Write("SpectatePlayer SpectatePreviousPlayer1")
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		m_Logger:Write("No Player found, stay in freecam")
		return
	end

	local s_PreviousPlayer = self:GetPreviousPlayer(true)

	if s_PreviousPlayer == nil then
		s_PreviousPlayer = self:GetPreviousPlayer(false)
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if s_PreviousPlayer ~= nil then
		m_Logger:Write("SpectatePlayer SpectatePreviousPlayer2")
		self:SpectatePlayer(s_PreviousPlayer)
	else
		WebUI:ExecuteJS("SpectatorTarget('');")
	end
end

---Get the previous available Player or nil
---@param p_OnlySquadMates boolean
---@return Player|nil
function SpectatorClient:GetPreviousPlayer(p_OnlySquadMates)
	-- Find the index of the current player.
	local s_CurrentIndex = 0
	---@type Player[]
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if p_OnlySquadMates then
		if s_LocalPlayer.squadId == SquadId.SquadNone then
			return self:GetPreviousPlayer(false)
		end

		s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)
	else
		s_Players = PlayerManager:GetPlayers()
	end

	if s_Players == nil then
		return
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player == SpectatorManager:GetSpectatedPlayer() then
			s_CurrentIndex = i
			break
		end
	end

	-- Decrement so we start from the previous player.
	s_CurrentIndex = s_CurrentIndex - 1

	if s_CurrentIndex <= 0 then
		s_CurrentIndex = #s_Players
	end

	-- Find the previous player we can spectate.
	---@type Player|nil
	local s_PreviousPlayer = nil

	for i = #s_Players, 1, -1 do
		---@type integer
		local s_PlayerIndex = (i - (#s_Players - s_CurrentIndex))

		if s_PlayerIndex <= 0 then
			s_PlayerIndex = s_PlayerIndex + #s_Players
		end

		local s_Player = s_Players[s_PlayerIndex]

		if s_Player.soldier ~= nil and s_Player ~= s_LocalPlayer then
			s_PreviousPlayer = s_Player
			break
		end
	end

	return s_PreviousPlayer
end

-- =============================================
	-- Freecam
-- =============================================

---No players found, no gunship found, now enable freecam
function SpectatorClient:EnableFreecam()
	SpectatorManager:SetCameraMode(SpectatorCameraMode.FreeCamera)

	if not self.m_IsDefaultFreeCamSet then
		m_Logger:Write("Set freecam transform")
		---@type LinearTransform
		local s_Transform = MapsConfig[LevelNameHelper:GetLevelName()].DefaultFreecamTransform
		SpectatorManager:SetFreecameraTransform(s_Transform)
		m_TimerManager:Interval(0.1, self, self.OnSetFreecameraTransform)
	end
end

return SpectatorClient()
