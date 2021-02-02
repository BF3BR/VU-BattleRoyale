class 'Whitelist'

function Whitelist:__init()
    self.whitelistedNames = {
        "voteban_flash",
        "Bree",
        "Janssent",
        "KVN",
        "breaknix",
        "kiwidog",
        "kiwidoggie",
        "keku645",
        "DankBoi21",
    }
    Hooks:Install('Player:RequestJoin', 100, self, self.OnPlayerRequestJoin) 
end

function Whitelist:OnPlayerRequestJoin(hook, joinMode, accountGuid, playerGuid, playerName)
    for _, name in pairs(self.whitelistedNames) do
        if playerName:lower() == name:lower() then
            return
        end
    end
    hook:Return(false)
end

g_Whitelist = Whitelist()
