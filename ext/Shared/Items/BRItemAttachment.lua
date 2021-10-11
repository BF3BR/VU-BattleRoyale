require "__shared/Items/BRItem"

local m_AttachmentDefinitions = require "__shared/Items/Definitions/BRItemAttachmentDefinition"

class("BRItemAttachment", BRItem)

function BRItemAttachment:__init(p_Id, p_Definition)
    BRItem.__init(self, p_Id, p_Definition, 1)
end

function BRItemAttachment:CreateFromTable(p_Table)
    return BRItemAttachment(p_Table.Id, m_AttachmentDefinitions[p_Table.UId])
end

--==============================
-- Attachment related functions
--==============================
