local m_InventoryManager = require "BRInventoryManager"
local m_BRAirdropManager = require "BRAirdropManager"

local m_ItemDatabase = require "Types/BRItemDatabase"
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"

local m_Logger = Logger("DebugCommands", true)

--============================================================
-- Custom debug commands
--============================================================

function OnPlayerGiveCommand(p_Player, p_Args)
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

    local s_Inventory = m_InventoryManager.m_Inventories[p_Player.id]
    local s_CreatedItem = m_ItemDatabase:CreateItem(s_Definition, p_Args[2] ~= nil and tonumber(p_Args[2]) or 1)

    s_Inventory:AddItem(s_CreatedItem.m_Id)
    m_Logger:Write(s_Definition.m_Name .. " - Item given to player: " .. p_Player.name)
end

function OnPlayerSpawnCommand(p_Player, p_Args)
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

function OnSpawnAirdropCommand(p_Player)
    if p_Player == nil then
        return
    end
    
    m_BRAirdropManager:CreateAirdrop(LinearTransform(
        Vec3(1, 0, 0),
        Vec3(0, 1, 0),
        Vec3(0, 0, 1),
        Vec3(
            p_Player.soldier.worldTransform.trans.x,
            p_Player.soldier.worldTransform.trans.y + 50,
            p_Player.soldier.worldTransform.trans.z
        )
    ))
end

-- subscribe to commands
NetEvents:Subscribe(InventoryNetEvent.InventoryGiveCommand, OnPlayerGiveCommand)
NetEvents:Subscribe(InventoryNetEvent.InventorySpawnCommand, OnPlayerSpawnCommand)
NetEvents:Subscribe("SpawnAirdropCommand", OnSpawnAirdropCommand)
