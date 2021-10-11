class "BRLootManager"

require "__shared/Enums/ItemEnums"
require "__shared/Utils/LevelNameHelper"

local m_Logger = Logger("BRLootManager", true)

local m_LootRandomizer = require "BRLootRandomizer"

function BRLootManager:SpawnMapSpecificLootPickups()
    local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return
	end

	for _, l_Point in pairs(MapsConfig[s_LevelName].LootSpawnPoints) do
		m_LootRandomizer:Spawn(l_Point)
	end
end

function BRLootManager:Clear()
	--[[for _, l_Pickup in pairs(self.m_LootPickups) do
		m_LootRandomizer:Spawn(l_Point)
	end]]
end

-- define global
if g_BRLootManager == nil then
    g_BRLootManager = BRLootManager()
end

return g_BRLootManager
