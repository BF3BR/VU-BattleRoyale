Events:Subscribe('Level:RegisterEntityResources', function(p_LevelData)
	if SharedUtils:GetLevelName() ~= 'Levels/XP5_003/XP5_003' then
		return
	end

	local s_XP3_Shield_LevelPropsLargeReferenceData = WorldPartReferenceObjectData(ResourceManager:FindInstanceByGuid(Guid('69AFE35D-259F-11E1-98E7-C42BEF8FFB67'), Guid('080E0293-4B9D-479C-A663-912BDC6CB24D')))
	local s_Cloned_LevelPropsLargeReferenceData = WorldPartReferenceObjectData(s_XP3_Shield_LevelPropsLargeReferenceData:Clone(Guid('B813FFD1-B3B4-1A0D-F0AE-C07B73399DEE')))

	p_LevelData = LevelData(p_LevelData)
	p_LevelData:MakeWritable()
	p_LevelData.objects:add(s_Cloned_LevelPropsLargeReferenceData)
end)

-- =============================================
-- Cull Distance & Lod
-- =============================================

-- tent_01_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('7399C5F9-F745-522F-1A75-8C235D9DF360'), Guid('E3E4DD13-7444-549D-167B-758EF57B24BB'), function(p_Instance)
	p_Instance = CompositeMeshAsset(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullScale = 50.0
end)

-- Bulkhead_01_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('BC838068-4D37-43D6-FCE2-D632D08459CC'), Guid('4A9E53C7-0A3B-11DE-B857-DBBDD7D66D76'), function(p_Instance)
	p_Instance = RigidMeshAsset(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullScale = 50.0
end)

-- PowerLine_01B_BrokenBase_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('1E857D81-FFDF-1EBC-D6F2-082F304F5809'), Guid('AB778B7A-AE12-98BC-5733-90A64F29EFFF'), function(p_Instance)
	p_Instance = RigidMeshAsset(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullScale = 50.0
	p_Instance.lodScale = 3.0
end)
