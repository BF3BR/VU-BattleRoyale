require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

local m_Logger = Logger("BRInventoryWeaponSlot", true)

class("BRInventoryWeaponSlot", BRInventorySlot)

local m_NoOptics = DC(Guid("6D3830F2-3528-11E0-B502-B15F9292C9B8"), Guid("A1AD1762-C856-F5D7-66B5-5E485460D3DF"))
local m_NoPrimaryAccessory = DC(Guid("57CE9FB1-3528-11E0-B502-B15F9292C9B8"), Guid("C6F8E97B-A579-263F-C9F6-38397F7706A0"))
local m_NoSecondaryAccessory = DC(Guid("619781B1-3528-11E0-B502-B15F9292C9B8"), Guid("BBB62E4A-4F15-29F6-0C5C-BAB1609B0636"))

function BRInventoryWeaponSlot:__init(p_Inventory, p_UnlockWeaponSlot)
    BRInventorySlot.__init(self, p_Inventory, { ItemType.Weapon })

    self.m_UnlockWeaponSlot = p_UnlockWeaponSlot
    self.m_AttachmentSlots = {
        OpticsSlot = nil,
        BarrelSlot = nil,
        OtherSlot = nil
    }
end

function BRInventoryWeaponSlot:OnBeforeDrop()
    -- 1. Save primary ammo in item
    self:UpdateItemPrimaryAmmo()

    -- 2. Drop attachments
    local s_DroppedAttachments = {}

    for _, l_AttachmentSlot in pairs(self.m_AttachmentSlots) do
        local s_Items = l_AttachmentSlot:Drop()

        -- attachments only drop one item
        if #s_Items == 1 then
            table.insert(s_DroppedAttachments, s_Items[1])
        end
    end

    return s_DroppedAttachments
end

function BRInventoryWeaponSlot:ResolveSlot(p_Item)
    if not BRInventorySlot.IsAccepted(self, p_Item) then

        if p_Item.m_Definition.m_Type == ItemType.Attachment then
            for _, l_Slot in pairs(self.m_AttachmentSlots) do
                local l_ResolvedAttachmentSlot = l_Slot:ResolveSlot(p_Item)
                if l_ResolvedAttachmentSlot ~= nil then
                    return l_ResolvedAttachmentSlot
                end
            end
        end

        return nil
    end

    return self
end

function BRInventoryWeaponSlot:PutWithRelated(p_Items)
    for _, l_Item in ipairs(p_Items) do
        local s_Def = l_Item.m_Definition

        -- put weapon
        if s_Def.m_Type == ItemType.Weapon then
            self:Put(l_Item)
        end

        -- put optics attachment
        if s_Def.m_Type == ItemType.Attachment and s_Def.m_AttachmentType == AttachmentType.Optics then
            self.m_AttachmentSlots.OpticsSlot:Put(l_Item)
        end

        -- put barrel attachment
        if s_Def.m_Type == ItemType.Attachment and s_Def.m_AttachmentType == AttachmentType.Barrel then
            self.m_AttachmentSlots.BarrelSlot:Put(l_Item)
        end

        -- put other attachment
        if s_Def.m_Type == ItemType.Attachment and s_Def.m_AttachmentType == AttachmentType.Other then
            self.m_AttachmentSlots.OtherSlot:Put(l_Item)
        end
    end

    return true, {}
end

function BRInventoryWeaponSlot:GetUnlockWeaponAndSlot()
    if self.m_Item == nil then
        return nil
    end

    -- Create weapon unlock
    local s_Weapon = UnlockWeaponAndSlot()
    s_Weapon.slot = self.m_UnlockWeaponSlot
    s_Weapon.weapon = SoldierWeaponUnlockAsset(
        self.m_Item.m_Definition.m_SoldierWeaponBlueprint:GetInstance()
    )

    -- Add attachments
    for l_Index, l_Slot in pairs(self.m_AttachmentSlots) do
        local s_Unlock = l_Slot:GetUnlockAsset()

        if s_Unlock ~= nil then
            s_Weapon.unlockAssets:add(s_Unlock)
        else
            if l_Index == "OpticsSlot" then
                s_Weapon.unlockAssets:add(m_NoOptics:GetInstance())
            elseif l_Index == "BarrelSlot" then
                s_Weapon.unlockAssets:add(m_NoPrimaryAccessory:GetInstance())
            elseif l_Index == "OtherSlot" then
                s_Weapon.unlockAssets:add(m_NoSecondaryAccessory:GetInstance())
            end
        end
    end

    return s_Weapon
end

function BRInventoryWeaponSlot:UpdateItemPrimaryAmmo()
    local s_Owner = self:GetOwner()
    if s_Owner == nil or s_Owner.soldier == nil then
        m_Logger:Write("Slot owner is undefined")
        return
    end

    -- get current weapon
    local s_Weapon = s_Owner.soldier.weaponsComponent.weapons[self.m_UnlockWeaponSlot + 1]
    if s_Weapon == nil or
       self.m_Item == nil or
       self.m_Item.m_Definition.m_EbxName ~= s_Weapon.name then
        return
    end

    self.m_Item:SetPrimaryAmmo(s_Weapon.primaryAmmo)
end

function BRInventoryWeaponSlot:HasWeapon(p_WeaponName)
    return self.m_Item ~= nil and self.m_Item.m_Definition.m_EbxName == p_WeaponName
end

function BRInventoryWeaponSlot:OnUpdate()
    self.m_Inventory:DeferUpdateSoldierCustomization()
end

function BRInventoryWeaponSlot:BeforeCustomizationApply()
    if self.m_IsUpdated then
        return
    end

    self:UpdateItemPrimaryAmmo()
end

function BRInventoryWeaponSlot:SetAttachmentSlots(p_OpticsSlot, p_BarrelSlot, p_OtherSlot)
    self.m_AttachmentSlots = {
        OpticsSlot = p_OpticsSlot,
        BarrelSlot = p_BarrelSlot,
        OtherSlot = p_OtherSlot
    }
end
