---@module "Items/Definitions/BRItemArmorDefinition"
---@type table<string, BRItemArmorDefinition>
local m_ArmorDefinitions = require "__shared/Items/Definitions/BRItemArmorDefinition"

---@class BRItemArmor : BRItem
---@field m_Definition BRItemArmorDefinition
BRItemArmor = class("BRItemArmor", BRItem)

---Creates a new BRItemArmor
---@param p_Id string @It is a tostring(Guid)
---@param p_Definition BRItemArmorDefinition
---@param p_CurrentDurability integer
function BRItemArmor:__init(p_Id, p_Definition, p_CurrentDurability)
	BRItem.__init(self, p_Id, p_Definition, 1)

	self.m_CurrentDurability = p_CurrentDurability or p_Definition.m_Durability
end

function BRItemArmor:AsTable(p_Extended)
	local s_Table = BRItem.AsTable(self, p_Extended)

	s_Table.CurrentDurability = self.m_CurrentDurability

	if p_Extended then
		s_Table.Tier = self.m_Definition.m_Tier
		s_Table.Durability = self.m_Definition.m_Durability
		s_Table.CurrentDurability = self.m_CurrentDurability
	end

	return s_Table
end

function BRItemArmor:CreateFromTable(p_Table)
	return BRItemArmor(p_Table.Id, m_ArmorDefinitions[p_Table.UId], p_Table.CurrentDurability)
end

--==============================
-- Armor related functions
--==============================

-- Applies damage to the armor.
-- returns:
--  * (int) the damage passed through.
--  * (bool) if the armor was destoyed
--
-- @param p_Damage number
--
function BRItemArmor:ApplyDamage(p_Damage)
	-- check if armor is fully damaged
	if self.m_CurrentDurability <= 0 then
		return p_Damage, true
	end

	-- calculate damage
	local s_DamageToArmor = p_Damage * self.m_Definition.m_DamageReduction
	local s_DamagePassed = p_Damage - s_DamageToArmor

	-- update armor durability
	self.m_CurrentDurability = self.m_CurrentDurability - s_DamageToArmor

	if self.m_CurrentDurability < 0 then
		s_DamagePassed = s_DamagePassed + math.abs(self.m_CurrentDurability)
		self.m_CurrentDurability = 0
	end

	self:SetUpdated()

	return s_DamagePassed, self.m_CurrentDurability <= 0
end

-- Returns the current percentage of the armor
function BRItemArmor:GetPercentage()
	if self.m_CurrentDurability <= 0 then
		return 0
	end

	return math.ceil((self.m_CurrentDurability / self.m_Definition.m_Durability) * 100)
end
