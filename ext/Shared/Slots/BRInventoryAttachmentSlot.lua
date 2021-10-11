require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

class("BRInventoryAttachmentSlot", BRInventorySlot)

function BRInventoryAttachmentSlot:__init(p_Inventory, p_AttachmentType)
    BRInventorySlot.__init(self, p_Inventory, { ItemType.Attachment })

    self.m_WeaponSlot = nil
    self.m_AttachmentType = p_AttachmentType
end

function BRInventoryAttachmentSlot:IsAccepted(p_Item)
    -- Do the basic check
    if not BRInventorySlot.IsAccepted(self, p_Item) then
        return false
    end

    if p_Item.m_Definition.m_AttachmentType ~= self.m_AttachmentType then
        return false
    end

    -- Check if weapon exists
    local s_WeaponItem = self.m_WeaponSlot.m_Item
    if s_WeaponItem == nil then
        return false
    end

    -- Check if compatible with weapon
    for l_Index, l_EbxAttachment in pairs(s_WeaponItem.m_Definition.m_EbxAttachments) do
        if p_Item.m_Definition.m_AttachmentId == l_Index then
            return true
        end
    end

    return false
end

function BRInventoryAttachmentSlot:GetUnlockAsset()
    if self.m_Item == nil and self.m_AttachmentType ~= AttachmentType.Optics then
        return nil
    end

    -- Resolve attachment id
    local s_AttachmentId = g_AttachmentIds.NoOptics
    if self.m_Item ~= nil then
        s_AttachmentId = self.m_Item.m_Definition.m_AttachmentId
    end

    return UnlockAsset(
        self.m_WeaponSlot.m_Item.m_Definition.m_EbxAttachments[s_AttachmentId]:GetInstance()
    )
end

function BRInventoryAttachmentSlot:OnUpdate()
    self.m_WeaponSlot:OnUpdate()
end

function BRInventoryAttachmentSlot:SetWeaponSlot(p_WeaponSlot)
    self.m_WeaponSlot = p_WeaponSlot
end
