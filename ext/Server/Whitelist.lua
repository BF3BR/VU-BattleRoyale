class "Whitelist"

require "__shared/Configs/ServerConfig"

function Whitelist:__init()
    Hooks:Install("Player:RequestJoin", 100, self, self.OnPlayerRequestJoin)
end

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

g_Whitelist = Whitelist()
