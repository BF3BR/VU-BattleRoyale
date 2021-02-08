class "Whitelist"

require "__shared/Configs/ServerConfig"
require "__shared/Utils/TableHelper"

function Whitelist:__init()
    Hooks:Install('Player:RequestJoin', 100, self, self.OnPlayerRequestJoin) 
end

function Whitelist:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
    if not TableHelper:Empty(ServerConfig.Debug.Whitelist) then
        for _, l_Name in pairs(ServerConfig.Debug.Whitelist) do
            if p_PlayerName:lower() == l_Name:lower() then
                return
            end
        end
        p_Hook:Return(false)
    else
        return
    end
end

g_Whitelist = Whitelist()
