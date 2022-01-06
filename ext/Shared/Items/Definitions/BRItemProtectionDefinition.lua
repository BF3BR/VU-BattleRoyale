---@class BRItemProtectionDefinition : BRItemDefinition
BRItemProtectionDefinition = class("BRItemProtectionDefinition", BRItemDefinition)

---@class BRItemProtectionDefinitionOptions : BRItemDefinitionOptions
---@field Tier Tier|integer|nil
---@field Durability integer|nil
---@field DamageReduction integer|nil

---Creates a new BRItemProtectionDefinition
---@param p_UId string
---@param p_Name string
---@param p_Options BRItemProtectionDefinitionOptions
function BRItemProtectionDefinition:__init(p_UId, p_Name, p_Options)
	p_Options = p_Options or {}

	-- set fixed shared option values for protective items
	p_Options.Stackable = false
	p_Options.MaxStack = nil
	p_Options.Price = 0

	-- call super's constructor and set shared options
	BRItemDefinition.__init(self, p_UId, p_Name, p_Options)

	-- set protective items shared options
	---@type Tier|integer
	self.m_Tier = p_Options.Tier or Tier.Tier1
	self.m_Durability = p_Options.Durability or 50
	self.m_DamageReduction = p_Options.DamageReduction or 1
end

return {}
