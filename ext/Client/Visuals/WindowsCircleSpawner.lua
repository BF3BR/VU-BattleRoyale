-- Credits go to NoFate for the idea and implementation xD

class "WindowsCircleSpawner"

local m_Logger = Logger("WindowsCircleSpawner", true)
local m_ScalingMatrix = LinearTransform(
  Vec3(1.0, 0.0, 0.0),
  Vec3(0.0, 10.0, 0.0),
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

function WindowsCircleSpawner:SpawnWindow(p_From, p_To, p_EdgeLength)
  -- create entity transform
	local s_Angle = math.atan(p_To.z - p_From.z, p_To.x - p_From.x)
	local s_EntityTrans = MathUtils:GetTransformFromYPR(-angle, 0, 0)
	s_EntityTrans.trans = Vec3(p_To.x, p_From.y, p_To.z)

  -- scale entity transform
	local s_XScaling = p_EdgeLength / m_MagicScalingNumber
	m_ScalingMatrix.left.x = s_XScaling
	s_EntityTrans = m_ScalingMatrix * s_EntityTrans

  -- create entity
  local s_EntityData = self:GetEntityData()
  if s_EntityData == nil then
    return
  end
	local s_CreatedEntity = EntityManager:CreateEntity(s_EntityData, s_EntityTrans)

  if s_CreatedEntity ~= nil then
		s_CreatedEntity:Init(Realm.Realm_Client, true)
		table.insert(self.m_Entities, s_CreatedEntity)

		local s_SpatialEntity = s_SpatialEntity(s_CreatedEntity)
		local s_Aabb = spatialEntity.aabb

    local width = s_Aabb.max.x - s_Aabb.min.x
		local height = s_Aabb.max.y - s_Aabb.min.y
		local depth = s_Aabb.max.z - s_Aabb.min.z

		print({
			width = width,
			depth = depth,
			height = height,
		})
	end
end

function WindowsCircleSpawner:DestroyEntities()
  for _, l_Entity in pairs(self.m_Entities) do
    l_Entity:Destroy()
  end

  self.m_Entities = {}
end

function WindowsCircleSpawner:Destroy()
  self:DestroyEntities()
  self.m_EntityData = nil
end

function WindowsCircleSpawner:OnExtensionUnloading()
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
