class "Airdrop"

local m_AirdropObjectBlueprint = DC(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"), Guid("DE3ABA3C-D0D1-9863-50FB-D48577340978"))
local m_RigidMesh = DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))
local m_HavokAsset = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("CB8BB4E2-E1F4-EA1D-E815-3DFD8765447B"))
local m_PartComponentData = DC(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"), Guid("1AA3DF7F-B284-938A-7AF0-102EFD478439"))
local m_RigidBodyData2 = DC(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"), Guid("D759F02E-691B-67EF-702B-E1653B2885EF"))

local m_Logger = Logger("Airdrop", true)

function Airdrop:OnRegisterEntityResources()
	--[[DC:WaitForInstances({
		m_AirdropObjectBlueprint,
		m_RigidMesh,
		m_HavokAsset,
		m_PartComponentData,
		m_RigidBodyData2
	}, self, self.OnCreateAirdropObjectBlueprint)]]
	self:OnCreateAirdropObjectBlueprint()
end

function Airdrop:OnCreateAirdropObjectBlueprint()
	local s_RigidBodyData1 = RigidBodyData(MathUtils:RandomGuid())
	s_RigidBodyData1.inertiaModifier = Vec3(1, 1, 1)
	s_RigidBodyData1.rigidBodyType = RigidBodyType.RBTypeCollision
	s_RigidBodyData1.mass = 800
	s_RigidBodyData1.restitution = 0.4
	s_RigidBodyData1.friction = 0.5
	s_RigidBodyData1.angularVelocityDamping = -1
	s_RigidBodyData1.linearVelocityDamping = 0.125
	s_RigidBodyData1.interactionToolkitCollisionVolumeId = 0
	s_RigidBodyData1.motionType = RigidBodyMotionType.RigidBodyMotionType_Dynamic
	s_RigidBodyData1.qualityType = RigidBodyQualityType.RigidBodyQualityType_Invalid
	s_RigidBodyData1.collisionLayer = RigidBodyCollisionLayer.RigidBodyCollisionLayer_Invalid

	local s_PhysicsEntityData = PhysicsEntityData(MathUtils:RandomGuid())
	s_PhysicsEntityData.scaledAssets:add(m_HavokAsset:GetInstance())
	s_PhysicsEntityData.rigidBodies:add(s_RigidBodyData1)
	s_PhysicsEntityData.rigidBodies:add(m_RigidBodyData2:GetInstance())
	s_PhysicsEntityData.inertiaModifier = Vec3(1, 1, 1)
	s_PhysicsEntityData.mass = 1000010
	s_PhysicsEntityData.restitution = 1000010
	s_PhysicsEntityData.friction = 1000010
	s_PhysicsEntityData.linearVelocityDamping = -1
	s_PhysicsEntityData.angularVelocityDamping = -1
	s_PhysicsEntityData.encapsulatePartsInLists = false
	s_PhysicsEntityData.movableParts = false

	local s_BangerEntityData = BangerEntityData(MathUtils:RandomGuid())
	s_BangerEntityData.scales:add(1)
	s_BangerEntityData.mesh = m_RigidMesh:GetInstance()
	s_BangerEntityData.timeToLive = 0.0
	s_BangerEntityData.destructiblePartCount = 0
	s_BangerEntityData.useVariableNetworkFrequency = true
	s_BangerEntityData.physicsData = s_PhysicsEntityData
	s_BangerEntityData.components:add(m_PartComponentData:GetInstance())
	s_BangerEntityData.enabled = true
	s_BangerEntityData.runtimeComponentCount = 1
	s_BangerEntityData.transform = LinearTransform()

	local s_ObjectBlueprint = ObjectBlueprint(Guid("261E43BF-259B-BF3B-41D2-0000BBBDBBBF"))
	s_ObjectBlueprint.object = s_BangerEntityData
	s_ObjectBlueprint.needNetworkId = true
	s_ObjectBlueprint.interfaceHasConnections = false
	s_ObjectBlueprint.alwaysCreateEntityBusClient = false
	s_ObjectBlueprint.alwaysCreateEntityBusServer = false
	s_ObjectBlueprint.name = "BR/Props/Airdrop_Banger"

	--[[local s_AirdropBlueprint = m_AirdropObjectBlueprint:GetInstance()
	local s_Partition = s_AirdropBlueprint.partition
	local s_Registry = RegistryContainer()

	local s_ObjectBlueprint = ObjectBlueprint(s_AirdropBlueprint:Clone(Guid("261E43BF-259B-BF3B-41D2-0000BBBDBBBF")))
	local s_BangerEntityData = BangerEntityData(s_ObjectBlueprint.object)

	s_BangerEntityData:MakeWritable()
	s_BangerEntityData.mesh = m_RigidMesh:GetInstance()
	s_BangerEntityData.timeToLive = 0.0

	local s_PhysicsData = PhysicsEntityData(s_BangerEntityData.physicsData)
	s_PhysicsData:MakeWritable()
	s_PhysicsData.scaledAssets:clear()
	s_PhysicsData.scaledAssets:add(m_HavokAsset:GetInstance())
	
	local s_RigidBodyData = RigidBodyData(s_PhysicsData.rigidBodies[1])
	s_RigidBodyData:MakeWritable()
	s_RigidBodyData.mass = 800
	s_RigidBodyData.linearVelocityDamping = 0.125
	]]

	local s_Registry = RegistryContainer()
	s_Registry.entityRegistry:add(s_RigidBodyData1)
	s_Registry.entityRegistry:add(s_PhysicsEntityData)
	s_Registry.entityRegistry:add(s_BangerEntityData)
	s_Registry.blueprintRegistry:add(s_ObjectBlueprint)
	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)

	
	local s_Partition = ResourceManager:FindDatabasePartition(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"))
	s_Partition:AddInstance(s_ObjectBlueprint)

	--local s_Partition = p_AirdropObjectBlueprint.partition
	--s_Partition:AddInstance(s_ObjectBlueprint)

	m_Logger:Write("Airdrop blueprint created.")
end

return Airdrop()
