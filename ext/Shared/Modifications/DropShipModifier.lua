class "DropShipModifier"

local m_Something = DC(Guid(""), Guid(""))

function DropShipModifier:RegisterCallbacks()
	--m_Something:RegisterLoadHandler(self, self.Something)
end

function DropShipModifier:DeregisterCallbacks()
	--m_Something:Deregister()
end

function DropShipModifier:Something(p_Something)

end

return DropShipModifier()
