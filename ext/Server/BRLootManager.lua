---@class BRLootManager
BRLootManager = class "BRLootManager"

---@type Logger
local m_Logger = Logger("BRLootManager", false)

---@type BRLootRandomizer
local m_LootRandomizer = require "BRLootRandomizer"
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"

function BRLootManager:SpawnMapSpecificLootPickups()
	m_Logger:Write("Spawning map specific pickups.")

	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return
	end

	for _, l_Point in pairs(MapsConfig[s_LevelName].LootSpawnPoints) do
		m_LootRandomizer:Spawn(l_Point)
	end
end

function BRLootManager:RemoveAllLootPickups()
	m_LootPickupDatabase:RemoveAllLootPickups()
end

return BRLootManager()
