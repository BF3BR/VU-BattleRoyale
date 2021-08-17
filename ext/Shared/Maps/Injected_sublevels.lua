Events:Subscribe('Partition:Loaded', function(partition)
if SharedUtils:GetLevelName() ~= 'Levels/XP5_003/XP5_003' then
	return
	end

    if partition == nil or partition.name ~= 'levels/xp5_003/xp5_003' then
        return
    end


    -- Airturbines + some props	---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    --print('Injecting PropsLarge reference data...')
	print('PropsLarge spawned')
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


    print('Adding new registry containing relevant SubWorldReferenceData...')
    local newRegistry = RegistryContainer()
    newRegistry.referenceObjectRegistry:add(mpLevelForestReferenceData) -- Forest

    ResourceManager:AddRegistry(newRegistry, ResourceCompartment.ResourceCompartment_Game)

end)