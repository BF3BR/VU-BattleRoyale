

-- XP3_Shield Map

Events:Subscribe('Partition:Loaded', function(partition)
if SharedUtils:GetLevelName() ~= 'Levels/XP5_003/XP5_003' then
	return
	end

    if partition == nil or partition.name ~= 'levels/xp5_003/xp5_003' then
        return
    end


    -- Airturbines + some props	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    --print('Injecting PropsLarge reference data...')
	--print('PropsLarge spawned')
    local spLevelPropsLargeReferenceData = WorldPartReferenceObjectData(ResourceManager:FindInstanceByGuid(Guid('69AFE35D-259F-11E1-98E7-C42BEF8FFB67'), Guid('080E0293-4B9D-479C-A663-912BDC6CB24D'))) -- To change
    mpLevelPropsLargeReferenceData = WorldPartReferenceObjectData(spLevelPropsLargeReferenceData:Clone(Guid('A0000000-0000-0000-0000-000000000000')))
    mpLevelPropsLargeReferenceData:MakeWritable()
    partition:AddInstance(mpLevelPropsLargeReferenceData)

    -- Add to LevelData objects array
    local mpLevelData = LevelData(ResourceManager:FindInstanceByGuid(Guid('CB9932E2-19E0-11E2-93EC-B0D4179CEA18'), Guid('FB11A0AA-BC0A-31C1-8F95-A8B8D7746908')))
    mpLevelData:MakeWritable()
    mpLevelData.objects:add(mpLevelPropsLargeReferenceData)
	
	
end)


Events:Subscribe('Level:RegisterEntityResources', function(levelData)
    if SharedUtils:GetLevelName() ~= 'Levels/XP5_003/XP5_003' then
        return
    end


    --print('Adding new registry containing relevant SubWorldReferenceData...')
    local newRegistry = RegistryContainer()
    newRegistry.referenceObjectRegistry:add(mpLevelPropsLargeReferenceData) -- PropsLarge

    ResourceManager:AddRegistry(newRegistry, ResourceCompartment.ResourceCompartment_Game)

end)

---------------------------------------------------------

-- Cull Distance & Lod

--tent_01_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('7399C5F9-F745-522F-1A75-8C235D9DF360'), Guid('E3E4DD13-7444-549D-167B-758EF57B24BB'), function(instance)
    
    local thisInstance = CompositeMeshAsset(instance)
    thisInstance:MakeWritable()
    local tent_01_Mesh = (50)
	thisInstance.cullScale = tent_01_Mesh
    --print('Culldistance for tent_01_Mesh set.')
end)

--Bulkhead_01_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('BC838068-4D37-43D6-FCE2-D632D08459CC'), Guid('4A9E53C7-0A3B-11DE-B857-DBBDD7D66D76'), function(instance)
    
    local thisInstance = RigidMeshAsset(instance)
    thisInstance:MakeWritable()
    local Bulkhead_01_Mesh = (50)
	thisInstance.cullScale = Bulkhead_01_Mesh
    --print('Culldistance for Bulkhead_01_Mesh set.')
end)

--PowerLine_01B_BrokenBase_Mesh
ResourceManager:RegisterInstanceLoadHandler(Guid('1E857D81-FFDF-1EBC-D6F2-082F304F5809'), Guid('AB778B7A-AE12-98BC-5733-90A64F29EFFF'), function(instance)
    
    local thisInstance = RigidMeshAsset(instance)
    thisInstance:MakeWritable()
    local PowerLine_01B_BrokenBase_Mesh_cull = (50)
	thisInstance.cullScale = PowerLine_01B_BrokenBase_Mesh_cull
	local PowerLine_01B_BrokenBase_Mesh_lod = (3)
	thisInstance.lodScale = PowerLine_01B_BrokenBase_Mesh_lod
	
    --print('Culldistance for PowerLine_01B_BrokenBase_Mesh set.')
end)