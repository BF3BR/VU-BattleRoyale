local m_HelmetDefinitions = require "__shared/Items/Definitions/BRItemHelmetDefinition"

class("BRItemHelmet", BRItem)

function BRItemHelmet:__init(p_Id, p_Definition, p_CurrentDurability)
	BRItem.__init(self, p_Id, p_Definition, 1)

	self.m_CurrentDurability = p_CurrentDurability or p_Definition.m_Durability
end

function BRItemHelmet:AsTable(p_Extended)
	local s_Table = BRItem.AsTable(self, p_Extended)

	s_Table.CurrentDurability = self.m_CurrentDurability

	if p_Extended then
		s_Table.Tier = self.m_Definition.m_Tier
		s_Table.Durability = self.m_Definition.m_Durability
		s_Table.CurrentDurability = self.m_CurrentDurability
	end

	return s_Table
end

function BRItemHelmet:CreateFromTable(p_Table)
	return BRItemHelmet(p_Table.Id, m_HelmetDefinitions[p_Table.UId], p_Table.CurrentDurability)
end

--==============================
-- Helmet related functions
--==============================

-- Applies damage to the helmet.
-- returns:
--  * (int) the damage passed through.
--  * (bool) if the helmet was destoyed
--
-- @param p_Damage number
--
function BRItemHelmet:ApplyDamage(p_Damage)
	-- check if helmet is fully damaged
	if self.m_CurrentDurability <= 0 then
		return p_Damage, true
	end

	-- calculate damage
	local s_DamageToHelmet = p_Damage * self.m_Definition.m_DamageReduction
	local s_DamagePassed = p_Damage - s_DamageToHelmet

	-- update helmet durability
	self.m_CurrentDurability = self.m_CurrentDurability - s_DamageToHelmet

	if self.m_CurrentDurability < 0 then
		s_DamagePassed = s_DamagePassed + math.abs(self.m_CurrentDurability)
		self.m_CurrentDurability = 0
	end

	self:SetUpdated()

	return s_DamagePassed, self.m_CurrentDurability <= 0
end

-- Returns the current percentage of the helmet
function BRItemHelmet:GetPercentage()
	if self.m_CurrentDurability <= 0 then
		return 0
	end

	return math.ceil((self.m_CurrentDurability / self.m_Definition.m_Durability) * 100)
end
