
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

--FX_DLC3_XP3_Shield_Pollen_CamProx
ResourceManager:RegisterInstanceLoadHandler(Guid('381A69CF-695D-4055-B0AD-5218711E3411'), Guid('A24EEEDF-FCF3-46EA-804F-765657A612DE'), function(p_Instance)
	p_Instance = EffectEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullDistance = 10000000.0
	p_Instance.maxInstanceCount = 100
end)

--FX_DLC3_XP3_Shield_Pollen_CamProx_02
ResourceManager:RegisterInstanceLoadHandler(Guid('0C1ECED7-AA15-4206-A62F-7D44FE153E3C'), Guid('401F99D9-3093-4F1E-9B23-498C634B9BF5'), function(p_Instance)
	p_Instance = EffectEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullDistance = 10000000.0
	p_Instance.maxInstanceCount = 100
end)

--FX_DLC3_XP3_Shield_Pollen_CamProx_03
ResourceManager:RegisterInstanceLoadHandler(Guid('5F470049-4215-4E97-B07E-BA422A57C14C'), Guid('657F2376-0B99-4C78-9024-C7FB74C3C3A0'), function(p_Instance)
	p_Instance = EffectEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.cullDistance = 10000000.0
	p_Instance.maxInstanceCount = 100
end)
