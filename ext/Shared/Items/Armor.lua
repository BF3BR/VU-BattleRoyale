require "__shared/Enums/ArmorTypes"

class "Armor"

function Armor:__init(p_ArmorType, p_CurrentDurability)
	self.m_Type = p_ArmorType
	self.m_CurrentDurability = p_CurrentDurability or p_ArmorType.Durability
end

-- Applies damage to the armor. Returns the damage passed through.
function Armor:ApplyDamage(p_Damage)
	-- check if armor is fully damaged
	if self.m_CurrentDurability <= 0 then
		return p_Damage
	end

	-- calculate damage
	local l_DamageToArmor = p_Damage * self.m_Type.DamageReduction
	local l_DamagePassed = p_Damage - l_DamageToArmor

	-- update armor durability
	self.m_CurrentDurability = self.m_CurrentDurability - l_DamageToArmor
	if self.m_CurrentDurability < 0 then
		l_DamagePassed = l_DamagePassed + math.abs(self.m_CurrentDurability)
		self.m_CurrentDurability = 0
	end

	return l_DamagePassed
end

function Armor:GetPercentage()
	if self.m_Type.Durability < 1 then
		return 0
	end

	return math.floor((self.m_CurrentDurability / self.m_Type.Durability) * 100)
end

function Armor:AsTable()
	return {
		Type = self.m_Type.Name,
		CurrentDurability = self.m_CurrentDurability
	}
end

function Armor:UpdateFromTable(p_ArmorTable)
	self.m_Type = ArmorTypes[p_ArmorTable.Type]
	self.m_CurrentDurability = p_ArmorTable.CurrentDurability
end

function Armor.static:FromTable(p_ArmorTable)
	return Armor(ArmorTypes[p_ArmorTable.Type], p_ArmorTable.CurrentDurability)
end

function Armor.static:NoArmor()
	return Armor(ArmorTypes.NoArmor)
end

function Armor.static:BasicArmor()
	return Armor(ArmorTypes.BasicArmor)
end
