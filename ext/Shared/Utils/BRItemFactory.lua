require "__shared/Enums/ItemEnums"

local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"
local m_GadgetDefinition = require "__shared/Items/Definitions/BRItemGadgetDefinition"

class "BRItemFactory"

function BRItemFactory:__init()
    self.m_Definitions = {}

    self:AppendDefinitions(m_AmmoDefinitions)
    self:AppendDefinitions(m_ArmorDefinitions)
    self:AppendDefinitions(m_AttachmentDefinitions)
    self:AppendDefinitions(m_ConsumableDefinitions)
    self:AppendDefinitions(m_HelmetDefinitions)
    self:AppendDefinitions(m_WeaponDefinitions)
    self:AppendDefinitions(m_GadgetDefinition)
end

function BRItemFactory:AppendDefinitions(p_Definitions)
    for l_Key, l_Definition in pairs(p_Definitions) do
        self.m_Definitions[l_Key] = l_Definition
    end
end

function BRItemFactory:FindDefinitionByUId(p_DefinitionUId)
    for l_DefinitionKey, l_Definition in pairs(self.m_Definitions) do
        if l_DefinitionKey == p_DefinitionUId then
			return l_Definition
        end
	end

	return nil
end

function BRItemFactory:CreateFromTable(p_Table)
    local s_Definition = self.m_Definitions[p_Table.UId]

    if s_Definition.m_Type == ItemType.Armor then
        return BRItemArmor:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Helmet then
        return BRItemHelmet:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Consumable then
        return BRItemConsumable:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Ammo then
        return BRItemAmmo:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Attachment then
        return BRItemAttachment:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Weapon then
        return BRItemWeapon:CreateFromTable(p_Table)
    elseif s_Definition.m_Type == ItemType.Gadget then
        return BRItemGadget:CreateFromTable(p_Table)
    end

    return nil
end

-- define global
if g_BRItemFactory== nil then
    g_BRItemFactory = BRItemFactory()
end

return g_BRItemFactory
