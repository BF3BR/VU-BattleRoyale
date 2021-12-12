---@class Whitelist
local Whitelist = class "Whitelist"

-- =============================================
-- Hooks
-- =============================================

function Whitelist:OnPlayerRequestJoin(p_HookCtx, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
	if not ServerConfig.Debug.EnableWhitelist then
		return
	end

	if #ServerConfig.Debug.Whitelist > 0 then
		for _, l_Name in ipairs(ServerConfig.Debug.Whitelist) do
			if p_PlayerName:lower() == l_Name:lower() then
				return
			end
		end

		p_HookCtx:Return(false)
	end
end

return Whitelist()
