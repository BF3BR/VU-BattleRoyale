require "__shared/Items/BRItem"

local m_GadgetDefinitions = require "__shared/Items/Definitions/BRItemGadgetDefinition"

class("BRItemGadget", BRItem)

function BRItemGadget:__init(p_Id, p_Definition, p_Quantity, p_CurrentPrimaryAmmo)
    BRItem.__init(self, p_Id, p_Definition, p_Quantity)

    self.m_CurrentPrimaryAmmo = p_CurrentPrimaryAmmo or 0
end

function BRItemGadget:SetPrimaryAmmo(p_AmmoCount)
    self.m_CurrentPrimaryAmmo = p_AmmoCount
end

-- Updates the quantity value for this item 
function BRItemGadget:SetQuantity(p_Quantity)
    -- fix for gadgets because m_Quantity contains both primary and secondary
    -- ammo, compared to other ammo items where m_Quantity is only the secondary ammo.
    -- After first reload (when self.m_CurrentPrimaryAmmo will be zero), quantity
    -- should stay the same.
    -- !!! :SetQuantity should be called before updating m_CurrentPrimaryAmmo
    if self.m_CurrentPrimaryAmmo == 0 then
        return
    end

    return BRItem.SetQuantity(self, p_Quantity)
end

function BRItemGadget:AsTable(p_Extended)
    local s_Table = BRItem.AsTable(self, p_Extended)

    s_Table.CurrentPrimaryAmmo = self.m_CurrentPrimaryAmmo

    return s_Table
end

function BRItemGadget:CreateFromTable(p_Table)
    return BRItemGadget(p_Table.Id, m_GadgetDefinitions[p_Table.UId], p_Table.Quantity, p_Table.CurrentPrimaryAmmo)
end

--==============================
-- Gadget related functions
--==============================
