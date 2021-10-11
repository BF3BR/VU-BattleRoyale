require "__shared/Items/BRItem"
require "__shared/Utils/Timers"

local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
local m_Logger = Logger("BRItemConsumable", true)

class("BRItemConsumable", BRItem)

function BRItemConsumable:__init(p_Id, p_Definition, p_Quantity)
    BRItem.__init(self, p_Id, p_Definition, p_Quantity)

    self.m_Timer = nil
    self.m_UpdateEvent = nil
end

function BRItemConsumable:CreateFromTable(p_Table)
    return BRItemConsumable(p_Table.Id, m_ConsumableDefinitions[p_Table.UId], p_Table.Quantity)
end

--==============================
-- Consumable related functions
--==============================

function BRItemConsumable:Use()
    -- check if already using this item
    if self.m_Timer ~= nil then
        return
    end

    -- start timer for the action
    self.m_Timer = g_Timers:Timeout(self.m_Definition.m_TimeToApply, self, self.OnComplete)

    -- start listening to update event
    self:SubscribeToEngineUpdates()

    -- inform player that the action started
    self:SendNetEvent(InventoryNetEvent.ItemActionStarted)
end

function BRItemConsumable:Cancel()
    -- check if item is not in use
    if self.m_Timer == nil then
        return
    end

    -- destroy timer
    self.m_Timer:Destroy()
    self.m_Timer = nil

    -- unsubscribe from update event
    -- self:UnsubscribeFromEngineUpdates() -- I think it causes a crash here...

    -- inform player that the action was canceled
    self:SendNetEvent(InventoryNetEvent.ItemActionCanceled)
end

function BRItemConsumable:OnComplete()
    -- check if item is not in use
    if self.m_Timer == nil then
        return
    end

    -- execute action and reduce item's quantity
    self:ApplyAction()
    self.m_Quantity = self.m_Quantity - 1

    -- inform player that the action was completed
    self:SendNetEvent(InventoryNetEvent.ItemActionCompleted)

    -- destroy item if needed
    if self.m_Quantity < 1 then
        Events:DispatchLocal("BRItem:DestroyItem", self.m_Id)
    end
end

function BRItemConsumable:ApplyAction()
    local s_Player = self:GetParentPlayer()
    if s_Player == nil or s_Player.soldier == nil then
        return
    end

    -- update player's health
    s_Player.soldier.health = math.min(100, s_Player.soldier.health + self.m_Definition.m_HealthToRegen)
end

function BRItemConsumable:SendNetEvent(p_Name)
    local s_Receivers = {}

    -- add owner as receiver
    local s_Player = self:GetParentPlayer()
    if s_Player ~= nil then
        table.insert(s_Receivers, s_Player)
    end

    -- TODO add spectators as receivers

    -- check for any receivers
    if #s_Receivers < 1 then
        return
    end

    -- send event to each receiver
    for _, l_Receiver in ipairs(s_Receivers) do
        NetEvents:SendToLocal(p_Name, l_Receiver, self.m_Id)
    end
end

function BRItemConsumable:OnEngineUpdate(p_DeltaTime, p_UpdatePass)
    if self.m_Timer == nil then
        self:UnsubscribeFromEngineUpdates()
        return
    end

    if p_UpdatePass ~= UpdatePass.UpdatePass_PreSim then
        return
    end

    local s_Player = self:GetParentPlayer()
    if s_Player == nil or s_Player.soldier == nil then
        return
    end

    local s_Soldier = s_Player.soldier

    -- cancel usage of consumable if:
    -- * player is firing
    -- * player starts sprinting
    -- * player is jumping
    if s_Soldier.isFiring or 
       s_Player.input:GetLevel(EntryInputActionEnum.EIASprint) > 0 or 
       s_Player.input:GetLevel(EntryInputActionEnum.EIAJump) > 0 then
        self:Cancel()
    end
end

function BRItemConsumable:SubscribeToEngineUpdates()
    self:UnsubscribeFromEngineUpdates()
    self.m_UpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnEngineUpdate)
end

function BRItemConsumable:UnsubscribeFromEngineUpdates()
    if self.m_UpdateEvent ~= nil then
        self.m_UpdateEvent:Unsubscribe()
        self.m_UpdateEvent = nil
    end
end

function BRItemHelmet:AsTable(p_Extended)
    local s_Table = BRItem.AsTable(self, p_Extended)

    if p_Extended then
        s_Table.TimeToApply = self.m_Definition.m_TimeToApply
    end

    return s_Table
end

function BRItemConsumable:Destroy()
    -- Destroy timer
    if self.m_Timer ~= nil then
        self.m_Timer:Destroy()
        self.m_Timer = nil
    end

    self:UnsubscribeFromEngineUpdates()
end
