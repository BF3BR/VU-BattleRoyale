local Gunship = class 'Gunship'

function Gunship:__init(p_Match)
	-- Save match reference
	self.m_Match = p_Match
	
	self.m_JumpOutOfGunshipEvent = NetEvents:Subscribe('JumpOutOfGunship', self, self.OnJumpOutOfGunship)
end

function Gunship:OnJumpOutOfGunship(p_Player)
	
	-- Get the Gunship transform
	-- TODO: Default transform should be the endposition of the gunship
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
end
	
function Gunship:Spawn()
	print("INFO: Spawning the gunship.")
	NetEvents:BroadcastLocal('GunshipCamera')
	
	local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleSpawnEntity")
	local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	
	while s_VehicleSpawnEntity do
		if s_VehicleSpawnEntity.data.instanceGuid == Guid('5449C054-7A18-4696-8AA9-416A8B9A9CD0') then
			s_VehicleSpawnEntity = Entity(s_VehicleSpawnEntity)
			s_VehicleSpawnEntity:FireEvent("Spawn")
			break
		end
		s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	end
	
	local s_SequenceEntityIterator = EntityManager:GetIterator("SequenceEntity")
	local s_SequenceEntity = s_SequenceEntityIterator:Next()
	
	while s_SequenceEntity do
		if s_SequenceEntity.data.instanceGuid == Guid('20F64BEB-665E-4C34-8E01-744EACD1BD16') then
			s_SequenceEntity = Entity(s_SequenceEntity)
			s_SequenceEntity:FireEvent("Start")
			s_SequenceEntity:RegisterEventCallback(self, self.OnSequenceEntityEventCallback)
			return
		end
		s_SequenceEntity = s_SequenceEntityIterator:Next()
	end
end

function Gunship:OnSequenceEntityEventCallback(ent, entityEvent)
	if entityEvent.eventId == 229946160 then -- "Reset"
		print("INFO: OnSequenceEntityEventCallback - Reset")
		NetEvents:BroadcastLocal('ForceJumpOufOfGunship')
	end
end

return Gunship
