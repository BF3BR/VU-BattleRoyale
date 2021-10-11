class "BRInventorySlot"

local m_Logger = Logger("BRInventorySlot", true)

function BRInventorySlot:__init(p_Inventory, p_AcceptedTypes)
    self.m_Item = nil
    self.m_Inventory = p_Inventory
    self.m_AcceptedTypes = p_AcceptedTypes or {}
    self.m_IsUpdated = true
end

-- Checks if the slot contains an item with the specified definition
function BRInventorySlot:IsOfDefinition(p_Definition)
    if self.m_Item ~= nil and self.m_Item.m_Definition:Equals(p_Definition) then
        return true
    end

    return false
end

-- Puts an item into the slot
function BRInventorySlot:Put(p_Item)
    -- TODO more checks + swap logic + more...
    if p_Item ~= nil then
        -- check if invalid item for this slot
        if not self:IsAccepted(p_Item) then
            return false, {p_Item}
        end

        -- check if the item is already equipped
        if p_Item:Equals(self.m_Item) then
            return true, {}
        end

        -- update item's owner
        p_Item.m_Owner = self
    end

    -- drop old stuff
    local s_DroppedItems = self:Drop()

    -- set new item
    self.m_Item = p_Item
    self.m_IsUpdated = true

    -- trigger the update event
    self:OnUpdate()

    return true, s_DroppedItems
end

function BRInventorySlot:Drop(p_Quantity)
    -- Override (if needed)
    if self.m_Item == nil then
        return {}
    end

    -- TODO add quantity support
    p_Quantity = p_Quantity or 0

    local s_DroppedItems = self:OnBeforeDrop()

    -- remove item from the slot
    local s_Item = self.m_Item
    s_Item.m_Owner = nil
    table.insert(s_DroppedItems, 1, s_Item)

    -- update slot state
    self.m_Item = nil
    self.m_IsUpdated = true

    self:OnUpdate()

    return s_DroppedItems
end

function BRInventorySlot:PutWithRelated(p_Items)
    -- default behavior is to :Put only the first item
    if p_Items ~= nil and #p_Items > 0 then
        return self:Put(p_Items[1])
    else
        return self:Clear()
    end
end

function BRInventorySlot:Clear()
    return self:Put(nil)
end

function BRInventorySlot:IsAccepted(p_Item)
    if p_Item == nil then
        return false
    end

    for _, l_Type in ipairs(self.m_AcceptedTypes) do
        if p_Item.m_Definition.m_Type == l_Type then
            return true
        end
    end

    return false
end

function BRInventorySlot:IsAvailable(p_Item)
    -- Check if type is not accepted
    if not self:IsAccepted(p_Item) then
        return false
    end

    -- Check if empty
    if self.m_Item == nil then
        return true
    end

    -- Check if item is stackable and slot contains same item type and has space
    if p_Item.m_Definition.m_Stackable and
        p_Item.m_Definition.m_MaxStack ~= nil and
        self.m_Item.m_Definition:Equals(p_Item.m_Definition) and
        self.m_Item.m_Quantity < p_Item.m_Definition.m_MaxStack then
        return true
    end

    return false
end

function BRInventorySlot:ResolveSlot(p_Item)
    if not self:IsAccepted(p_Item) then
        return nil
    end

    return self
end

function BRInventorySlot:GetOwner()
    return self.m_Inventory.m_Owner
end

function BRInventorySlot:AsTable()
    return {Item = self.m_Item ~= nil and self.m_Item:AsTable() or nil}
end

-- @Override
-- It's called before the item is about to be dropped. It can be used
-- to trigger related ammo drops. Returns the related items that were dropped
function BRInventorySlot:OnBeforeDrop()
    return {}
end

-- @Override
function BRInventorySlot:OnUpdate()
    -- Empty
end

-- @Override
-- It's called before soldier customization starts happening, even
-- if that was triggered from unrelated slot. It's used to suppress
-- some side-effects caused by unrelated (to this slot) slot changes
function BRInventorySlot:BeforeCustomizationApply()
    -- Empty
end

