class("SkeletonMeshModel", MeshModel)

function SkeletonMeshModel:__init(p_MeshAsset, p_Variation, p_BoneCount, p_BoneOffsets)
    MeshModel.__init(self, p_MeshAsset, p_Variation)
    self.m_BoneCount = p_BoneCount
    self.m_BoneOffsets = p_BoneOffsets or {}
end

function SkeletonMeshModel:Draw(p_LootPickup, p_LocalTransform)
    local s_MeshAsset = self.m_Mesh:GetInstance()
    if s_MeshAsset == nil then
        return nil
    end

	local s_Data = StaticModelEntityData()
	s_Data.mesh = s_MeshAsset
    s_Data.transform = p_LocalTransform

    if p_LootPickup.m_Type.PhysicsEntityData ~= nil then
        s_Data.physicsData = p_LootPickup.m_Type.PhysicsEntityData:GetInstance()
    end

    for l_Index = 1, self.m_BoneCount do
        s_Data.basePoseTransforms:add(self.m_BoneOffsets[l_Index] or LinearTransform())
    end

    local s_Params = EntityCreationParams()
    s_Params.variationNameHash = self.m_Variation
    s_Params.transform = p_LootPickup.m_Transform
		
	local s_Entity = EntityManager:CreateEntity(s_Data, s_Params)

	if s_Entity ~= nil then
		s_Entity:Init(Realm.Realm_ClientAndServer, true)
		return s_Entity
	end

    return nil
end
