local Gunship = class 'Gunship'

function Gunship:__init(p_Match)
	-- Save match reference
	self.m_Match = p_Match
	
	self.m_JumpOutOfGunshipEvent = NetEvents:Subscribe('JumpOutOfGunship', self, self.OnJumpOutOfGunship)
	self.m_EngineUpdateEvent = Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	
	
	self.m_SetFlyPath = false
	self.m_CumulatedTime = 0
	
end

function Gunship:OnJumpOutOfGunship(p_Player)
	
	-- Get the Gunship transform
	local s_Transform = nil
	
	local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
	local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	
	while s_VehicleSpawnEntity do
		
		if s_VehicleSpawnEntity.data.instanceGuid == Guid('81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778') then
			
			s_VehicleSpawnEntity = SpatialEntity(s_VehicleSpawnEntity)
			s_Transform = s_VehicleSpawnEntity.transform
			s_Transform.trans = Vec3(s_Transform.trans.x, s_Transform.trans.y - 10, s_Transform.trans.z)
			
			break
			
		end
		
		s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	
	end
	
	self.m_Match:SpawnPlayer(p_Player, s_Transform)
	p_Player.soldier.health = 200.0
end

function Gunship:OnEngineUpdate(p_DeltaTime)
	if not self.m_SetFlyPath then
		return
	end
	self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
	if self.m_CumulatedTime >= 0.1 then
		self.m_SetFlyPath = false
		self.m_CumulatedTime = 0
		self:SetLocatorEntityTransform(true)
		self:SetVehicleEntityTransform()
		self:SetLocatorEntityTransform(false)
		NetEvents:BroadcastLocal('GunshipCamera')
	end
end
	
function Gunship:Spawn()
	
	local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleSpawnEntity")
	local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	
	while s_VehicleSpawnEntity do
		
		if s_VehicleSpawnEntity.data.instanceGuid == Guid('5449C054-7A18-4696-8AA9-416A8B9A9CD0') then
			
			s_VehicleSpawnEntity = Entity(s_VehicleSpawnEntity)
			s_VehicleSpawnEntity:FireEvent("Spawn")
			
			self.m_SetFlyPath = true
			return
			
		end
		
		s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	
	end
end

function Gunship:SetVehicleEntityTransform()
	local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
	local s_VehicleEntity = s_VehicleEntityIterator:Next()
	
	while s_VehicleEntity do
			
		if s_VehicleEntity.data.instanceGuid == Guid('81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778') then
			
			s_VehicleEntity = SpatialEntity(s_VehicleEntity)
			
			local s_StartTransform = LinearTransform(Vec3(-0.459440, 0.000000, -0.888209), Vec3(0.000000, 1.000000, 0.000000), Vec3(0.888209, 0.000000, -0.459440), Vec3(-528.583984, 556.093933, -327.112305))
			s_VehicleEntity.transform = s_StartTransform

			break
		end
		s_VehicleEntity = s_VehicleEntityIterator:Next()
	
	end
end

function Gunship:SetLocatorEntityTransform(p_First)
	local s_LocatorEntityIterator = EntityManager:GetIterator("LocatorEntity")
	local s_LocatorEntity = s_LocatorEntityIterator:Next()
	
	while s_LocatorEntity do
		
		s_LocatorEntity = SpatialEntity(s_LocatorEntity)
		local s_DirectionTransform = LinearTransform(Vec3(-0.459440, 0.000000, -0.888209), Vec3(0.000000, 1.000000, 0.000000), Vec3(0.888209, 0.000000, -0.459440), Vec3(-491.778320, 553.822815, -346.150391))
		if p_First then
			s_DirectionTransform.trans.y = 556.093933
		end
		s_LocatorEntity.transform = s_DirectionTransform
		
		s_LocatorEntity = s_LocatorEntityIterator:Next()
	
	end
end

return Gunship
