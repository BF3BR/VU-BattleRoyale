class "LootManagerServer"

local m_Logger = Logger("LootManagerServer", true)

function LootManagerServer:__init()
	self.m_RandomSpawnTransforms = {}
end

-- =============================================
-- Events
-- =============================================

function LootManagerServer:OnLevelLoadResources()
	local s_WeightTable = {}
	local s_AccumulatedWeight = PickupsConfig.NoPickupWeight
	s_WeightTable[1] = s_AccumulatedWeight

	for l_Tier, l_TierConfig in ipairs(PickupsConfig.Tiers) do
		s_AccumulatedWeight = s_AccumulatedWeight + l_TierConfig.Weight
		s_WeightTable[l_Tier + 1] = s_AccumulatedWeight
	end

	self.m_RandomSpawnTransforms = {}

	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return
	end

	for i, l_Transform in pairs(MapsConfig[s_LevelName].LootSpawnPoints) do
		local s_Tier
		local s_Random = MathUtils:GetRandom(0, 1) * s_AccumulatedWeight

		for l_Tier, l_Weight in ipairs(s_WeightTable) do
			if s_Random <= l_Weight then
				s_Tier = l_Tier
				break
			end
		end

		-- Ignore the first tier (NO ITEM)
		if s_Tier ~= nil and s_Tier ~= 1 then
			table.insert(self.m_RandomSpawnTransforms, { tier = s_Tier - 1, transform = l_Transform})
		end
	end
	NetEvents:BroadcastLocal(LMS.RLT, self.m_RandomSpawnTransforms)
	Events:DispatchLocal(LMS.RLT, self.m_RandomSpawnTransforms)
end

function LootManagerServer:OnPlayerAuthenticated(p_Player)
	m_Logger:Write("Sending loot transforms")
	NetEvents:SendToLocal(LMS.RLT, p_Player, self.m_RandomSpawnTransforms)
end

-- =============================================
-- Functions
-- =============================================

function LootManagerServer:EnableMatchPickups()
	local s_Iterator = EntityManager:GetIterator("ServerPickupEntity")
	local s_Entity = s_Iterator:Next()

	while s_Entity do
		WeaponUnlockPickupEntityData(s_Entity.data).contentIsStatic = false
		s_Entity.bus.entities[2]:FireEvent("ShowMarker")
		s_Entity = s_Iterator:Next()
	end
end

function LootManagerServer:OnModReload()
	m_Logger:Write("Mod Reload - Refresh table")
	self.m_RandomSpawnTransforms = {}

	local s_Iterator = EntityManager:GetIterator("ServerPickupEntity")
	local s_Entity = s_Iterator:Next()

	while s_Entity do
		if s_Entity.data:Is("WeaponUnlockPickupEntityData") then
			local s_Transform = ReferenceObjectData(s_Entity.bus.parentRepresentative).blueprintTransform
			local s_HudIcon

			for _, l_Entity in pairs(s_Entity.bus.entities) do
				if l_Entity.data:Is("MapMarkerEntityData")then
					s_HudIcon = MapMarkerEntityData(l_Entity.data).hudIcon
					break
				end
			end

			if s_HudIcon ~= nil then
				local s_Tier = nil

				if s_HudIcon == UIHudIcon.UIHudIcon_WeaponPickupTier1 then
					s_Tier = 1
				elseif s_HudIcon == UIHudIcon.UIHudIcon_WeaponPickupTier2 then
					s_Tier = 2
				elseif s_HudIcon == UIHudIcon.UIHudIcon_WeaponPickupTier3 then
					s_Tier = 3
				end

				table.insert(self.m_RandomSpawnTransforms, { tier = s_Tier - 1, transform = s_Transform})
			end
		end

		s_Entity = s_Iterator:Next()
	end
end

if g_LootManagerServer == nil then
	g_LootManagerServer = LootManagerServer()
end

return g_LootManagerServer
