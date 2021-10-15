class "Airdrop"

local m_AirdropObjectBlueprint = DC(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"), Guid("DE3ABA3C-D0D1-9863-50FB-D48577340978"))
local m_RigidMesh = DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))
local m_HavokAsset = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("CB8BB4E2-E1F4-EA1D-E815-3DFD8765447B"))

local m_Logger = Logger("Airdrop", true)

function Airdrop:RegisterCallbacks()
	DC:WaitForInstances({m_AirdropObjectBlueprint, m_RigidMesh, m_HavokAsset}, self, self.CreateObjectBlueprint)
end

function Airdrop:DeregisterCallbacks()
	m_AirdropObjectBlueprint:Deregister()
	m_RigidMesh:Deregister()
	m_HavokAsset:Deregister()
end

function Airdrop:CreateObjectBlueprint()
	local s_AirdropBlueprint = m_AirdropObjectBlueprint:GetInstance()
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
	s_RigidBodyData.mass = 1500
	s_RigidBodyData.linearVelocityDamping = 0.1

	s_Partition:AddInstance(s_ObjectBlueprint)

	s_Registry.blueprintRegistry:add(s_ObjectBlueprint)
	s_Registry.entityRegistry:add(s_BangerEntityData)

	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)

	m_Logger:Write("Airdrop blueprint created.")
end

return Airdrop()
