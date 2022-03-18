---@module "Items/Definitions/BRItemAmmoDefinition"
---@type table<string, BRItemAmmoDefinition>
local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"
---@module "Items/Definitions/BRItemArmorDefinition"
---@type table<string, BRItemArmorDefinition>
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
---@module "Items/Definitions/BRItemAttachmentDefinition"
---@type table<string, BRItemAttachmentDefinition>
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
---@module "Items/Definitions/BRItemConsumableDefinition"
---@type table<string, BRItemConsumableDefinition>
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
---@module "Items/Definitions/BRItemHelmetDefinition"
---@type table<string, BRItemHelmetDefinition>
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
---@module "Items/Definitions/BRItemWeaponDefinition"
---@type table<string, BRItemWeaponDefinition>
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"
---@module "Items/Definitions/BRItemGadgetDefinition"
---@type table<string, BRItemGadgetDefinition>
local m_GadgetDefinition = require "__shared/Items/Definitions/BRItemGadgetDefinition"

---@class ClientCommands
ClientCommands = {
	errInvalidCommand = "Invalid command",

	---Give Command
	---@param p_Args string[]
	---@return string
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

	---Spawn Command
	---@param p_Args string[]
	---@return string
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

	---SpawnAirdrop Command
	---@param p_Args string[]
	---@return string
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

	---List Command
	---@param p_Args string[]
	---@return string
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
}
