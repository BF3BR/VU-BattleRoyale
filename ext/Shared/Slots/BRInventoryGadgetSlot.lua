require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

local m_Logger = Logger("BRInventoryGadgetSlot", true)

class("BRInventoryGadgetSlot", BRInventorySlot)

function BRInventoryGadgetSlot:__init(p_Inventory)
    BRInventorySlot.__init(self, p_Inventory, { ItemType.Gadget })

    self.m_UnlockWeaponSlot = WeaponSlot.WeaponSlot_2
end

function BRInventoryGadgetSlot:OnBeforeDrop()
    self:UpdateItemPrimaryAmmo()

    return {}
end

function BRInventoryGadgetSlot:UpdateItemPrimaryAmmo()
    local s_Owner = self:GetOwner()
    if s_Owner == nil or s_Owner.soldier == nil then
        m_Logger:Write("Slot owner is undefined")
        return
    end

    -- get current weapon
    local s_Weapon = s_Owner.soldier.weaponsComponent.weapons[self.m_UnlockWeaponSlot + 1]
    if s_Weapon == nil or self.m_Item == nil then
        return
    end

    -- when it was about to reload but dropped
    if s_Weapon.primaryAmmo == 0 and self.m_Item.m_CurrentPrimaryAmmo > 0 then
        self.m_Item:DecreaseQuantityBy(1)
    end

    -- check in case it was destroyed
    if self.m_Item ~= nil then
        self.m_Item:SetPrimaryAmmo(s_Weapon.primaryAmmo)
    end
end

function BRInventoryGadgetSlot:DestroyIfEmpty()
    if self.m_Item == nil then
        return nil
    end

    local s_Owner = self:GetOwner()
    if s_Owner == nil or s_Owner.soldier == nil then
        m_Logger:Write("Slot owner is undefined")
        return
    end

    local s_Gadget = s_Owner.soldier.weaponsComponent.weapons[self.m_UnlockWeaponSlot + 1]

    -- check for a specific case after weapon change when gadget is out of ammo
    if self.m_Item.m_Quantity == 1 and s_Gadget.primaryAmmo == 0 then
        self.m_Item:SetQuantity(0)
    end
end

function BRInventoryGadgetSlot:GetUnlockWeaponAndSlot()
    if self.m_Item == nil then
        return nil
    end

    -- Create gadget unlock
    local s_Gadget = UnlockWeaponAndSlot()
    s_Gadget.slot = WeaponSlot.WeaponSlot_2
    s_Gadget.weapon = SoldierWeaponUnlockAsset(
        self.m_Item.m_Definition.m_SoldierWeaponBlueprint:GetInstance()
    )

    return s_Gadget
end

function BRInventoryGadgetSlot:HasWeapon(p_WeaponName)
    return self.m_Item ~= nil and self.m_Item.m_Definition.m_EbxName == p_WeaponName
end

function BRInventoryGadgetSlot:OnUpdate()
    m_Logger:Write("Gadget slot updated")
    self.m_Inventory:DeferUpdateSoldierCustomization()
end
