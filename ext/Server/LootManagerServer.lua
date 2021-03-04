class "LootManagerServer"

function LootManagerServer:__init()
    self.m_RandomSpawnTransforms = {}
end

function LootManagerServer:OnLevelLoadResources(p_WorldPartData, p_Registry)
    local s_WeightTable = {}
    local s_AccumulatedWeight = PickupsConfig.NoPickupWeight
    for l_Tier, l_TierConfig in pairs(PickupsConfig.Tiers) do
        s_AccumulatedWeight = s_AccumulatedWeight + l_TierConfig.Weight
        s_WeightTable[s_AccumulatedWeight] = l_Tier
    end

    self.m_RandomSpawnTransforms = {}

    for i, l_Transform in pairs(MapsConfig.XP5_003.LootSpawnPoints) do
        local s_Tier
        local s_Random = MathUtils:GetRandom(0, 1) * s_AccumulatedWeight

        for l_Weight, l_Tier in pairs(s_WeightTable) do
            if s_Random >= l_Weight then
                s_Tier = l_Tier
            end
        end

        if s_Tier ~= nil then
            table.insert(self.m_RandomSpawnTransforms, { tier = s_Tier, transform = l_Transform})
        end
    end

    NetEvents:BroadcastLocal('LMS:RLT', self.m_RandomSpawnTransforms)
    Events:DispatchLocal('LMS:RLT', self.m_RandomSpawnTransforms)
end

function LootManagerServer:OnPlayerAuthenticated(p_Player)
    print("[LootManagerServer] Sending loot transforms")
    NetEvents:SendToLocal('LMS:RLT', p_Player, self.m_RandomSpawnTransforms)
end

function LootManagerServer:EnableMatchPickups()
    local s_Iterator = EntityManager:GetIterator("ServerPickupEntity")
	local s_Entity = s_Iterator:Next()
	while s_Iterator do
		WeaponUnlockPickupEntityData(s_Entity.data).contentIsStatic = false
		s_Entity.bus.entities[2]:FireEvent('ShowMarker')
		s_Entity = s_Iterator:Next()
	end
end

if g_LootManagerServer == nil then
	g_LootManagerServer = LootManagerServer()
end

return g_LootManagerServer