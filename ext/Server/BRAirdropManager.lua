---@class BRAirdropManager
BRAirdropManager = class "BRAirdropManager"

---@type Logger
local m_Logger = Logger("BRAirdropManager", false)

---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
---@module "Items/Definitions/BRItemArmorDefinition"
---@type table<string, BRItemArmorDefinition>
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
---@module "Items/Definitions/BRItemAttachmentDefinition"
---@type table<string, BRItemAttachmentDefinition>
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
---@module "Items/Definitions/BRItemConsumableDefinition"
---@type table<string, BRItemConsumableDefinition>
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
---@module "Items/Definitions/BRItemHelmetDefinition"
---@type table<string, BRItemHelmetDefinition>
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
---@module "Items/Definitions/BRItemWeaponDefinition"
---@type table<string, BRItemWeaponDefinition>
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

---@type BRItemDatabase
local m_ItemDatabase = require "Types/BRItemDatabase"
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type BRLootRandomizer
local m_LootRandomizer = require "BRLootRandomizer"
---@type GunshipServer
local m_GunshipServer = require "GunshipServer"

function BRAirdropManager:__init()
	self:RegisterVars()
end

function BRAirdropManager:RegisterVars()
	---@type table<integer, Timer>
	---`[instanceId] -> Timer`
	self.m_AirdropTimers = {}
	---@type table<integer, integer>
	---`[instanceId] -> handle`
	self.m_AirdropHandles = {}

	---@type Vec3|nil
	self.m_AirdropCenterPos = nil
	self.m_AirdropDropped = true
end

---@param p_DeltaTime number
function BRAirdropManager:OnEngineUpdate(p_DeltaTime)
	if not self.m_AirdropDropped then
		local s_PlaneDistance = self:GetPlaneDistance()

		if s_PlaneDistance ~= nil and s_PlaneDistance <= 2.5 then
			self:CreateAirdrop(m_GunshipServer:GetDropPosition())
			self.m_AirdropDropped = true
			NetEvents:BroadcastLocal("Airdrop:Dropped")
		end
	end
end

---@return number|nil
function BRAirdropManager:GetPlaneDistance()
	if self.m_AirdropCenterPos == nil then
		return
	end

	-- if disabled or wrong type
	if not m_GunshipServer:IsEnabled() or m_GunshipServer:GetType() ~= "Airdrop" then
		return nil
	end

	local s_GunshipPos = m_GunshipServer:GetCurrentPosition()

	if s_GunshipPos == nil then
		return nil
	end

	return self.m_AirdropCenterPos:Distance(s_GunshipPos)
end

---@param p_Trans Vec3|nil
function BRAirdropManager:CreatePlane(p_Trans)
	if p_Trans == nil then
		return
	end

	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return
	end

	---@type integer
	local s_Angle = math.random(0, 359)
	---@type integer
	local s_OppositeAngle = 0

	if s_Angle <= 179 then
		s_OppositeAngle = s_Angle + 180
	else
		s_OppositeAngle = s_Angle - 180
	end

	m_GunshipServer:Enable(
		self:RandomPointWithAngle(p_Trans, math.rad(s_Angle), MapsConfig[s_LevelName]["InitialCircle"]["Radius"] * 1.5),
		self:RandomPointWithAngle(p_Trans, math.rad(s_OppositeAngle), MapsConfig[s_LevelName]["InitialCircle"]["Radius"] * 1.5),
		45,
		"Airdrop",
		true
	)

	self.m_AirdropCenterPos = p_Trans
	self.m_AirdropDropped = false
end

---@param p_Transform LinearTransform|nil
function BRAirdropManager:CreateAirdrop(p_Transform)
	if p_Transform == nil then
		return
	end

	local s_ObjectBlueprint = ObjectBlueprint(
		ResourceManager:SearchForInstanceByGuid(AirdropGuids.CustomAirdropGuid)
	)

	local s_CreationParams = EntityCreationParams()
	s_CreationParams.transform = p_Transform
	s_CreationParams.networked = true

	local s_CreatedBus = EntityManager:CreateEntitiesFromBlueprint(s_ObjectBlueprint, s_CreationParams)

	if s_CreatedBus == nil then
		m_Logger:Write("CreatedBus is nil for the Airdrop.")
		return
	end

	for _, l_Entity in pairs(s_CreatedBus.entities) do
		l_Entity:Init(Realm.Realm_ClientAndServer, true)
		local l_PhysicsEntity = PhysicsEntity(l_Entity)

		local l_CollisionCallback = l_PhysicsEntity:RegisterCollisionCallback(
		---@param p_Entity Entity
		---@param p_CollisionInfo CollisionInfo
			function(p_Entity, p_CollisionInfo)
				if p_CollisionInfo.entity.typeInfo.name == "ServerSoldierEntity" then
					return
				end

				if self.m_AirdropTimers[p_Entity.instanceId] ~= nil then
					self.m_AirdropTimers[p_Entity.instanceId]:Destroy()
				end

				---@class AirdropTable
				local s_Table = {
					transform = SpatialEntity(p_Entity).transform,
					entity = p_Entity,
					handle = self.m_AirdropHandles,
				}

				self.m_AirdropTimers[p_Entity.instanceId] = m_TimerManager:Timeout(2.5, s_Table,
					---@param p_Table AirdropTable
					function(p_Table)
						---@type BRItemWeaponDefinition
						local s_RandomWeaponDefinition = m_LootRandomizer:Randomizer(tostring(Tier.Tier3) .. "_Weapon", m_WeaponDefinitions, true, Tier.Tier3)

						-- Get a randomized attachment
						---@type BRItemAttachmentDefinition
						local s_AttachmentDefinition = m_LootRandomizer:Randomizer(tostring(s_RandomWeaponDefinition.m_Name) .. "_Attachment", m_AttachmentDefinitions, true, nil, s_RandomWeaponDefinition.m_EbxAttachments)

						-- Get the ammo definition
						---@type BRItemAmmoDefinition
						local s_AmmoDefinition = s_RandomWeaponDefinition.m_AmmoDefinition

						---@type BRItemWeapon
						local s_WeaponItem = m_ItemDatabase:CreateItem(s_RandomWeaponDefinition)
						---@type BRItemAttachment
						local s_AttachmentItem = m_ItemDatabase:CreateItem(s_AttachmentDefinition)
						---@type BRItemAmmo
						local s_AmmoItem = m_ItemDatabase:CreateItem(s_AmmoDefinition, s_AmmoDefinition.m_MaxStack * math.random(1, 2))
						---@type BRItemConsumable
						local s_LargeMedkitItem = m_ItemDatabase:CreateItem(m_ConsumableDefinitions["consumable-large-medkit"])
						---@type BRItemHelmet
						local s_HelmetItem = m_ItemDatabase:CreateItem(m_HelmetDefinitions["helmet-tier-3"])
						---@type BRItemArmor
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

---@param p_Center Vec3
---@param p_Angle integer
---@param p_Radius number
---@return Vec3
function BRAirdropManager:RandomPointWithAngle(p_Center, p_Angle, p_Radius)
	local s_X = p_Center.x + p_Radius * math.cos(p_Angle)
	local s_Z = p_Center.z + p_Radius * math.sin(p_Angle)

	return Vec3(s_X, p_Center.y, s_Z)
end

return BRAirdropManager()
