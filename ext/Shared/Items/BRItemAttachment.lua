---@module "Items/Definitions/BRItemAttachmentDefinition"
---@type table<string, BRItemAttachmentDefinition>
local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"

---@class BRItemAttachment : BRItem
---@field m_Definition BRItemAttachmentDefinition
BRItemAttachment = class("BRItemAttachment", BRItem)

---Creates a new BRItemAttachment
---@param p_Id string @It is a tostring(Guid)
---@param p_Definition BRItemAttachmentDefinition
function BRItemAttachment:__init(p_Id, p_Definition)
	BRItem.__init(self, p_Id, p_Definition, 1)
end

function BRItemAttachment:CreateFromTable(p_Table)
	return BRItemAttachment(p_Table.Id, m_AttachmentDefinitions[p_Table.UId])
end
