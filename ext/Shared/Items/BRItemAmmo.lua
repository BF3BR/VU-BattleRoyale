require "__shared/Items/BRItem"

local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"

class("BRItemAmmo", BRItem)

function BRItemAmmo:__init(p_Id, p_Definition, p_Quantity)
    BRItem.__init(self, p_Id, p_Definition, p_Quantity)
end

function BRItemAmmo:CreateFromTable(p_Table)
    return BRItemAmmo(p_Table.Id, m_AmmoDefinitions[p_Table.UId], p_Table.Quantity)
end

--==============================
-- Ammo related functions
--==============================
