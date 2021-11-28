class "BRAirdropManager"

require "__shared/Enums/AirdropEnums"

local m_Logger = Logger("BRAirdropManager", true)

local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

local m_ItemDatabase = require "Types/BRItemDatabase"
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
local m_LootRandomizer = require "BRLootRandomizer"
local m_Gunship = require "Gunship"

function BRAirdropManager:__init()
	self:RegisterVars()
end

function BRAirdropManager:RegisterVars()
	self.m_AirdropTimers = {}
	self.m_AirdropHandles = {}

    self.m_AirdropCenterPos = nil
    self.m_AirdropDropped = true
end

function BRAirdropManager:OnEngineUpdate(p_DeltaTime)
    if not self.m_AirdropDropped then
        local s_PlaneDistance = self:GetPlaneDistance()
        if s_PlaneDistance ~= nil and s_PlaneDistance <= 2.5 then
            self:CreateAirdrop(m_Gunship:GetDropPosition())
            self.m_AirdropDropped = true
			NetEvents:BroadcastLocal("Airdrop:Dropped")
        end
    end
end

function BRAirdropManager:GetPlaneDistance()
    if self.m_AirdropCenterPos == nil then
        return
    end

    if not m_Gunship:IsEnabled() or m_Gunship:GetType() ~= "Airdrop" then
        return nil
    end

    local s_GunshipPos = m_Gunship:GetCurrentPosition(m_Gunship.m_CalculatedTime)

    if s_GunshipPos == nil then
        return nil
    end

    return self.m_AirdropCenterPos:Distance(s_GunshipPos)
end

function BRAirdropManager:CreatePlane(p_Trans)
	if p_Trans == nil then
		return
	end

    local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return
	end

    local s_Angle = math.random(0, 359)
    local s_OppositeAngle = 0
    if s_Angle <= 179 then
        s_OppositeAngle = s_Angle + 180
    else
        s_OppositeAngle = s_Angle - 180
    end

    m_Gunship:Enable(
        self:RandomPointWithAngle(p_Trans, math.rad(s_Angle), MapsConfig[s_LevelName]["InitialCircle"]["Radius"] * 1.5),
        self:RandomPointWithAngle(p_Trans, math.rad(s_OppositeAngle), MapsConfig[s_LevelName]["InitialCircle"]["Radius"] * 1.5),
        45,
        "Airdrop",
        true
    )

    self.m_AirdropCenterPos = p_Trans
    self.m_AirdropDropped = false
end

function BRAirdropManager:CreateAirdrop(p_Trans)
	if p_Trans == nil then
		return
	end

	local s_Bp = ObjectBlueprint(
		ResourceManager:SearchForInstanceByGuid(AirdropGuids.CustomAirdropGuid)
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

function BRAirdropManager:RandomPointWithAngle(p_Center, p_Angle, p_Radius)
	local s_X = p_Center.x + p_Radius * math.cos(p_Angle)
	local s_Z = p_Center.z + p_Radius * math.sin(p_Angle)

	return Vec3(s_X, p_Center.y, s_Z)
end

-- define global
if g_BRAirdropManager== nil then
    g_BRAirdropManager = BRAirdropManager()
end

return g_BRAirdropManager
