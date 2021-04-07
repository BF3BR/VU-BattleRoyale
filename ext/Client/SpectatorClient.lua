require "__shared/Enums/CustomEvents"
require "__shared/Utils/MathHelper"
require "__shared/Utils/Timers"
require "__shared/Mixins/TimersMixin"

class("SpectatorClient", TimersMixin)

function SpectatorClient:__init()
	-- call TimersMixin's constructor
	TimersMixin.__init(self)
	
	self.m_SpectatedPlayerId = nil

	self.m_Distance = 2.0
	self.m_Height = 1.75
	self.m_Data = nil
	self.m_Entity = nil
	self.m_Active = false
	self.m_LookAtPos = nil

	self.m_SpectatingPlayerPitch = 0.0
	self.m_SpectatingPlayerYaw = 0.0

	self.m_LastPitch = 0.0
	self.m_LastYaw = 0.0

	self.m_GameState = nil
	self.m_IsSpectatingGunship = false
end

function SpectatorClient:OnExtensionUnloading()
	self:Disable()
end

function SpectatorClient:OnLevelDestroy()
	self:Disable()
end

function SpectatorClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
	if p_Pitch == nil or p_Yaw == nil then
		return
	end

	self.m_SpectatingPlayerPitch = p_Pitch
	self.m_SpectatingPlayerYaw = p_Yaw
end

function SpectatorClient:OnPlayerRespawn(p_Player)
	if not self:IsEnabled() then
		return
	end

	-- Disable spectator when the local player spawns.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == p_Player then
		self:Disable()
		return
	end

	-- If we have nobody to spectate and this player is spectatable
	-- then switch to them.
	if self.m_SpectatedPlayerId == nil then
		self:SpectatePlayer(p_Player)
	end
end

function SpectatorClient:OnPlayerKilled(p_PlayerId, p_InflictorId)
	if p_PlayerId == nil then
		return
	end

    local s_Player = PlayerManager:GetLocalPlayer()

    if s_Player == nil then
        return
    end
    if s_Player.id == p_PlayerId then
        g_Timers:Timeout(5, p_InflictorId, function()
            self:Enable(p_InflictorId)
        end)
        return
    -- Handle death of player being spectated.
    elseif self.m_SpectatedPlayerId == nil then
        self:SpectateNextPlayer()
        return
    elseif p_PlayerId == self.m_SpectatedPlayerId then
        if p_InflictorId ~= nil then
            local s_Inflictor = PlayerManager:GetPlayerById(p_InflictorId)
            if s_Inflictor ~= nil and p_InflictorId ~= s_Player.id then
                self:SpectatePlayer(s_Inflictor)
                return
            end
        end
    end
    self:SpectateNextPlayer()
end

function SpectatorClient:OnPlayerDeleted(p_Player)
    if not self:IsEnabled() then
        return
    end

    -- Handle disconnection of player being spectated.
    if p_Player.id == self.m_SpectatedPlayerId then
        self.m_SpectatedPlayerId = nil
        self:SpectateNextPlayer()
    end
end

function SpectatorClient:OnClientUpdateInput()
    if self:IsEnabled() then
        if InputManager:WentKeyDown(InputDeviceKeys.IDK_Space) or InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowRight) then
            self:SpectateNextPlayer()
        end
        
        if InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowLeft) then
            self:SpectatePreviousPlayer()
        end 
    end
end

function SpectatorClient:OnGameStateChanged(p_GameState)
    if p_GameState == nil then
        return
    end
    self.m_GameState = p_GameState
end

function SpectatorClient:FindFirstPlayerToSpectate(p_OnlySquadMates, p_InflictorId)
	local s_PlayerToSpectate = nil
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

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

function SpectatorClient:Enable(p_InflictorId)
	if self:IsEnabled() then
		return
	end

	local s_Transform = LinearTransform(
				Vec3(-0.9988129734993, 0.048187829554081, -0.0071058692410588), 
				Vec3(-0.00787671841681, -0.015825755894184, 0.99984383583069), 
				Vec3(0.048067845404148, 0.99871289730072, 0.016186531633139), 
				Vec3(98.216575622559, 889.53924560547, -815.45764160156))
	SpectatorManager:SetFreecameraTransform(s_Transform)

	-- If we're alive we don't allow spectating.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer.soldier ~= nil and not s_LocalPlayer.soldier.isDead then
		return
	end

	self:CreateCamera()
	self:TakeControl()

	local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)
	if s_PlayerToSpectate == nil then
		s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false, p_InflictorId)
	end

	if s_PlayerToSpectate ~= nil then
		-- self:RemoveTimer("NoPlayerFoundTimer")
		if self.m_IsSpectatingGunship then
			self:SpectateGunship(false)	
		end
		self:SpectatePlayer(s_PlayerToSpectate)
		return
	elseif self.m_GameState == GameStates.Plane then
		self:SpectateGunship(true)	
	end

	self:SetTimer("NoPlayerFoundTimer", g_Timers:Timeout(4, self, self.ReEnable))

	-- If we found no player to spectate we just disable the spectator mode
	self:Disable()
end

function SpectatorClient:ReEnable()
	self:Enable(nil)
end

function SpectatorClient:Disable()
	if not self:IsEnabled() then
		return
    end
    
    WebUI:ExecuteJS("SpectatorTarget('');")
    WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(false) .. ");")

	self.m_SpectatedPlayerId = nil
	-- Dispatch a local event for phasemanager
	Events:DispatchLocal(SpectatorEvent.PlayerChanged)

	self:ReleaseControl()
	self:DestroyCamera()
end

function SpectatorClient:DestroyCamera()
	if self.m_Entity == nil then
		return
	end

	-- Destroy the camera entity.
	self.m_Entity:Destroy()
	self.m_Entity = nil
	self.m_LookAtPos = nil
end

function SpectatorClient:TakeControl()
	-- By firing the "TakeControl" event on the camera entity we make the
	-- current player switch to this camera from their first person camera.
	self.m_Active = true
	self.m_Entity:FireEvent("TakeControl")
end


function SpectatorClient:ReleaseControl()
	-- By firing the "ReleaseControl" event on the camera entity we return
	-- the player to whatever camera they were supposed to be using.
	self.m_Active = false

	if self.m_Entity ~= nil then
		self.m_Entity:FireEvent("ReleaseControl")
	end
end

function SpectatorClient:CreateCameraData()
	if self.m_Data ~= nil then
		return
	end

	-- Create data for our camera entity.
	-- We set the priority very high so our game gets forced to use this camera.
	self.m_Data = CameraEntityData()
	self.m_Data.fov = 80
	self.m_Data.enabled = true
	self.m_Data.priority = 99999
	self.m_Data.nameId = "vu-battleroyale-spec-cam"
	self.m_Data.transform = LinearTransform()
end

function SpectatorClient:CreateCamera()
	if self.m_Entity ~= nil then
		return
	end

	-- First ensure that we have create our camera data.
	self:CreateCameraData()

	-- And then create the camera entity.
	self.m_Entity = EntityManager:CreateEntity(self.m_Data, self.m_Data.transform)
	self.m_Entity:Init(Realm.Realm_Client, true)
end

function SpectatorClient:SpectatePlayer(p_Player)
	if not self:IsEnabled() then
		return
	end

	if p_Player == nil then
		self:Disable()
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- We can't spectate the local player.
	if s_LocalPlayer == p_Player then
		return
	end

	WebUI:ExecuteJS("SpectatorTarget('" .. tostring(p_Player.name) .. "');")
	WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(true) .. ");")

	-- Dispatch a local event so phasemanager can toggle the OOC visuals
	Events:DispatchLocal(SpectatorEvent.PlayerChanged, p_Player)
	self.m_SpectatedPlayerId = p_Player.id
end

function SpectatorClient:SpectateNextPlayer()
	if not self:IsEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self.m_SpectatedPlayerId == nil then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)

		if s_PlayerToSpectate == nil then
			s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false)
		end

		if s_PlayerToSpectate ~= nil then
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		-- If no players found we just reset the spectator mode
		self:Disable()
		self:Enable()
		return
	end

	local s_NextPlayer = self:GetNextPlayer(true)
	if s_NextPlayer == nil then
		s_NextPlayer = self:GetNextPlayer(false)
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if s_NextPlayer == nil then
		self:Disable()
	else
		self:SpectatePlayer(s_NextPlayer)
	end
end

function SpectatorClient:GetNextPlayer(p_OnlySquadMates)
	-- Find the index of the current player.
	local s_CurrentIndex = 0
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if p_OnlySquadMates then
		if s_LocalPlayer.squadId == SquadId.SquadNone then
			return self:GetNextPlayer(false)
		end
		s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)
	else
		s_Players = PlayerManager:GetPlayers()
	end
	
	if s_Players == nil then
		return
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player.id == self.m_SpectatedPlayerId then
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
	local s_NextPlayer = nil

	for i = 1, #s_Players do
		local l_PlayerIndex = (i - 1) + s_CurrentIndex

		if l_PlayerIndex > #s_Players then
			l_PlayerIndex = l_PlayerIndex - #s_Players
		end

		local l_Player = s_Players[l_PlayerIndex]

		if l_Player.soldier ~= nil and l_Player ~= s_LocalPlayer then
			s_NextPlayer = l_Player
			break
		end
	end
	
	return s_NextPlayer
end

function SpectatorClient:SpectatePreviousPlayer()
	if not self:IsEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self.m_SpectatedPlayerId == nil then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate(true)
	
		if s_PlayerToSpectate == nil then
			s_PlayerToSpectate = self:FindFirstPlayerToSpectate(false)
		end

		if s_PlayerToSpectate ~= nil then
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		return
	end	
	local s_PreviousPlayer = self:GetPreviousPlayer(true)
	if s_PreviousPlayer == nil then
		s_PreviousPlayer = self:GetPreviousPlayer(false)
	end
	-- If we didn't find any players to spectate then switch to freecam.
	if s_PreviousPlayer == nil then
		self:Disable()
	else
		self:SpectatePlayer(s_PreviousPlayer)
	end
end

function SpectatorClient:GetPreviousPlayer(p_OnlySquadMates)
	-- Find the index of the current player.
	local s_CurrentIndex = 0
	local s_Players = nil
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if p_OnlySquadMates then
		if s_LocalPlayer.squadId == SquadId.SquadNone then
			return self:GetNextPlayer(false)
		end
		s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)
	else
		s_Players = PlayerManager:GetPlayers()
	end
	
	if s_Players == nil then
		return
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player.id == self.m_SpectatedPlayerId then
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
	local s_PreviousPlayer = nil

	for i = #s_Players, 1, -1 do
		local l_PlayerIndex = (i - (#s_Players - s_CurrentIndex))

		if l_PlayerIndex <= 0 then
			l_PlayerIndex = l_PlayerIndex + #s_Players
		end

		local l_Player = s_Players[l_PlayerIndex]

		if l_Player.soldier ~= nil and l_Player ~= s_LocalPlayer then
			s_PreviousPlayer = l_Player
			break
		end
	end
	
	return s_PreviousPlayer
end

function SpectatorClient:IsEnabled()
	return self.m_Active
end

function SpectatorClient:OnLevelDestroy()
	self:Disable()
	self.m_SpectatedPlayerId = nil
	self.m_SpectatingPlayerPitch = 0.0
	self.m_SpectatingPlayerYaw = 0.0
end

function SpectatorClient:OnEngineUpdate(p_DeltaTime)
	if not self:IsEnabled() then
		return
	end

	if self.m_SpectatedPlayerId == nil then
		return
	end

	-- Don't update if we don't have a player with an alive soldier.
	local s_Player = PlayerManager:GetPlayerById(self.m_SpectatedPlayerId)

	if s_Player == nil then
		return
	end

	if s_Player.soldier == nil or s_Player.id == nil then
		return
	end

	-- Request the spectating player's pitch and yaw
	NetEvents:Send(SpectatorEvents.RequestPitchAndYaw, s_Player.id)
	
	-- Get the soldier's aiming angles.
	local s_Yaw = MathHelper:LerpRadians(self.m_LastYaw, self.m_SpectatingPlayerYaw, p_DeltaTime * 10)
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
	local s_HeadTransform = s_Player.soldier.ragdollComponent:GetActiveWorldTransform(46)
	if s_HeadTransform ~= nil then
		s_HeadTransform = s_HeadTransform:ToLinearTransform()
		self.m_LookAtPos.y = s_HeadTransform.trans.y
	else
		self.m_LookAtPos.y = self.m_LookAtPos.y + self.m_Height
	end

	-- Calculate where our camera has to be base on the angles.
	local s_Cosfi = math.cos(s_Yaw)
	local s_Sinfi = math.sin(s_Yaw)

	local s_Costheta = math.cos(s_Pitch)
	local s_Sintheta = math.sin(s_Pitch)

	local s_Cx = self.m_LookAtPos.x + (self.m_Distance * s_Sintheta * s_Cosfi)
	local s_Cy = self.m_LookAtPos.y + (self.m_Distance * s_Costheta)
	local s_Cz = self.m_LookAtPos.z + (self.m_Distance * s_Sintheta * s_Sinfi)

    local s_CameraLocation = Vec3(s_Cx, s_Cy, s_Cz)
    
    local s_Hit = RaycastManager:Raycast(self.m_LookAtPos, s_CameraLocation, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	-- If something does, then change the camera location to it.
	if s_Hit ~= nil then
		s_CameraLocation = s_Hit.position

		-- Move it just a bit forward so we're not actually inside geometry.
		local s_Heading = self.m_LookAtPos - s_CameraLocation
		local direction = s_Heading:Normalize()

		s_CameraLocation = s_CameraLocation + (direction * 0.1)
	end

	self.m_Data.transform:LookAtTransform(s_CameraLocation, self.m_LookAtPos)
	self.m_Data.transform.left = self.m_Data.transform.left * -1
	self.m_Data.transform.forward = self.m_Data.transform.forward * -1
end

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

if g_SpectatorClient == nil then
    g_SpectatorClient = SpectatorClient()
end

return g_SpectatorClient
