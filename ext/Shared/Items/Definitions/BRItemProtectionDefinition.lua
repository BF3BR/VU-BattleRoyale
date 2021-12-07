class("BRItemProtectionDefinition", BRItemDefinition)

function BRItemProtectionDefinition:__init(p_UId, p_Name, p_Options)
	p_Options = p_Options or {}

	-- set fixed shared option values for protective items
	p_Options.Stackable = false
	p_Options.MaxStack = nil
	p_Options.Price = 0

	-- call super's constructor and set shared options
	BRItemDefinition.__init(self, p_UId, p_Name, p_Options)

	-- set protective items shared options
	self.m_Tier = p_Options.Tier or Tier.Tier1
	self.m_Durability = p_Options.Durability or 50
	self.m_DamageReduction = p_Options.DamageReduction or 1
end

return {}
