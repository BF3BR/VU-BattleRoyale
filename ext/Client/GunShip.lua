class 'Gunship'

function Gunship:__init()

	self.m_IsInGunship = false

	self.m_GunshipCameraNetEvent = NetEvents:Subscribe('GunshipCamera', self, self.OnGunShipCamera)
	self.m_GunshipCameraNetEvent = NetEvents:Subscribe('ForceJumpOufOfGunship', self, self.OnForceJumpOufOfGunship)
	self.m_ClientUpdateInputEvent = Events:Subscribe('Client:UpdateInput', self, self.OnClientUpdateInput)
	
end

function Gunship:OnGunShipCamera()
	self:EnableCamera(true)
end

function Gunship:OnForceJumpOufOfGunship()
	
	if self.m_IsInGunship then
		
		NetEvents:SendLocal('JumpOutOfGunship')
		self:EnableCamera(false)
		
	end
	
end

function Gunship:OnClientUpdateInput()
	
	if not self.m_IsInGunship then
		return
	end
	
	if InputManager:IsKeyDown(InputDeviceKeys.IDK_E) then
		
		print("Debug: Pressed E")
		-- TODO: Spawn player under the gunship
		self.m_IsInGunship = false
		
		NetEvents:SendLocal('JumpOutOfGunship')
		self:EnableCamera(false)
		
	end
	
end

function Gunship:EnableCamera(p_Enable)
	
	local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
	local s_CameraEntity = s_CameraEntityIterator:Next()
	
	while s_CameraEntity do
		
		if s_CameraEntity.data.instanceGuid == Guid('B19E172D-24EB-4513-9844-53ECA80A4FF9') then
			
			s_CameraEntity = Entity(s_CameraEntity)
			
			if p_Enable then
				
				self.m_IsInGunship = true
				s_CameraEntity:FireEvent("TakeControl")
				
			else
			
				s_CameraEntity:FireEvent("ReleaseControl")
			
			end
			
			return
			
		end
		
		s_CameraEntity = s_CameraEntityIterator:Next()
	
	end
	
end

g_Gunship = Gunship()