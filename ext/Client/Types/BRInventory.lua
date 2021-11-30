class "BRInventory"

function BRInventory:__init()
	self:ResetVars()
end

function BRInventory:ResetVars()
	self.m_Slots = {}
end

function BRInventory:GetSlot(p_SlotIndex)
	return self.m_Slots[p_SlotIndex]
end

-- =============================================
-- Events
-- =============================================

function BRInventory:OnReceiveInventoryState(p_State)
	if p_State == nil then
		return
	end

	for l_Index, l_Item in pairs(p_State) do
		self.m_Slots[l_Index] = (l_Item.Item ~= nil and BRItem:CreateFromTable(l_Item.Item)) or nil
	end

	self:SyncInventoryWithUI()
end

function BRInventory:AsTable()
	local s_Data = {}

	-- I return an array just to not break things in the UI
	for l_Index = 1, 20 do
		local s_Item = self.m_Slots[l_Index]
		s_Data[l_Index] = s_Item ~= nil and s_Item:AsTable(true) or {}
	end

	return s_Data
end

--==============================
-- UI related functions
--==============================

function BRInventory:SyncInventoryWithUI()
	WebUI:ExecuteJS(string.format("SyncInventory(%s);", json.encode(self:AsTable())))
end

function BRInventory:OnWebUIMoveItem(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local s_ItemId = s_DecodedData.item
	local s_SlotId = tonumber(s_DecodedData.slot) + 1

	if s_ItemId == nil or s_SlotId == nil then
		return
	end

	NetEvents:Send(InventoryNetEvent.MoveItem, s_ItemId, s_SlotId)
end

function BRInventory:OnWebUIDropItem(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local s_ItemId = s_DecodedData.item
	local s_Quantity = s_DecodedData.quantity

	if s_ItemId == nil or s_Quantity == nil then
		return
	end

	NetEvents:Send(InventoryNetEvent.DropItem, s_ItemId, s_Quantity)
end

function BRInventory:OnWebUIUseItem(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local s_ItemId = s_DecodedData.id

	if s_ItemId == nil then
		return
	end

	NetEvents:Send(InventoryNetEvent.UseItem, s_ItemId)
end

function BRInventory:OnWebUIPickupItem(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local s_LootPickupId = s_DecodedData.lootPickup
	local s_ItemId = s_DecodedData.item
	local s_SlotId = nil

	if s_DecodedData.slot ~= "" then
		s_SlotId = tonumber(s_DecodedData.slot) + 1
	end

	if s_LootPickupId == nil or s_ItemId == nil then
		return
	end

	NetEvents:Send(InventoryNetEvent.PickupItem, s_LootPickupId, s_ItemId, s_SlotId)
end

function BRInventory:OnItemActionCanceled()
	WebUI:ExecuteJS("ItemCancelAction();")
end

function BRInventory:Reset()
	for _, l_Item in pairs(self.m_Slots) do
		l_Item:Destroy()
	end

	self:ResetVars()
end
