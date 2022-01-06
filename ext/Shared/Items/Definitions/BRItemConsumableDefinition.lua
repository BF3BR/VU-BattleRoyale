---@class BRItemConsumableDefinition : BRItemDefinition
BRItemConsumableDefinition = class("BRItemConsumableDefinition", BRItemDefinition)

---@class BRItemConsumableDefinitionOptions : BRItemDefinitionOptions
---@field HealthToRegen integer
---@field TimeToApply integer

---Creates a new BRItemConsumableDefinition
---@param p_UId string
---@param p_Name string
---@param p_Options BRItemConsumableDefinitionOptions
function BRItemConsumableDefinition:__init(p_UId, p_Name, p_Options)
	p_Options = p_Options or {}

	-- set fixed shared option values for consumables
	---@type ItemType|integer
	p_Options.Type = ItemType.Consumable
	p_Options.Price = 0

	-- call super's constructor and set shared options
	BRItemDefinition.__init(self, p_UId, p_Name, p_Options)

	-- The ammount of health you regenerate after using this item
	self.m_HealthToRegen = p_Options.HealthToRegen

	-- The time it takes to regenerate your health / use the item
	self.m_TimeToApply = p_Options.TimeToApply
end

return {
	["consumable-small-medkit"] = BRItemConsumableDefinition(
		"consumable-small-medkit",
		"Small Medkit",
		{
			Description = "A small medkit, it's gonna refill 25% of your health.",
			UIIcon = "UI/Art/Persistence/KitItem/Fancy/medkit",
			RandomWeight = 45,
			Stackable = true,
			MaxStack = 3,
			HealthToRegen = 25,
			TimeToApply = 3,
			Mesh = MeshModel(
				DC(Guid("077FFC1D-1079-0D3E-B3AF-610E461217C6"), Guid("EFC1128E-7DDB-7283-B936-FF1CD422DE53"))
			),
			Transform = LinearTransform(
				Vec3(0.5, 0.0, 0.0),
				Vec3(0.0, 0.5, 0.0),
				Vec3(0.0, 0.0, 0.5),
				Vec3(-0.25, 0.0, -0.15)
			),
		}
	),
	["consumable-large-medkit"] = BRItemConsumableDefinition(
		"consumable-large-medkit",
		"Large Medkit",
		{
			Description = "A large medkit, it's gonna refill 50% of your health.",
			UIIcon = "UI/Art/Persistence/KitItem/Fancy/medkit",
			RandomWeight = 10,
			Stackable = true,
			MaxStack = 1,
			HealthToRegen = 50,
			TimeToApply = 5,
			Mesh = MeshModel(
				DC(Guid("077FFC1D-1079-0D3E-B3AF-610E461217C6"), Guid("EFC1128E-7DDB-7283-B936-FF1CD422DE53"))
			),
			Transform = LinearTransform(
				Vec3(1.0, 0.0, 0.0),
				Vec3(0.0, 1.0, 0.0),
				Vec3(0.0, 0.0, 1.0),
				Vec3(-0.25, 0.0, -0.25)
			),
		}
	),
}
