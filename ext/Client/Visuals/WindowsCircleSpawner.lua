-- Credits go to NoFate for the idea and implementation xD

class "WindowsCircleSpawner"

local m_Logger = Logger("WindowsCircleSpawner", true)
local m_ScalingMatrix = LinearTransform(
	Vec3(1.0, 0.0, 0.0),
	Vec3(0.0, 100.0, 0.0),
	Vec3(0.0, 0.0, 1.0),
	Vec3(0.0, 0.0, 0.0)
)
local m_MagicScalingNumber = 1.66

-- 'XP3/Architecture/Barrack_02/Barrack_02_Window_01'
local m_WindowBP = DC(Guid("C2F9C48C-A4EB-11E1-ABB8-FED5C2003E58"), Guid("11DEF780-CA1C-D8A7-A389-E267D1146509"))

function WindowsCircleSpawner:__init()
	self.m_Entities = {}
	self.m_EntityData = nil
end

function WindowsCircleSpawner:SpawnWindow(p_From, p_To, p_EdgeLength, p_Index)
	local s_MapConfig = MapsConfig[LevelNameHelper:GetLevelName()]

	-- create entity transform
	local s_Angle = math.atan(p_To.z - p_From.z, p_To.x - p_From.x)
	local s_EntityTrans = MathUtils:GetTransformFromYPR(-s_Angle, 0, 0)
	s_EntityTrans.trans = Vec3(p_To.x, s_MapConfig.CircleWallY, p_To.z)

	-- scale entity transform
	local s_XScaling = p_EdgeLength / m_MagicScalingNumber
	m_ScalingMatrix.left.x = s_XScaling
	m_ScalingMatrix.up.y = s_MapConfig.CircleWallHeightModifier
	s_EntityTrans = m_ScalingMatrix * s_EntityTrans

	-- get or create an entity and update it's transform
	local s_Entity = self:GetOrCreateEntity(p_Index, s_EntityTrans)
	if s_Entity ~= nil then
		SpatialEntity(s_Entity).transform = s_EntityTrans
	end
end

function WindowsCircleSpawner:GetOrCreateEntity(p_Index, p_EntityTrans)
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
	local s_CreatedEntity = EntityManager:CreateEntity(s_EntityData, p_EntityTrans)
	if s_CreatedEntity ~= nil then
		s_CreatedEntity:Init(Realm.Realm_Client, true)
		table.insert(self.m_Entities, s_CreatedEntity)
		m_Logger:Write("Created a new entity")
	end

	return s_CreatedEntity
end

function WindowsCircleSpawner:GetEntityData()
	if self.m_EntityData ~= nil then
		return self.m_EntityData
	end

	local s_ObjectBlueprint = m_WindowBP:GetInstance()
	if s_ObjectBlueprint ~= nil then
		self.m_EntityData = StaticModelEntityData(s_ObjectBlueprint.object)
	end

	return self.m_EntityData
end

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

function WindowsCircleSpawner:OnExtensionUnloading()
	self:Destroy()
end

function WindowsCircleSpawner:OnLevelDestroy()
	self:Destroy()
end

function WindowsCircleSpawner:__gc()
	self:Destroy()
end

-- define global
if g_WindowsCircleSpawner == nil then
	g_WindowsCircleSpawner = WindowsCircleSpawner()
end

return g_WindowsCircleSpawner
