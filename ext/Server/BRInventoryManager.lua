---@class BRInventoryManager
BRInventoryManager = class "BRInventoryManager"

local m_Logger = Logger("BRInventoryManager", true)

local m_ItemDatabase = require "Types/BRItemDatabase"
---@type BRLootPickupDatabaseServer
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type BRTeamManagerServer
local m_BRTeamManagerServer = require "BRTeamManagerServer"

---@type BRItemAmmoDefinition
local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"
---@type BRItemArmorDefinition
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
---@type BRItemAttachmentDefinition
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
---@type BRItemConsumableDefinition
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
---@type BRItemHelmetDefinition
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
---@type BRItemWeaponDefinition
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

function BRInventoryManager:__init()
	self:RegisterVars()
end

function BRInventoryManager:RegisterVars()
	-- [Player.id] -> [BRInventory]
	self.m_Inventories = {}
end

function BRInventoryManager:OnPlayerLeft(p_Player)
	m_Logger:Write(string.format("Destroying Inventory for '%s'", p_Player.name))

	if self.m_Inventories[p_Player.id] ~= nil then
		self:RemoveInventory(p_Player)
	end
end

function BRInventoryManager:OnPlayerChangingWeapon(p_Player)
	if p_Player == nil or p_Player.soldier == nil then
		return
	end

	local s_CurrentWeapon = p_Player.soldier.weaponsComponent.currentWeapon
	local s_Inventory = self:GetOrCreateInventory(p_Player)

	if s_CurrentWeapon == nil or s_Inventory == nil then
		return
	end

	-- destroy gadget if empty
	s_Inventory:GetSlot(InventorySlot.Gadget):DestroyIfEmpty()

	-- Update secondary ammo count
	s_CurrentWeapon.secondaryAmmo = s_Inventory:GetAmmoTypeCount(s_CurrentWeapon.name)
end

function BRInventoryManager:GetOrCreateInventory(p_Player)
	-- get existing inventory
	local s_Inventory = self.m_Inventories[p_Player.id]

	-- get BRPlayer for this player
	local s_BRPlayer = m_BRTeamManagerServer:GetPlayer(p_Player)

	-- create a new one if needed
	if s_Inventory == nil then
		s_Inventory = BRInventory(s_BRPlayer)
		self:AddInventory(s_Inventory, p_Player)
	end

	return s_Inventory
end

-- Adds a BRInventory
-- @param p_Inventory BRInventory
-- @param p_Player Player
function BRInventoryManager:AddInventory(p_Inventory, p_Player)
	self.m_Inventories[p_Player.id] = p_Inventory

	-- set inventory reference in BRPlayer
	local s_BRPlayer = m_BRTeamManagerServer:GetPlayer(p_Player)
	if s_BRPlayer ~= nil then
		m_Logger:Write("Set inventory for BRPlayer " .. s_BRPlayer:GetName())
		s_BRPlayer.m_Inventory = p_Inventory
	end
end

-- Removes a BRInventory
-- @param p_Player Player
function BRInventoryManager:RemoveInventory(p_Player)
	if self.m_Inventories[p_Player.id] == nil then
		return
	end

	-- destroy inventory and clear reference
	self.m_Inventories[p_Player.id]:Destroy()
	self.m_Inventories[p_Player.id] = nil

	-- clear inventory reference in BRPlayer
	local s_BRPlayer = m_BRTeamManagerServer:GetPlayer(p_Player)
	if s_BRPlayer ~= nil then
		s_BRPlayer.m_Inventory = nil
	end
end

--============================================================
-- Player <-> Inventory interaction functions
--============================================================

-- Responds to the request of a player to pickup an item from a specified lootpickup
function BRInventoryManager:OnInventoryPickupItem(p_Player, p_LootPickupId, p_ItemId, p_SlotIndex)
	-- check if player is alive
	if p_Player == nil or p_Player.soldier == nil or not p_Player.soldier.isAlive then
		return
	end

	-- get inventory
	local s_Inventory = self:GetOrCreateInventory(p_Player)
	if s_Inventory == nil then
		return
	end

	-- get lootpickup
	local s_LootPickup = m_LootPickupDatabase:GetById(p_LootPickupId)
	if s_LootPickup == nil or not s_LootPickup:ContainsItemId(p_ItemId) then
		return
	end

	-- check that player and lootpickup are close
	local s_LootPickupPos = s_LootPickup.m_Transform.trans
	local s_PlayerPos = p_Player.soldier.transform.trans

	if s_LootPickupPos:Distance(s_PlayerPos) > InventoryConfig.CloseItemAllowedRadiusServer then
		return
	end

	-- add item to player and remove it from lootpickup
	if s_LootPickup:ContainsItemId(p_ItemId) then
		if s_Inventory:AddItem(p_ItemId, p_SlotIndex) then
			m_LootPickupDatabase:RemoveItemFromLootPickup(p_LootPickupId, p_ItemId)
		else
			m_LootPickupDatabase:UpdateState(p_LootPickupId)
		end
	end
end

-- Responds to the request of a player to move an item between slots of his inventory
function BRInventoryManager:OnInventoryMoveItem(p_Player, p_ItemId, p_SlotId)
	-- check if player is alive
	if p_Player == nil or p_Player.soldier == nil or not p_Player.soldier.isAlive then
		return
	end

	-- get inventory
	local s_Inventory = self:GetOrCreateInventory(p_Player)
	if s_Inventory == nil then
		return
	end

	s_Inventory:SwapItems(p_ItemId, p_SlotId)
end

-- Responds to the request of a player to drop an item from his inventory
function BRInventoryManager:OnInventoryDropItem(p_Player, p_ItemId, p_Quantity)
	-- check if player is alive
	if p_Player == nil or p_Player.soldier == nil or not p_Player.soldier.isAlive then
		return
	end

	-- get inventory
	local s_Inventory = self:GetOrCreateInventory(p_Player)
	if s_Inventory == nil then
		return
	end

	s_Inventory:DropItem(p_ItemId, p_Quantity)
end

-- Responds to the request of a player to use an item from his inventory
function BRInventoryManager:OnInventoryUseItem(p_Player, p_ItemId)
	local s_Item = m_ItemDatabase:GetItem(p_ItemId)

	-- TODO validate that player is owner of this item

	if s_Item ~= nil then
		s_Item:Use()
	end
end

function BRInventoryManager:OnPlayerPostReload(p_Player, p_AmmoAdded, p_Weapon)
	if p_Player == nil or p_Player.soldier == nil then
		return
	end

	local s_Inventory = self.m_Inventories[p_Player.id]
	local p_Weapon = p_Weapon or p_Player.soldier.weaponsComponent.currentWeapon

	if s_Inventory == nil or p_Weapon == nil then
		return
	end

	-- remove ammo that was added
	s_Inventory:RemoveAmmo(p_Weapon.name, p_AmmoAdded)

	-- Update ammo values
	s_Inventory:SavePrimaryAmmo(p_Player.soldier.weaponsComponent.currentWeaponSlot, p_Weapon.primaryAmmo)
	p_Weapon.secondaryAmmo = s_Inventory:GetAmmoTypeCount(p_Weapon.name)
end

-- ugly solution for now
-- BRItemDatabase should know where each item resides and
-- destroy it and remove any references when needed
function BRInventoryManager:DestroyItem(p_ItemId)
	-- search for the item
	for _, l_Inventory in pairs(self.m_Inventories) do
		local s_Slot = l_Inventory:GetItemSlot(p_ItemId)

		-- clear slot and send the updated inventory state
		if s_Slot ~= nil then
			s_Slot:Clear()
			l_Inventory:SendState()
			break
		end
	end

	-- remove item from database
	m_ItemDatabase:UnregisterItem(p_ItemId)
end

function BRInventoryManager:OnItemDestroy(p_ItemId)
	return self:DestroyItem(p_ItemId)
end

function BRInventoryManager:Clear()
	for _, l_Inventory in pairs(self.m_Inventories) do
		l_Inventory:Clear()
		l_Inventory:SendState()
	end
end

return BRInventoryManager()
