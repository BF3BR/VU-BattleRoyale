class "DropShipModifier"

local m_Something = DC(Guid(""), Guid(""))

function DropShipModifier:__init()

end

function DropShipModifier:RegisterCallbacks()
	--m_AmmobagFiringData:RegisterLoadHandler(self, self.Something)
end

function DropShipModifier:Something(p_Something)

end

if g_DropShipModifier == nil then
	g_DropShipModifier = DropShipModifier()
end

return g_DropShipModifier
