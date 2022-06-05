-- Credits go to NoFate for the idea and implementation xD

---@class WindowsCircleSpawner
WindowsCircleSpawner = class "WindowsCircleSpawner"

---@type RotationHelper
local m_RotationHelper = require "__shared/Utils/RotationHelper"

local m_MagicScalingNumber = 2.5

-- 'Architecture/Warehouse_02/DebrisClusters/Warehouse_02_WindowBroken_01'
---@type DC
local m_WindowBP = DC(Guid("AFEA12FF-A2F8-11E0-9D5D-D43B5C1D8C9B"), Guid("319952E5-30F8-86E1-2FA0-890716D7D491"))

function WindowsCircleSpawner:__init()
	self.m_Entities = {}
	self.m_EntityData = nil
end

---@param p_From Vec3
---@param p_To Vec3
---@param p_EdgeLength number
---@param p_CachedEntityIndex integer
function WindowsCircleSpawner:SpawnWindow(p_From, p_To, p_EdgeLength, p_CachedEntityIndex)
	local s_MapConfig = MapsConfig[LevelNameHelper:GetLevelName()]

	-- create entity transform
	local s_Angle = math.atan(p_To.z - p_From.z, p_To.x - p_From.x)
	local s_EntityTrans = MathUtils:GetTransformFromYPR(-s_Angle, 0, 0)
	s_EntityTrans.trans = Vec3((p_From.x + p_To.x) / 2, s_MapConfig.CircleWallY, (p_From.z + p_To.z) / 2)

	local s_Left, s_Up, s_Forward = m_RotationHelper:GetLUFfromYPR(0, math.pi, 0)

	-- scale entity transform
	local s_XScaling = p_EdgeLength / m_MagicScalingNumber
	local s_ScalingMatrix = LinearTransform(
		Vec3(s_Left.x * s_XScaling, s_Left.y, s_Left.z),
		Vec3(s_Up.x, s_Up.y * s_MapConfig.CircleWallHeightModifier, s_Up.z),
		s_Forward,
		Vec3(0.0, 0.0, 0.0)
	)
	s_EntityTrans = s_ScalingMatrix * s_EntityTrans

	-- get or create an entity and update it's transform
	local s_Entity = self:GetOrCreateEntity(p_CachedEntityIndex, s_EntityTrans)
	if s_Entity ~= nil then
		SpatialEntity(s_Entity).transform = s_EntityTrans
	end
end

---@param p_Index integer
---@param p_EntityTransform LinearTransform
---@return Entity|nil
function WindowsCircleSpawner:GetOrCreateEntity(p_Index, p_EntityTransform)
	-- check if there's an available entity to use
	if p_Index <= #self.m_Entities then
		return self.m_Entities[p_Index]
	end

	-- get entity data
	local s_EntityData = self:GetEntityData()
	if s_EntityData == nil then
		return nil
	end

	-- create and save new entity
	local s_CreatedEntity = EntityManager:CreateEntity(s_EntityData, p_EntityTransform)
	if s_CreatedEntity ~= nil then
		s_CreatedEntity:Init(Realm.Realm_Client, true)
		table.insert(self.m_Entities, s_CreatedEntity)
	end

	return s_CreatedEntity
end

---@return StaticModelEntityData
function WindowsCircleSpawner:GetEntityData()
	if self.m_EntityData ~= nil then
		return self.m_EntityData
	end

	---@type ObjectBlueprint|nil
	local s_ObjectBlueprint = m_WindowBP:GetInstance()
	if s_ObjectBlueprint ~= nil then
		self.m_EntityData = StaticModelEntityData(s_ObjectBlueprint.object)
	end

	return self.m_EntityData
end

---@param p_StartIndex integer|nil
function WindowsCircleSpawner:DestroyEntities(p_StartIndex)
	p_StartIndex = p_StartIndex or 1

	-- destroy selected entities
	for l_Index = #self.m_Entities, p_StartIndex, -1 do
		local s_Entity = self.m_Entities[l_Index]

		if s_Entity ~= nil then
			s_Entity:Destroy()
			table.remove(self.m_Entities, l_Index)
		end
	end

	-- clear entities array if all entities got destroyed
	if p_StartIndex == 1 then
		self.m_Entities = {}
	end
end

function WindowsCircleSpawner:Destroy()
	self:DestroyEntities()
	self.m_EntityData = nil
end

---VEXT Shared Extension:Unloading Event
function WindowsCircleSpawner:OnExtensionUnloading()
	self:Destroy()
end

---VEXT Shared Level:Destroy Event
function WindowsCircleSpawner:OnLevelDestroy()
	self:Destroy()
end

function WindowsCircleSpawner:__gc()
	self:Destroy()
end

return WindowsCircleSpawner()
