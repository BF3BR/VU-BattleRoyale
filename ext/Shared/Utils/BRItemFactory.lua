---@module "Items/Definitions/BRItemAmmoDefinition"
---@type table<string, BRItemAmmoDefinition>
local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"
---@module "Items/Definitions/BRItemArmorDefinition"
---@type table<string, BRItemArmorDefinition>
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"
---@module "Items/Definitions/BRItemAttachmentDefinition"
---@type table<string, BRItemAttachmentDefinition>
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"
---@module "Items/Definitions/BRItemConsumableDefinition"
---@type table<string, BRItemConsumableDefinition>
local m_ConsumableDefinitions = require "__shared/Items/Definitions/BRItemConsumableDefinition"
---@module "Items/Definitions/BRItemHelmetDefinition"
---@type table<string, BRItemHelmetDefinition>
local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"
---@module "Items/Definitions/BRItemWeaponDefinition"
---@type table<string, BRItemWeaponDefinition>
local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"
---@module "Items/Definitions/BRItemGadgetDefinition"
---@type table<string, BRItemGadgetDefinition>
local m_GadgetDefinition = require "__shared/Items/Definitions/BRItemGadgetDefinition"

---@class BRItemFactory
BRItemFactory = class "BRItemFactory"

function BRItemFactory:__init()
	---@type table<string, BRItemDefinition>
	self.m_Definitions = {}

	self:AppendDefinitions(m_AmmoDefinitions)
	self:AppendDefinitions(m_ArmorDefinitions)
	self:AppendDefinitions(m_AttachmentDefinitions)
	self:AppendDefinitions(m_ConsumableDefinitions)
	self:AppendDefinitions(m_HelmetDefinitions)
	self:AppendDefinitions(m_WeaponDefinitions)
	self:AppendDefinitions(m_GadgetDefinition)
end

---@param p_Definitions table<string, BRItemDefinition> @can be all sorts of BRItemDefinition
function BRItemFactory:AppendDefinitions(p_Definitions)
	for l_Key, l_Definition in pairs(p_Definitions) do
		self.m_Definitions[l_Key] = l_Definition
	end
end

---@param p_DefinitionUId string
---@return BRItemDefinition|nil @can be all sorts of BRItemDefinition
function BRItemFactory:FindDefinitionByUId(p_DefinitionUId)
	for l_DefinitionKey, l_Definition in pairs(self.m_Definitions) do
		if l_DefinitionKey == p_DefinitionUId then
			return l_Definition
		end
	end

	return nil
end

---@param p_Table table
---@return BRItem|nil @can be all sorts of BRItem
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

return BRItemFactory()
