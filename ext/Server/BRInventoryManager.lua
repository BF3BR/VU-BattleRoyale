---@class BRInventoryManager
BRInventoryManager = class "BRInventoryManager"

---@type Logger
local m_Logger = Logger("BRInventoryManager", false)

---@type BRItemDatabase
local m_ItemDatabase = require "Types/BRItemDatabase"
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type BRTeamManagerServer
local m_BRTeamManagerServer = require "BRTeamManagerServer"

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

function BRInventoryManager:__init()
	self:RegisterVars()
end

function BRInventoryManager:RegisterVars()
	---@type table<integer, BRInventory>
	---`[Player.id] -> [BRInventory]`
	self.m_Inventories = {}
end

---VEXT Server Player:Left Event
---@param p_Player Player
function BRInventoryManager:OnPlayerLeft(p_Player)
	m_Logger:Write(string.format("Destroying Inventory for '%s'", p_Player.name))

	if self.m_Inventories[p_Player.id] ~= nil then
		self:RemoveInventory(p_Player)
	end
end

---VEXT Server Player:ChangingWeapon Event
---@param p_Player Player
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
	---@diagnostic disable-next-line @it is a BRInventoryGadgetSlot
	s_Inventory:GetSlot(InventorySlot.Gadget):DestroyIfEmpty()

	-- Update secondary ammo count
	s_CurrentWeapon.secondaryAmmo = s_Inventory:GetAmmoTypeCount(s_CurrentWeapon.name)
end

---@param p_Player Player
---@return BRInventory
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

---Adds a BRInventory
---@param p_Inventory BRInventory
---@param p_Player Player
function BRInventoryManager:AddInventory(p_Inventory, p_Player)
	self.m_Inventories[p_Player.id] = p_Inventory

	-- set inventory reference in BRPlayer
	local s_BRPlayer = m_BRTeamManagerServer:GetPlayer(p_Player)
	if s_BRPlayer ~= nil then
		m_Logger:Write("Set inventory for BRPlayer " .. s_BRPlayer:GetName())
		s_BRPlayer.m_Inventory = p_Inventory
	end
end

---Removes a BRInventory
---@param p_Player Player
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

---Responds to the request of a player to pickup an item from a specified lootpickup
---@param p_Player Player
---@param p_LootPickupId string @it is a tostring(Guid)
---@param p_ItemId string @it is a tostring(Guid)
---@param p_SlotIndex InventorySlot|integer
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
---@param p_Player Player
---@param p_ItemId string @it is a tostring(Guid)
---@param p_SlotId InventorySlot|integer
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
---@param p_Player Player
---@param p_ItemId string @it is a tostring(Guid)
---@param p_Quantity integer|nil
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
---@param p_Player Player
---@param p_ItemId string @it is a tostring(Guid)
function BRInventoryManager:OnInventoryUseItem(p_Player, p_ItemId)
	---@type BRItemConsumable
	local s_Item = m_ItemDatabase:GetItem(p_ItemId)

	-- TODO validate that player is owner of this item

	if s_Item ~= nil then
		s_Item:Use()
	end
end

---@param p_Player Player|nil
---@param p_AmmoAdded integer
---@param p_Weapon SoldierWeapon|nil
function BRInventoryManager:OnPlayerPostReload(p_Player, p_AmmoAdded, p_Weapon)
	if p_Player == nil or p_Player.soldier == nil then
		return
	end

	local s_Inventory = self.m_Inventories[p_Player.id]
	p_Weapon = p_Weapon or p_Player.soldier.weaponsComponent.currentWeapon

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
---@param p_ItemId string @it is a tostring(Guid)
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

---@param p_ItemId string @it is a tostring(Guid)
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
