local m_InventoryManager = require "BRInventoryManager"
local m_BRAirdropManager = require "BRAirdropManager"

local m_ItemDatabase = require "Types/BRItemDatabase"
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"

local m_Logger = Logger("DebugCommands", true)

--============================================================
-- Custom debug commands
--============================================================

local function OnPlayerGiveCommand(p_Player, p_Args)
	if p_Player == nil then
		m_Logger:Error("Invalid player.")
		return
	end

	if #p_Args == 0 then
		m_Logger:Error("Invalid command.")
		return
	end

	local s_Definition = g_BRItemFactory:FindDefinitionByUId(p_Args[1])

	if s_Definition == nil then
		m_Logger:Error("Invalid item definition UId: " .. p_Args[1])
		return
	end

    local s_Inventory = m_InventoryManager:GetOrCreateInventory(p_Player)
    local s_CreatedItem = m_ItemDatabase:CreateItem(s_Definition, p_Args[2] ~= nil and tonumber(p_Args[2]) or 1)

	s_Inventory:AddItem(s_CreatedItem.m_Id)
	m_Logger:Write(s_Definition.m_Name .. " - Item given to player: " .. p_Player.name)
end

local function OnPlayerSpawnCommand(p_Player, p_Args)
	if p_Player == nil then
		m_Logger:Error("Invalid player.")
		return
	end

	if #p_Args == 0 then
		m_Logger:Error("Invalid command.")
		return
	end

	local s_Definition = g_BRItemFactory:FindDefinitionByUId(p_Args[1])

	if s_Definition == nil then
		m_Logger:Error("Invalid item definition UId: " .. p_Args[1])
		return
	end

	local s_CreatedItem = m_ItemDatabase:CreateItem(s_Definition, p_Args[2] ~= nil and tonumber(p_Args[2]) or 1)
	m_LootPickupDatabase:CreateBasicLootPickup(p_Player.soldier.worldTransform, {s_CreatedItem})

	m_Logger:Write(s_Definition.m_Name .. " - Item spawned for player: " .. p_Player.name)
end

local function OnSpawnAirdropCommand(p_Player)
    local s_LevelName = LevelNameHelper:GetLevelName()

    if s_LevelName == nil then
        return
    end

    if p_Player == nil then
        return
    end

    m_BRAirdropManager:CreatePlane(Vec3(
        p_Player.soldier.worldTransform.trans.x,
        MapsConfig[s_LevelName]["AirdropPlaneFlyHeight"],
        p_Player.soldier.worldTransform.trans.z
    ))
end

-- subscribe to commands
NetEvents:Subscribe(InventoryNetEvent.InventoryGiveCommand, OnPlayerGiveCommand)
NetEvents:Subscribe(InventoryNetEvent.InventorySpawnCommand, OnPlayerSpawnCommand)
NetEvents:Subscribe("SpawnAirdropCommand", OnSpawnAirdropCommand)
