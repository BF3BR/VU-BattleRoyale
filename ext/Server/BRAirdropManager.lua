class "BRAirdropManager"

local m_Logger = Logger("BRAirdropManager", true)

local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

local m_ItemDatabase = require "Types/BRItemDatabase"
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
local m_LootRandomizer = require "BRLootRandomizer"

function BRAirdropManager:__init()
	self:RegisterVars()
end

function BRAirdropManager:RegisterVars()
	self.m_AirdropTimers = {}
	self.m_AirdropHandles = {}
end

function BRAirdropManager:CreateAirdrop(p_Trans)
	if p_Trans == nil then
		return
	end

	local s_Bp = ObjectBlueprint(
		ResourceManager:SearchForInstanceByGuid(Guid("261E43BF-259B-BF3B-41D2-0000BBBDBBBF"))
	)

	local s_CreationParams = EntityCreationParams()
	s_CreationParams.transform = p_Trans
	s_CreationParams.networked = true

	local s_CreatedBus = EntityManager:CreateEntitiesFromBlueprint(s_Bp, s_CreationParams)
	
	if s_CreatedBus == nil then
		m_Logger:Write("CreatedBus is nil for the Airdrop.")
		return
	end

	for _, l_Entity in pairs(s_CreatedBus.entities) do
		l_Entity:Init(Realm.Realm_ClientAndServer, true)
		local l_PhysicsEntity = PhysicsEntity(l_Entity)

		local l_CollisionCallback = l_PhysicsEntity:RegisterCollisionCallback(function(p_Entity, p_CollisionInfo)
			if p_CollisionInfo.entity.typeInfo.name == "ServerSoldierEntity" then
				return
			end

			if self.m_AirdropTimers[p_Entity.instanceId] ~= nil then
				self.m_AirdropTimers[p_Entity.instanceId]:Destroy()
			end

			local s_Table = {
				transform = SpatialEntity(p_Entity).transform,
				entity = p_Entity,
				handle = self.m_AirdropHandles,
			}

			self.m_AirdropTimers[p_Entity.instanceId] = g_Timers:Timeout(2.5, s_Table, function(p_Table)
				local s_RandomWeaponDefinition = m_LootRandomizer:Randomizer(tostring(Tier.Tier3) .. "_Weapon", m_WeaponDefinitions, true, Tier.Tier3)

				-- Get a randomized attachment
				local s_AttachmentDefinition = m_LootRandomizer:Randomizer(tostring(s_RandomWeaponDefinition.m_Name) .. "_Attachment", m_AttachmentDefinitions, true, nil, s_RandomWeaponDefinition.m_EbxAttachments)
		
				-- Get the ammo definition
				local s_AmmoDefinition = s_RandomWeaponDefinition.m_AmmoDefinition

				local s_WeaponItem = m_ItemDatabase:CreateItem(s_RandomWeaponDefinition)
				local s_AttachmentItem = m_ItemDatabase:CreateItem(s_AttachmentDefinition)
				local s_AmmoItem = m_ItemDatabase:CreateItem(s_AmmoDefinition, s_AmmoDefinition.m_MaxStack * math.random(1, 2))
				local s_LargeMedkitItem = m_ItemDatabase:CreateItem(m_ConsumableDefinitions["consumable-large-medkit"])
				local s_HelmetItem = m_ItemDatabase:CreateItem(m_HelmetDefinitions["helmet-tier-3"])
				local s_ArmorItem = m_ItemDatabase:CreateItem(m_ArmorDefinitions["armor-tier-3"])

				m_LootPickupDatabase:CreateAirdropLootPickup(p_Table.transform, {
					s_WeaponItem,
					s_AttachmentItem,
					s_AmmoItem,
					s_LargeMedkitItem,
					s_HelmetItem,
					s_ArmorItem
				})

				if p_Table.handle[p_Table.entity.instanceId] ~= nil then
					local s_PhysicsEntity = PhysicsEntity(p_Table.entity)
					s_PhysicsEntity:UnregisterCollisionCallback(p_Table.handle[s_PhysicsEntity.instanceId])
					s_PhysicsEntity:FireEvent("Disable")
					s_PhysicsEntity:FireEvent("Destroy")
					s_PhysicsEntity:Destroy()
				end
			end)
		end)

		self.m_AirdropHandles[l_PhysicsEntity.instanceId] = l_CollisionCallback
	end
end

return BRAirdropManager()
