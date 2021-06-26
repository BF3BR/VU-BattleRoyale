class "Whitelist"

-- =============================================
-- Events
-- =============================================

function Whitelist:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
	if #ServerConfig.Debug.Whitelist > 0 then
		for _, l_Name in ipairs(ServerConfig.Debug.Whitelist) do
			if p_PlayerName:lower() == l_Name:lower() then
				return
			end
		end

		p_Hook:Return(false)
	end
end

if g_Whitelist == nil then
	g_Whitelist = Whitelist()
end

return g_Whitelist
