local m_AmmoDefinitions = require "__shared/Items/Definitions/BRItemAmmoDefinition"

---@class BRItemAmmo : BRItem
---@field m_Definition BRItemAmmoDefinition
BRItemAmmo = class("BRItemAmmo", BRItem)

---Creates a new BRItemAmmo
---@param p_Id string @It is a tostring(Guid)
---@param p_Definition BRItemAmmoDefinition
---@param p_Quantity integer
function BRItemAmmo:__init(p_Id, p_Definition, p_Quantity)
	BRItem.__init(self, p_Id, p_Definition, p_Quantity)
end

function BRItemAmmo:CreateFromTable(p_Table)
	return BRItemAmmo(p_Table.Id, m_AmmoDefinitions[p_Table.UId], p_Table.Quantity)
end
