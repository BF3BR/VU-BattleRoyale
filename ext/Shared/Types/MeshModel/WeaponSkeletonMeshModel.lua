class("WeaponSkeletonMeshModel", MeshModel)

local m_MapHelper = require "__shared/Utils/MapHelper"

function WeaponSkeletonMeshModel:__init(p_MeshAsset, p_Variation)
    MeshModel.__init(self, p_MeshAsset, p_Variation)
end

function WeaponSkeletonMeshModel:Draw(p_LootPickup, p_LocalTransform)
    local s_MeshAsset = self.m_Mesh:GetInstance()
    if s_MeshAsset == nil then
        return nil
    end

    local s_SingleItem = m_MapHelper:NextItem(p_LootPickup.m_Items)

    if s_SingleItem == nil then
        return nil
    end

	local s_Data = StaticModelEntityData()
	s_Data.mesh = s_MeshAsset
    s_Data.transform = p_LocalTransform

    if p_LootPickup.m_Type.PhysicsEntityData ~= nil then
        s_Data.physicsData = p_LootPickup.m_Type.PhysicsEntityData:GetInstance()
    end

    local s_SoldierWeaponUnlockAsset = s_SingleItem.m_Definition.m_SoldierWeaponBlueprint:GetInstance()
    local s_SoldierWeaponData = SoldierWeaponData(s_SoldierWeaponUnlockAsset.weapon.object)
    for _, l_LinearTransform in pairs(s_SoldierWeaponData.weaponStates[1].mesh3pTransforms) do        
        s_Data.basePoseTransforms:add(l_LinearTransform)
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
