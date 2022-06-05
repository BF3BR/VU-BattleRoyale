---@class BRInventory : TimersMixin
BRInventory = class("BRInventory", TimersMixin)

---@type Logger
local m_Logger = Logger("BRInventory", false)

---@type BRItemDatabase
local m_ItemDatabase = require "Types/BRItemDatabase"
---@type BRInventoryManager
local m_InventoryManager = require "BRInventoryManager"
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"

---@type ArrayHelper
local m_ArrayHelper = require "__shared/Utils/ArrayHelper"
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"


---@param p_Owner BRPlayer
function BRInventory:__init(p_Owner)
	TimersMixin.__init(self)

	-- the BRPlayer that owns this inventory
	self.m_Owner = p_Owner

	-- A table of slots
	---@type BRInventorySlot[]
	self.m_Slots = {
		-- PrimaryWeapon slots
		---@type BRInventoryWeaponSlot
		[InventorySlot.PrimaryWeapon] = BRInventoryWeaponSlot(self, WeaponSlot.WeaponSlot_0),
		---@type BRInventoryAttachmentSlot
		[InventorySlot.PrimaryWeaponAttachmentOptics] = BRInventoryAttachmentSlot(self, AttachmentType.Optics),
		[InventorySlot.PrimaryWeaponAttachmentBarrel] = BRInventoryAttachmentSlot(self, AttachmentType.Barrel),
		[InventorySlot.PrimaryWeaponAttachmentOther] = BRInventoryAttachmentSlot(self, AttachmentType.Other),
		-- SecondaryWeapon slots
		---@type BRInventoryWeaponSlot
		[InventorySlot.SecondaryWeapon] = BRInventoryWeaponSlot(self, WeaponSlot.WeaponSlot_1),
		---@type BRInventoryWeaponSlot
		[InventorySlot.SecondaryWeaponAttachmentOptics] = BRInventoryAttachmentSlot(self, AttachmentType.Optics),
		---@type BRInventoryWeaponSlot
		[InventorySlot.SecondaryWeaponAttachmentBarrel] = BRInventoryAttachmentSlot(self, AttachmentType.Barrel),
		---@type BRInventoryWeaponSlot
		[InventorySlot.SecondaryWeaponAttachmentOther] = BRInventoryAttachmentSlot(self, AttachmentType.Other),
		-- Gadget slots
		---@type BRInventoryArmorSlot
		[InventorySlot.Armor] = BRInventoryArmorSlot(self),
		---@type BRInventoryHelmetSlot
		[InventorySlot.Helmet] = BRInventoryHelmetSlot(self),
		---@type BRInventoryGadgetSlot
		[InventorySlot.Gadget] = BRInventoryGadgetSlot(self),
		-- Backpack slots
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack1] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack2] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack3] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack4] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack5] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack6] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack7] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack8] = BRInventoryBackpackSlot(self),
		---@type BRInventoryBackpackSlot
		[InventorySlot.Backpack9] = BRInventoryBackpackSlot(self),
	}

	self.m_Slots[InventorySlot.PrimaryWeaponAttachmentOptics]:SetWeaponSlot(self.m_Slots[InventorySlot.PrimaryWeapon])
	self.m_Slots[InventorySlot.PrimaryWeaponAttachmentBarrel]:SetWeaponSlot(self.m_Slots[InventorySlot.PrimaryWeapon])
	self.m_Slots[InventorySlot.PrimaryWeaponAttachmentOther]:SetWeaponSlot(self.m_Slots[InventorySlot.PrimaryWeapon])

	self.m_Slots[InventorySlot.PrimaryWeapon]:SetAttachmentSlots(
		self.m_Slots[InventorySlot.PrimaryWeaponAttachmentOptics],
		self.m_Slots[InventorySlot.PrimaryWeaponAttachmentBarrel],
		self.m_Slots[InventorySlot.PrimaryWeaponAttachmentOther]
	)

	self.m_Slots[InventorySlot.SecondaryWeaponAttachmentOptics]:SetWeaponSlot(self.m_Slots[InventorySlot.SecondaryWeapon])
	self.m_Slots[InventorySlot.SecondaryWeaponAttachmentBarrel]:SetWeaponSlot(self.m_Slots[InventorySlot.SecondaryWeapon])
	self.m_Slots[InventorySlot.SecondaryWeaponAttachmentOther]:SetWeaponSlot(self.m_Slots[InventorySlot.SecondaryWeapon])

	self.m_Slots[InventorySlot.SecondaryWeapon]:SetAttachmentSlots(
		self.m_Slots[InventorySlot.SecondaryWeaponAttachmentOptics],
		self.m_Slots[InventorySlot.SecondaryWeaponAttachmentBarrel],
		self.m_Slots[InventorySlot.SecondaryWeaponAttachmentOther]
	)
end

---Returns the player instance of the owner of this inventory
---@return Player|nil
function BRInventory:GetOwnerPlayer()
	return (self.m_Owner ~= nil and self.m_Owner:GetPlayer()) or nil
end

---Returns the soldier instance of the owner of this inventory
---@return SoldierEntity|nil
function BRInventory:GetOwnerSoldier()
	return (self.m_Owner ~= nil and self.m_Owner:GetSoldier()) or nil
end

---Returns a BRInventorySlot type
---@param p_SlotIndex InventorySlot|integer
---@return BRInventorySlot
function BRInventory:GetSlot(p_SlotIndex)
	return self.m_Slots[p_SlotIndex]
end

---Returns the slot of an item or nil if item was not found
---in this inventory
---@param p_ItemId string @It is a tostring(Guid)
---@return BRInventorySlot|nil
function BRInventory:GetItemSlot(p_ItemId)
	for l_Index, l_Slot in pairs(self.m_Slots) do
		if l_Slot.m_Item ~= nil and l_Slot.m_Item.m_Id == p_ItemId then
			return l_Slot
		end
	end

	return nil
end

---Returns the inventory slot of the currently equipped weapon
---@return BRInventoryWeaponSlot
function BRInventory:GetCurrentWeaponSlot()
	local s_Soldier = self:GetOwnerSoldier()
	if s_Soldier == nil then
		return nil
	end

	local s_WeaponSlot = s_Soldier.weaponsComponent.currentWeaponSlot

	if s_WeaponSlot == WeaponSlot.WeaponSlot_0 then
		return self.m_Slots[InventorySlot.PrimaryWeapon]
	elseif s_WeaponSlot == WeaponSlot.WeaponSlot_1 then
		return self.m_Slots[InventorySlot.SecondaryWeapon]
	end

	return nil
end

-- TODO p_CreateLootPickup wont be needed when we will be sure that each item
-- will have a link to it's owner. Then we will only need to check if it's owner is
-- a LootPickup or not

---@param p_ItemId string @it is a tostring(Guid)
---@param p_SlotIndex InventorySlot|integer
---@param p_CreateLootPickup boolean
---@return boolean
function BRInventory:AddItem(p_ItemId, p_SlotIndex, p_CreateLootPickup)
	-- Check if item exists
	local s_Item = m_ItemDatabase:GetItem(p_ItemId)
	if s_Item == nil then
		m_Logger:Write("Invalid item Id.")
		return false
	end

	-- check if the resolved slot from the drop slot, can accept this item
	local s_DropSlot = self:GetSlot(p_SlotIndex)
	local s_Slot = (s_DropSlot ~= nil and s_DropSlot:ResolveSlot(s_Item)) or nil

	local s_Soldier = self:GetOwnerSoldier()
	local s_CurrentWeaponSlot = self:GetCurrentWeaponSlot()

	-- get current weapon slot if item is weapon and both weapon slots are occupied
	if s_Slot == nil and s_Item:IsOfType(ItemType.Weapon) then
		-- check if slot is available for this item
		if s_CurrentWeaponSlot ~= nil and self:GetEquippedWeaponsNumber() == 2 then
			s_Slot = s_CurrentWeaponSlot
		end
	end

	-- replace helmet or armor if the item you try to pickup has higher tier
	if s_Slot == nil and (s_Item:IsOfType(ItemType.Armor) or s_Item:IsOfType(ItemType.Helmet)) then
		local s_ItemSlotIndex = (s_Item:IsOfType(ItemType.Armor) and InventorySlot.Armor) or InventorySlot.Helmet
		---@type BRInventoryArmorSlot|BRInventoryHelmetSlot
		local s_ItemSlot = self:GetSlot(s_ItemSlotIndex)

		-- compare tier levels
		if s_ItemSlot.m_Item ~= nil and s_ItemSlot.m_Item.m_Definition.m_Tier < s_Item.m_Definition.m_Tier then
			s_Slot = s_ItemSlot
		end
	end

	-- if none of the above cases worked, pick first free slot that can accept the item
	if s_Slot == nil then
		s_Slot = self:GetFirstAvailableSlot(s_Item)
	end

	-- check if no slot is found
	if s_Slot == nil then
		m_Logger:Write("No available slot in the inventory.")

		if p_CreateLootPickup and s_Soldier ~= nil then
			m_LootPickupDatabase:CreateBasicLootPickup(s_Soldier.worldTransform, { s_Item })
		end

		return false
	end

	-- If the item is stackable, first it should prioritize to fill the similar
	-- items that have some space left instead of beign put in some empty slot
	if s_Item.m_Definition.m_Stackable then
		-- Get similar stackable items
		local s_SimilarItems = self:GetItemsByDefinition(s_Item.m_Definition)

		-- Sort by quantity from low to high
		table.sort(s_SimilarItems, function(p_ItemA, p_ItemB)
			return p_ItemA.m_Quantity < p_ItemB.m_Quantity
		end)

		-- Fill all the similar stackable items from low to high
		-- and also create a new one if needed
		local s_QuantityLeftToAdd = s_Item.m_Quantity

		for _, l_SimilarItem in ipairs(s_SimilarItems) do
			-- Update similar item quantity
			local s_AvailableSpace = math.abs(l_SimilarItem.m_Definition.m_MaxStack - l_SimilarItem.m_Quantity)
			local s_QuantityToAdd = math.min(s_QuantityLeftToAdd, s_AvailableSpace)
			l_SimilarItem:IncreaseQuantityBy(s_QuantityToAdd)

			-- Update quantity left to add
			s_QuantityLeftToAdd = s_QuantityLeftToAdd - s_QuantityToAdd

			if s_QuantityLeftToAdd <= 0 then
				self:DestroyItem(s_Item.m_Id)
				self:SendState()
				return true
			end
		end

		-- If item has still quantity left to be added try to readd it
		-- in the inventory
		s_Item:SetQuantity(s_QuantityLeftToAdd)
		self:SendState()

		if s_Slot.m_Item ~= nil then
			return self:AddItem(s_Item.m_Id, nil, false)
		end
	end

	local _, s_DroppedItems = s_Slot:Put(s_Item)

	if #s_DroppedItems > 0 then
		-- if new item was a weapon, put back the compatible attachments
		if s_Slot.m_Type == SlotType.Weapon and #s_DroppedItems > 1 then
			-- needs to be cloned cause some of its contents may be deleted during iteration
			local s_DroppedItemsCloned = m_ArrayHelper:Clone(s_DroppedItems)

			for _, l_Item in ipairs(s_DroppedItemsCloned) do
				local s_AttachmentSlot = s_Slot:ResolveSlot(l_Item)
				if s_AttachmentSlot ~= nil and s_AttachmentSlot.m_Type == ItemType.Attachment then
					s_AttachmentSlot:Put(l_Item)
					m_ArrayHelper:RemoveByValue(s_DroppedItems, l_Item)
				end
			end
		end

		if s_Soldier ~= nil then
			m_LootPickupDatabase:CreateBasicLootPickup(s_Soldier.worldTransform, s_DroppedItems)
		end
	end

	m_Logger:WriteF("Item added to inventory. (%s)", s_Item.m_Definition.m_Name)
	self:SendState()
	return true
end

---@param p_ItemId string @It is a tostring(Guid)
---@param p_SlotId InventorySlot|integer
function BRInventory:SwapItems(p_ItemId, p_SlotId)
	local s_NewSlot = self.m_Slots[p_SlotId]
	local s_OldSlot = self:GetItemSlot(p_ItemId)

	-- check if item isn't in the inventory
	if s_OldSlot == nil then
		m_Logger:Write("Item not found in your inventory.")
		return
	end

	-- check if item can be put into the new slot
	s_NewSlot = s_NewSlot:ResolveSlot(s_OldSlot.m_Item)

	if s_NewSlot == nil then
		return
	end

	-- empty slots and keep dropped items
	local s_ReplacedItems = s_NewSlot:Drop()
	local s_NewItems = s_OldSlot:Drop()

	-- swap items
	s_NewSlot:PutWithRelated(s_NewItems)
	local _, s_RemainingItems = s_OldSlot:PutWithRelated(s_ReplacedItems)

	-- try to readd all the remaining items
	for _, l_Item in ipairs(s_RemainingItems) do
		self:AddItem(l_Item.m_Id, nil, true)
	end

	self:SendState()
end

---@param p_ItemId string @It is a tostring(Guid)
---@param p_Quantity integer|nil
function BRInventory:DropItem(p_ItemId, p_Quantity)
	local s_Soldier = self:GetOwnerSoldier()
	if s_Soldier == nil or s_Soldier.worldTransform == nil then
		return
	end

	p_Quantity = p_Quantity or 0

	local s_Slot = self:GetItemSlot(p_ItemId)

	if s_Slot ~= nil then
		local l_DroppedItems = s_Slot:Drop(p_Quantity)
		m_LootPickupDatabase:CreateBasicLootPickup(s_Soldier.worldTransform, l_DroppedItems)

		self:SendState()
	end
end

---@param p_ItemId string @It is a tostring(Guid)
function BRInventory:DestroyItem(p_ItemId)
	-- Check if item exists
	local s_Item = m_ItemDatabase:GetItem(p_ItemId)
	if s_Item == nil then
		m_Logger:Write("Invalid item Id.")
		return false
	end

	local s_Slot = self:GetItemSlot(p_ItemId)
	if s_Slot ~= nil then
		s_Slot:Clear()

		m_Logger:WriteF("Item removed from inventory. (%s)", s_Item.m_Definition.m_Name)

		m_ItemDatabase:UnregisterItem(p_ItemId)
		self:SendState()

		return true
	end

	m_Logger:Write("Item not found in any slot.")
	return false
end

---@param p_Item BRItem
----@return BRInventorySlot|nil
function BRInventory:GetFirstAvailableSlot(p_Item)
	if p_Item == nil then
		return nil
	end

	for _, l_Slot in pairs(self.m_Slots) do
		if l_Slot:IsAvailable(p_Item) then
			return l_Slot
		end
	end

	return nil
end

---@param p_Definition BRItemDefinition
---@return BRItem[]
function BRInventory:GetItemsByDefinition(p_Definition)
	local s_Items = {}

	for _, l_Slot in pairs(self.m_Slots) do
		if l_Slot:IsOfDefinition(p_Definition) then
			table.insert(s_Items, l_Slot.m_Item)
		end
	end

	return s_Items
end

---@return integer
function BRInventory:GetEquippedWeaponsNumber()
	local s_WeaponSlot1 = self:GetSlot(InventorySlot.PrimaryWeapon)
	local s_WeaponSlot2 = self:GetSlot(InventorySlot.SecondaryWeapon)

	return (s_WeaponSlot1.m_Item ~= nil and 1 or 0) + (s_WeaponSlot2.m_Item ~= nil and 1 or 0)
end

-- Returns the first weapon slot item with the specified weapon name
-- if it exists in the inventory
---@param p_WeaponName string @It is the ebx partition name
----@return BRInventorySlot|nil
function BRInventory:GetWeaponItemByName(p_WeaponName)
	for _, l_SlotIndex in pairs({ InventorySlot.PrimaryWeapon, InventorySlot.SecondaryWeapon, InventorySlot.Gadget }) do
		local s_Slot = self.m_Slots[l_SlotIndex]

		if s_Slot:HasWeapon(p_WeaponName) then
			return s_Slot.m_Item
		end
	end

	return nil
end

---@param p_WeaponSlot InventorySlot|integer
---@return BRItemWeapon|BRItemGadget|nil
function BRInventory:GetWeaponItemByWeaponSlot(p_WeaponSlot)
	if p_WeaponSlot == WeaponSlot.WeaponSlot_0 then
		return self:GetSlot(InventorySlot.PrimaryWeapon).m_Item
	elseif p_WeaponSlot == WeaponSlot.WeaponSlot_1 then
		return self:GetSlot(InventorySlot.SecondaryWeapon).m_Item
	elseif p_WeaponSlot == WeaponSlot.WeaponSlot_2 then
		return self:GetSlot(InventorySlot.Gadget).m_Item
	end

	return nil
end

---@param p_WeaponName string @It is the ebx partition name
---@return BRItemAmmoDefinition|nil
function BRInventory:GetAmmoDefinition(p_WeaponName)
	local s_Item = self:GetWeaponItemByName(p_WeaponName)
	return (s_Item ~= nil and s_Item.m_Definition.m_AmmoDefinition) or nil
end

---@param p_WeaponSlot InventorySlot|integer
---@return integer @current primary ammo
function BRInventory:GetSavedPrimaryAmmo(p_WeaponSlot)
	local s_Item = self:GetWeaponItemByWeaponSlot(p_WeaponSlot)
	return (s_Item ~= nil and s_Item.m_CurrentPrimaryAmmo) or 0
end

---@param p_WeaponSlot InventorySlot|integer
---@param p_AmmoCount integer
---@see not really returning anything
function BRInventory:SavePrimaryAmmo(p_WeaponSlot, p_AmmoCount)
	local s_Item = self:GetWeaponItemByWeaponSlot(p_WeaponSlot)
	return s_Item ~= nil and s_Item:SetPrimaryAmmo(p_AmmoCount)
end

---@param p_ForceFullUpdate boolean
---@return table
---@return table
function BRInventory:AsTable(p_ForceFullUpdate)
	local s_Data = {}
	local s_SpectatorData = {}

	-- Add only updated slots into the data that
	-- will be sent to the client
	for l_SlotIndex = 1, 20 do
		local s_Slot = self.m_Slots[l_SlotIndex]

		if p_ForceFullUpdate or s_Slot.m_IsUpdated then
			local s_SlotData = s_Slot:AsTable()
			s_Data[l_SlotIndex] = s_SlotData

			if s_Slot.m_SendToSpectator then
				s_SpectatorData[l_SlotIndex] = s_SlotData
			end

			if not p_ForceFullUpdate then
				s_Slot.m_IsUpdated = false
			end
		end
	end

	return s_Data, s_SpectatorData
end

-- Calls `SendState` with a delay.
-- Avoids multiple uneeded firings that may happen during some operations
function BRInventory:DeferSendState()
	if not self:ResetTimer("SendState") then
		self:SetTimer("SendState", m_TimerManager:Timeout(0.02, self, self.SendState))
	end
end

-- Sends the state of the inventory to its owner and the spectators
function BRInventory:SendState()
	self:RemoveTimer("SendState")

	if self.m_Owner == nil then
		return
	end

	local s_Data, s_SpectatorData = self:AsTable()

	-- send data to player if it's not empty
	if next(s_Data) ~= nil then
		NetEvents:SendToLocal(InventoryNetEvent.InventoryState, self:GetOwnerPlayer(), s_Data)
	end

	-- send data to player's spectators if it's not empty
	if next(s_SpectatorData) ~= nil then
		self.m_Owner:SendEventToSpectators(InventoryNetEvent.InventoryState, s_SpectatorData)
	end
end

function BRInventory:Clear()
	for _, l_Slot in pairs(self.m_Slots) do
		l_Slot:Clear()
	end
end

-- Destroys the `BRInventory` instance
function BRInventory:Destroy()
	self.m_Owner = nil
	self.m_Slots = {}
end

-- Garbage collector metamethod
function BRInventory:__gc()
	self:Destroy()
end

--==============================
-- Player / Soldier related functions
--==============================

---@param p_WeaponName string @It is the ebx partition name
---@return integer
function BRInventory:GetAmmoTypeCount(p_WeaponName)
	---@type BRInventoryGadgetSlot
	local s_GadgetSlot = self:GetSlot(InventorySlot.Gadget)

	if s_GadgetSlot.m_Item ~= nil and s_GadgetSlot:HasWeapon(p_WeaponName) then
		return s_GadgetSlot.m_Item.m_Quantity - s_GadgetSlot.m_Item.m_CurrentPrimaryAmmo
	end

	local s_AmmoDefinition = self:GetAmmoDefinition(p_WeaponName)
	if s_AmmoDefinition == nil then
		return 0
	end

	local s_Sum = 0

	for l_Key, l_Slot in pairs(self.m_Slots) do
		if l_Slot.m_Item ~= nil then
			if l_Key >= InventorySlot.Backpack1 and l_Slot.m_Item.m_Definition:Equals(s_AmmoDefinition) then
				s_Sum = s_Sum + l_Slot.m_Item.m_Quantity
			end
		end
	end

	return s_Sum
end

-- @return The number of ammo that was successfully removed
---@param p_WeaponName string @It is the ebx partition name
---@param p_Quantity integer
---@return integer
function BRInventory:RemoveAmmo(p_WeaponName, p_Quantity)
	-- Handle all the Gadget related code here
	local s_GadgetSlot = self.m_Slots[InventorySlot.Gadget]
	local s_GadgetItem = s_GadgetSlot.m_Item

	if s_GadgetItem ~= nil and s_GadgetSlot:HasWeapon(p_WeaponName) then
		s_GadgetItem:SetQuantity(s_GadgetItem.m_Quantity - 1)
		s_GadgetSlot.m_IsUpdated = true

		if s_GadgetItem.m_Quantity == 0 then
			self:DestroyItem(s_GadgetItem.m_Id)
		else
			self:SendState()
		end

		return s_GadgetItem.m_Quantity - 1
	end

	-- Get ammo definition for this weapon
	local s_AmmoDefinition = self:GetAmmoDefinition(p_WeaponName)

	if s_AmmoDefinition == nil then
		return 0
	end

	-- Get similar ammo items
	local s_AmmoItems = self:GetItemsByDefinition(s_AmmoDefinition)

	-- Sort by quantity from low to high
	table.sort(s_AmmoItems, function(p_AmmoItemA, p_AmmoItemB)
		return p_AmmoItemA.m_Quantity < p_AmmoItemB.m_Quantity
	end)

	local s_QuantityLeftToRemove = p_Quantity

	for _, l_AmmoItem in ipairs(s_AmmoItems) do
		local s_QuantityRemoved = math.min(l_AmmoItem.m_Quantity, s_QuantityLeftToRemove)

		-- Update ammo item state
		l_AmmoItem:SetQuantity(l_AmmoItem.m_Quantity - s_QuantityRemoved)
		if l_AmmoItem.m_Quantity <= 0 then
			self:DestroyItem(l_AmmoItem.m_Id)
		end

		-- Update quantity left to remove
		s_QuantityLeftToRemove = s_QuantityLeftToRemove - s_QuantityRemoved
		if s_QuantityLeftToRemove <= 0 then
			self:SendState()
			return p_Quantity
		end
	end

	self:SendState()
	return p_Quantity - s_QuantityLeftToRemove
end

-- Calls `UpdateSoldierCustomization` with a delay.
-- Avoids multiple uneeded firings that may happen during some operations
---@param p_Timeout number|nil
function BRInventory:DeferUpdateSoldierCustomization(p_Timeout)
	if not self:ResetTimer("UpdateCustomization") then
		self:SetTimer("UpdateCustomization", m_TimerManager:Timeout(p_Timeout or 0.12, self, self.UpdateSoldierCustomization))
	end
end

function BRInventory:UpdateSoldierCustomization()
	self:RemoveTimer("UpdateCustomization")

	local s_Soldier = self:GetOwnerSoldier()
	if s_Soldier == nil then
		return
	end

	-- This one is called because a change in some slots causes a
	-- complete change in customization so it may have some side-effects
	-- to unrelated slots
	for _, l_Slot in pairs(self.m_Slots) do
		l_Slot:BeforeCustomizationApply()
	end

	s_Soldier:ApplyCustomization(self:CreateCustomizeSoldierData())

	-- Reset primary ammo for each weapon
	for l_WeaponSlot, l_Weapon in pairs(s_Soldier.weaponsComponent.weapons) do
		if l_Weapon ~= nil then
			l_Weapon.primaryAmmo = self:GetSavedPrimaryAmmo(l_WeaponSlot - 1)
			l_Weapon.secondaryAmmo = self:GetAmmoTypeCount(l_Weapon.name)
		end
	end
end

function BRInventory:UpdateWeaponSecondaryAmmo()
	local s_Soldier = self:GetOwnerSoldier()
	if s_Soldier == nil then
		return
	end

	for _, l_Weapon in pairs(s_Soldier.weaponsComponent.weapons) do
		if l_Weapon ~= nil then
			l_Weapon.secondaryAmmo = self:GetAmmoTypeCount(l_Weapon.name)
		end
	end
end

function BRInventory:CreateCustomizeSoldierData()
	local s_CustomizeSoldierData = CustomizeSoldierData()
	s_CustomizeSoldierData.restoreToOriginalVisualState = false
	s_CustomizeSoldierData.clearVisualState = true
	s_CustomizeSoldierData.overrideMaxHealth = -1.0
	s_CustomizeSoldierData.overrideCriticalHealthThreshold = -1.0

	-- Update weapon and gadget slots
	local s_SlotIndexes = { InventorySlot.PrimaryWeapon, InventorySlot.SecondaryWeapon, InventorySlot.Gadget }

	for _, l_SlotIndex in pairs(s_SlotIndexes) do
		local s_UnlockWeaponAndSlot = self.m_Slots[l_SlotIndex]:GetUnlockWeaponAndSlot()

		if s_UnlockWeaponAndSlot ~= nil then
			s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot)
		end
	end

	local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
	s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(
		ResourceManager:FindInstanceByGuid(Guid("0003DE1B-F3BA-11DF-9818-9F37AB836AC2"), Guid("8963F500-E71D-41FC-4B24-AE17D18D8C73"))
	)
	s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_7
	s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot)

	--[[local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
	s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(
		ResourceManager:FindInstanceByGuid(Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B"))
	)
	s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_9
	s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot)]]

	local s_Soldier = self:GetOwnerSoldier()
	if s_Soldier ~= nil then
		local s_CurrWeaponSlot = s_Soldier.weaponsComponent.currentWeaponSlot
		if s_CurrWeaponSlot then
			s_CustomizeSoldierData.activeSlot = s_CurrWeaponSlot
		else
			s_CustomizeSoldierData.activeSlot = WeaponSlot.WeaponSlot_7
		end
	end

	s_CustomizeSoldierData.removeAllExistingWeapons = true
	s_CustomizeSoldierData.disableDeathPickup = false

	return s_CustomizeSoldierData
end

function BRInventory:Destroy()
	self:RemoveTimers()
end
