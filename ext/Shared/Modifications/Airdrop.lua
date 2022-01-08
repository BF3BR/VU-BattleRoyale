---@class Airdrop
Airdrop = class "Airdrop"

local m_AirdropObjectBlueprint = DC(Guid("344790FB-C800-11E0-BD5B-D85FACD7C899"), Guid("DE3ABA3C-D0D1-9863-50FB-D48577340978"))
local m_RigidMesh = DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))
local m_HavokAsset = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("CB8BB4E2-E1F4-EA1D-E815-3DFD8765447B"))

local m_RegistryManager = require "__shared/Logic/RegistryManager"

local m_Logger = Logger("Airdrop", true)

function Airdrop:RegisterCallbacks()
	m_AirdropObjectBlueprint:RegisterLoadHandler(self, self.ModifyAirdropObject)
end

function Airdrop:DeregisterCallbacks()
	m_AirdropObjectBlueprint:Deregister()
end

function Airdrop:ModifyAirdropObject(p_OriginalBlueprint)
	local s_Partition = p_OriginalBlueprint.partition
	local s_CustomObjectBlueprint = ObjectBlueprint(p_OriginalBlueprint:Clone(AirdropGuids.CustomAirdropGuid))
	s_CustomObjectBlueprint.name = "Props/BattleRoyale/Airdrop_Banger"

	-- We also need to clone the original SoldierEntityData and replace all references to it.
	local s_OriginalBangerEntityData = s_CustomObjectBlueprint.object
	local s_CustomBangerEntityData = BangerEntityData(s_OriginalBangerEntityData:Clone())

	local s_OriginalPhysicsEntityData = s_CustomBangerEntityData.physicsData
	local s_CustomPhysicsEntityData = PhysicsEntityData(s_OriginalPhysicsEntityData:Clone())

	local s_OriginalRigidBodyData = s_CustomPhysicsEntityData.rigidBodies[1]
	local s_CustomRigidBodyData = RigidBodyData(s_OriginalRigidBodyData:Clone())

	s_CustomObjectBlueprint.object = s_CustomBangerEntityData
	s_CustomBangerEntityData.physicsData = s_CustomPhysicsEntityData
	s_CustomPhysicsEntityData.rigidBodies[1] = s_CustomRigidBodyData

	-- Modify all the stuff we need
	s_CustomBangerEntityData.mesh = m_RigidMesh:GetInstance()
	s_CustomBangerEntityData.timeToLive = 0.0

	s_CustomPhysicsEntityData.scaledAssets:clear()
	s_CustomPhysicsEntityData.scaledAssets:add(m_HavokAsset:GetInstance())

	s_CustomRigidBodyData.mass = 800
	s_CustomRigidBodyData.linearVelocityDamping = 0.125

	-- Add our new airdrop blueprint to the partition.
	-- This will make it so we can later look it up by its GUID.
	s_Partition:AddInstance(s_CustomObjectBlueprint)
	m_Logger:Write("Airdrop blueprint created.")
end

function Airdrop:OnRegisterEntityResources()
	-- In order for our custom airdrop to be usable we need to register it with the engine.
	-- This means that during this event we need to create a new registry container and add
	-- all relevant datacontainers to the respective arrays.
	local s_Registry = RegistryContainer()

	-- Locate the custom airdrop BP, get its data, and add to the registry container.
	-- You can fetch the BP in the same way when you want to spawn it
	local s_CustomObjectBlueprint = ObjectBlueprint(ResourceManager:SearchForInstanceByGuid(AirdropGuids.CustomAirdropGuid))
	local s_CustomBangerEntityData = BangerEntityData(s_CustomObjectBlueprint.object)
	local s_CustomPhysicsEntityData = PhysicsEntityData(s_CustomBangerEntityData.physicsData)
	local s_CustomRigidBodyData = RigidBodyData(s_CustomPhysicsEntityData.rigidBodies[1])

	s_Registry.blueprintRegistry:add(s_CustomObjectBlueprint)
	s_Registry.entityRegistry:add(s_CustomBangerEntityData)
	s_Registry.entityRegistry:add(s_CustomPhysicsEntityData)
	s_Registry.entityRegistry:add(s_CustomRigidBodyData)

	-- And then add the registry to the game compartment.
	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
	m_Logger:Write("Airdrop blueprint registered.")
end

return Airdrop()
