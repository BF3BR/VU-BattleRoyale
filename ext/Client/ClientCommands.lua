local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"
local m_GadgetDefinition = require "__shared/Items/Definitions/BRItemGadgetDefinition"

ClientCommands = 
{
    errInvalidCommand = "Invalid command",

    Give = function(p_Args)
        -- If we have any arguments, ignore them
        if #p_Args == 0 then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local player
        local s_LocalPlayer = PlayerManager:GetLocalPlayer()
        if s_LocalPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Check to see if the player is alive
        if s_LocalPlayer.alive == false then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local soldier instance
        local s_LocalSoldier = s_LocalPlayer.soldier
        if s_LocalSoldier == nil then
            return ClientCommands.errInvalidCommand
        end

        NetEvents:Send(InventoryNetEvent.InventoryGiveCommand, p_Args)

        return "Item given."        
    end,

    Spawn = function(p_Args)
        -- If we have any arguments, ignore them
        if #p_Args == 0 then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local player
        local s_LocalPlayer = PlayerManager:GetLocalPlayer()
        if s_LocalPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Check to see if the player is alive
        if s_LocalPlayer.alive == false then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local soldier instance
        local s_LocalSoldier = s_LocalPlayer.soldier
        if s_LocalSoldier == nil then
            return ClientCommands.errInvalidCommand
        end

        NetEvents:Send(InventoryNetEvent.InventorySpawnCommand, p_Args)

        return "Item spawned."        
    end,

    SpawnAirdrop = function(p_Args)
        -- Get the local player
        local s_LocalPlayer = PlayerManager:GetLocalPlayer()
        if s_LocalPlayer == nil then
            return ClientCommands.errInvalidCommand
        end

        -- Check to see if the player is alive
        if s_LocalPlayer.alive == false then
            return ClientCommands.errInvalidCommand
        end

        -- Get the local soldier instance
        local s_LocalSoldier = s_LocalPlayer.soldier
        if s_LocalSoldier == nil then
            return ClientCommands.errInvalidCommand
        end

        NetEvents:Send("SpawnAirdropCommand")

        return "Airdrop spawned."        
    end,

    List = function(p_Args)
        local s_Result = "";
        
        for l_Key, l_Definition in pairs(m_AmmoDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_ArmorDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_AttachmentDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_ConsumableDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_HelmetDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_WeaponDefinitions) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        for l_Key, l_Definition in pairs(m_GadgetDefinition) do
            s_Result = s_Result .. l_Key .. "\n"
        end

        return s_Result        
    end,

    SpawnKiasarLoot = function (p_Args)
        NetEvents:Send("SpawnKiasarLoot")
    end
}
