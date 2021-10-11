require "__shared/Items/BRItem"

local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

class("BRItemWeapon", BRItem)

function BRItemWeapon:__init(p_Id, p_Definition, p_CurrentPrimaryAmmo)
    BRItem.__init(self, p_Id, p_Definition, 1)

    self.m_CurrentPrimaryAmmo = p_CurrentPrimaryAmmo or 0
end

function BRItemWeapon:SetPrimaryAmmo(p_AmmoCount)
    self.m_CurrentPrimaryAmmo = p_AmmoCount
end

function BRItemWeapon:AsTable(p_Extended)
    local s_Table = BRItem.AsTable(self, p_Extended)

    s_Table.CurrentPrimaryAmmo = self.m_CurrentPrimaryAmmo

    if p_Extended then
        s_Table.Tier = self.m_Definition.m_Tier
        s_Table.AmmoName = self.m_Definition.m_AmmoDefinition.m_Name
    end

    return s_Table
end

function BRItemWeapon:CreateFromTable(p_Table)
    return BRItemWeapon(p_Table.Id, m_WeaponDefinitions[p_Table.UId], p_Table.CurrentPrimaryAmmo)
end

--==============================
-- Weapon related functions
--==============================
