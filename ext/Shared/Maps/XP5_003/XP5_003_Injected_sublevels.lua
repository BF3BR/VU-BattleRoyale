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

-- =============================================
-- Disable destruction on X assets
-- =============================================

--MEC_House_Low_02_V2
ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('5F96ED33-D47A-ACB6-DE80-A59BFFD6485A'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('3FB5D38D-F259-A055-0559-17A37D6404AD'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('AFB1BACE-DE83-19DC-839B-00966E85C455'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('0CAE178D-66F5-1591-8D4C-8CF8EEC62207'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('892931DC-624D-DE2C-D2EE-C086E111A8DD'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('3FD0AFEA-F2FE-D6B6-F9D7-DC744E805F7B'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('A3081468-864B-74FC-EE5F-EC885A96F19F'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('AAA0BBAE-6D38-1D9D-B2EB-69FEE42B9183'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('A24D997F-673B-FC22-991E-A72578A69983'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('B8466EDB-F5C4-D425-42FC-060C6D7B01CE'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('BA441450-F0C0-19C6-69F9-F3777D0A9CBB'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('80366CDD-3E18-1120-6D66-7024EE30C514'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('B196FFE0-EC20-7BBC-D403-B1FD1EF977CB'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

--ME_House01_Garage_Destruction
ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('C10FC461-FB35-D98F-DF5F-991EAC90D210'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('6763D0BF-C8F0-B2CB-5C47-5D3B71E84C31'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('334D0FB2-BC98-9F9F-193B-F72E64CE55DA'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('4EA2A78E-798B-2CCE-7A54-E735D0E3D714'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('851B14D5-5878-7A25-4059-6FA61601B87A'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('D722D65E-BA26-B4CA-1400-9E2CFFEAFCA2'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('CA3429E5-B1E5-8DE2-2D4F-8CA6035FC5B3'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)

ResourceManager:RegisterInstanceLoadHandler(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('67409BE4-A1FC-F745-9F54-4052F655088D'), function(p_Instance)
	p_Instance = BreakablePartComponentData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.healthPercentage = 10000000
end)
