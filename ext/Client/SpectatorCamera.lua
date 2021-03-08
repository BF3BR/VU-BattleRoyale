class "SpectatorCamera"

require "__shared/Enums/CustomEvents"
require "__shared/Utils/MathHelper"

function SpectatorCamera:__init()
	self.m_SpectatedPlayer = nil

	self.m_Distance = 2.0
	self.m_Height = 1.75
	self.m_Data = nil
	self.m_Entity = nil
	self.m_Active = false
    self.m_LookAtPos = nil

	self.m_PlayersPitchAndYaw = { }

	self.m_LastPitch = 0.0
	self.m_LastYaw = 0.0
end

function SpectatorCamera:OnExtensionUnloading()
    self:Disable()
end

function SpectatorCamera:OnLevelDestroy()
    self:Disable()
end

function SpectatorCamera:OnPlayersPitchAndYaw(p_PitchAndYaw)
	self.m_PlayersPitchAndYaw = p_PitchAndYaw
end

function SpectatorCamera:OnPlayerRespawn(p_Player)
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
	if self.m_SpectatedPlayer == nil then
		self:SpectatePlayer(p_Player)
	end
end

function SpectatorCamera:OnPlayerKilled(p_Player)
    if p_Player == nil then
        return
	end
	
	print("INFO: Player killed: " .. p_Player.name)

    local s_Player = PlayerManager:GetLocalPlayer()

    if s_Player == nil then
        return
    end

    if s_Player.id == p_Player.id then
        self:Enable()
    -- Handle death of player being spectated.
    elseif p_Player == self.m_SpectatedPlayer then
        self:SpectateNextPlayer()
    end
end

function SpectatorCamera:OnPlayerDeleted(p_Player)
	if not self:IsEnabled() then
		return
	end

	-- Handle disconnection of player being spectated.
	if p_Player == self.m_SpectatedPlayer then
		self:SpectateNextPlayer()
	end
end

function SpectatorCamera:OnClientUpdateInput()
    if self:IsEnabled() then
        if InputManager:WentKeyDown(InputDeviceKeys.IDK_Space) or InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowRight) then
            self:SpectateNextPlayer()
        end
        
        if InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowLeft) then
            self:SpectatePreviousPlayer()
        end 
    end
end

function SpectatorCamera:FindFirstPlayerToSpectate()
	local s_PlayerToSpectate = nil
	local s_Players = PlayerManager:GetPlayers()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

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

function SpectatorCamera:Enable()
	if self:IsEnabled() then
		return
	end

	-- If we're alive we don't allow spectating.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer.soldier ~= nil then
		return
	end

	self:CreateCamera()
	self:TakeControl()

    local s_PlayerToSpectate = self:FindFirstPlayerToSpectate()

    if s_PlayerToSpectate ~= nil then
        WebUI:ExecuteJS("SpectatorTarget('" .. tostring(s_PlayerToSpectate.name) .. "');")
        WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(true) .. ");")
		self:SpectatePlayer(s_PlayerToSpectate)
		return
	end

	-- If we found no player to spectate we just disable the spectator mode
	self:Disable()
end

function SpectatorCamera:Disable()
	if not self:IsEnabled() then
		return
    end
    
    WebUI:ExecuteJS("SpectatorTarget('');")
    WebUI:ExecuteJS("SpectatorEnabled(" .. tostring(false) .. ");")

	self.m_SpectatedPlayer = nil

	self:ReleaseControl()
	self:DestroyCamera()
end

function SpectatorCamera:DestroyCamera()
	if self.m_Entity == nil then
		return
	end

	-- Destroy the camera entity.
	self.m_Entity:Destroy()
	self.m_Entity = nil
	self.m_LookAtPos = nil
end

function SpectatorCamera:TakeControl()
	-- By firing the "TakeControl" event on the camera entity we make the
	-- current player switch to this camera from their first person camera.
	self.m_Active = true
	self.m_Entity:FireEvent("TakeControl")
end


function SpectatorCamera:ReleaseControl()
	-- By firing the "ReleaseControl" event on the camera entity we return
	-- the player to whatever camera they were supposed to be using.
	self.m_Active = false

	if self.m_Entity ~= nil then
		self.m_Entity:FireEvent("ReleaseControl")
	end
end

function SpectatorCamera:CreateCameraData()
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

function SpectatorCamera:CreateCamera()
	if self.m_Entity ~= nil then
		return
	end

	-- First ensure that we have create our camera data.
	self:CreateCameraData()

	-- And then create the camera entity.
	self.m_Entity = EntityManager:CreateEntity(self.m_Data, self.m_Data.transform)
	self.m_Entity:Init(Realm.Realm_Client, true)
end

function SpectatorCamera:SpectatePlayer(p_Player)
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

	print("INFO: Spectating player: " .. p_Player.name)

	-- Dispatch a local event so phasemanager can toggle the OOC visuals
	Events:DispatchLocal(SpectatorEvent.PlayerChanged, p_Player)
	self.m_SpectatedPlayer = p_Player
end

function SpectatorCamera:SpectateNextPlayer()
	if not self:IsEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self.m_SpectatedPlayer == nil then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate()

		if s_PlayerToSpectate ~= nil then
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		return
	end

	-- Find the index of the current player.
	local s_CurrentIndex = 0
	local s_Players = PlayerManager:GetPlayers()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_Players == nil then
		return
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player == self.m_SpectatedPlayer then
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

		if l_Player.soldier ~= nil then
			s_NextPlayer = l_Player
			break
		end
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if s_NextPlayer == nil then
		self:Disable()
	else
		WebUI:ExecuteJS("SpectatorTarget('" .. tostring(s_NextPlayer.name) .. "');")
		self:SpectatePlayer(s_NextPlayer)
	end
end

function SpectatorCamera:SpectatePreviousPlayer()
	if not self:IsEnabled() then
		return
	end

	-- If we are not spectating anyone just find the first player to spectate.
	if self.m_SpectatedPlayer == nil then
		local s_PlayerToSpectate = self:FindFirstPlayerToSpectate()

		if s_PlayerToSpectate ~= nil then
			self:SpectatePlayer(s_PlayerToSpectate)
		end

		return
	end

	-- Find the index of the current player.
	local s_CurrentIndex = 0
	local s_Players = PlayerManager:GetPlayers()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_Players == nil then
		return
	end

	for i, l_Player in pairs(s_Players) do
		if l_Player == self.m_SpectatedPlayer then
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
	local s_NextPlayer = nil

	for i = #s_Players, 1, -1 do
		local l_PlayerIndex = (i - (#s_Players - s_CurrentIndex))

		if l_PlayerIndex <= 0 then
			l_PlayerIndex = l_PlayerIndex + #s_Players
		end

		local l_Player = s_Players[l_PlayerIndex]

		if l_Player.soldier ~= nil and l_Player ~= s_LocalPlayer then
			s_NextPlayer = l_Player
			break
		end

		if l_Player.soldier ~= nil then
			s_NextPlayer = l_Player
			break
		end
	end

	-- If we didn't find any players to spectate then switch to freecam.
	if s_NextPlayer == nil then
		self:Disable()
	else
		WebUI:ExecuteJS("SpectatorTarget('" .. tostring(s_NextPlayer.name) .. "');")
		self:SpectatePlayer(s_NextPlayer)
	end
end

function SpectatorCamera:IsEnabled()
	return self.m_Active
end

function SpectatorCamera:OnGameStateChanged(p_GameState)
    if p_GameState == nil then
        return
    end
	
	if p_GameState == GameStates.EndGame then
		self:Disable()
	end
end

function SpectatorCamera:OnLevelDestroy()
	self:Disable()
	self.m_SpectatedPlayer = nil
	self.m_PlayersPitchAndYaw = { }
end

function SpectatorCamera:OnEngineUpdate(p_DeltaTime)
	if not self:IsEnabled() then
		return
	end

	-- Don't update if we don't have a player with an alive soldier.
	local s_Player = self.m_SpectatedPlayer

	if s_Player == nil or s_Player.soldier == nil or s_Player.id == nil then
		return
	end

	if self.m_PlayersPitchAndYaw[s_Player.id] == nil then
		return
	end
	
	-- Get the soldier's aiming angles.
	local s_Yaw = MathHelper:LerpRadians(self.m_LastYaw, self.m_PlayersPitchAndYaw[s_Player.id]["Yaw"], p_DeltaTime * 10)
	self.m_LastYaw = s_Yaw
	
	local s_Pitch = MathUtils:Lerp(self.m_LastPitch, self.m_PlayersPitchAndYaw[s_Player.id]["Pitch"], p_DeltaTime * 10)
	self.m_LastPitch = s_Pitch

	-- Fix angles so we're looking at the right thing.
	s_Yaw = s_Yaw - math.pi / 2
	s_Pitch = s_Pitch + math.pi / 2

	-- Set the look at position above the soldier's feet.
	self.m_LookAtPos = s_Player.soldier.transform.trans:Clone()
	self.m_LookAtPos.x = self.m_LookAtPos.x + s_Player.soldier.transform.left.x * 0.5
	self.m_LookAtPos.z = self.m_LookAtPos.z + s_Player.soldier.transform.left.z * 0.5
	self.m_LookAtPos.y = self.m_LookAtPos.y + self.m_Height

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

if g_SpectatorCamera == nil then
    g_SpectatorCamera = SpectatorCamera()
end

return g_SpectatorCamera
