require "__shared/Enums/TeamManagerEvents"
require "__shared/Items/Armor"

class "BRPlayer"

function BRPlayer:__init(p_Player, p_Team, p_Armor)
    -- the vanilla player object of the player
    self.m_Player = p_Player

    -- the BRTeam that the player is part of
    self.m_Team = p_Team

    self.m_Armor = p_Armor or Armor:NoArmor()
    self.m_Kills = 0
    self.m_Score = 0
end

-- Returns the username of the player
function BRPlayer:Name()
    return (self.m_Player ~= nil and self.m_Player.name) or nil
end

function BRPlayer:SetTeam(p_Team)
    -- TODO send NetEvent to update team
    self.m_Team = p_Team
    self:ApplyTeamSquadIds()
end

-- Updates the vanilla player team/squad Ids
function BRPlayer:ApplyTeamSquadIds()
    -- ensure that the player is dead
    if self.m_Team ~= nil and self.m_Player ~= nil and not self.m_Player.alive then
        self.m_Player.TeamId = p_Team.m_TeamId
        self.m_Player.SquadId = p_Team.m_SquadId
    end
end

-- 
function BRPlayer:SetArmor(p_Armor)
    self.m_Armor = p_Armor
    NetEvents:SendToLocal(BRPlayerNetEvents.ArmorState, self.m_Player, self.m_Armor:AsTable())
end

-- 
function BRPlayer:ApplyDamage(p_Damage, p_IgnoreArmor)
    -- TODO add a lot...
    local l_Damage = p_Damage
    if not p_IgnoreArmor then
        l_Damage = self.m_Armor:ApplyDamage(p_Damage)
    end

    self.m_Player.soldier.health = self.m_Player.soldier.health - l_Damage
end

-- Removes a player from his current team and moves him to a newly created one
-- @param p_IgnoreNewTeam
function BRPlayer:LeaveTeam(p_IgnoreNewTeam)
    -- remove player from old team
    if self.m_Team ~= nil then
        self.m_Team:RemovePlayer(self)
        self.m_Team = nil
    end

    -- join a newly created team
    if p_IgnoreNewTeam then
        -- Request TM to create a team and put this player in it
        Events:DispatchLocal('TM:PutOnATeam', self)
    end
end

-- Checks if the player and `p_OtherBrPlayer` are on the same team
function BRPlayer:IsTeammate(p_OtherBrPlayer)
    return self.m_Team ~= nil and self.m_Team:Equals(p_OtherBrPlayer.m_Team)
end

-- Checks if the player has any alive teammates
function BRPlayer:HasAliveTeammates()
    return self.m_Team ~= nil and self.m_Team:HasAlivePlayers(self)
end

-- Kills the player
-- @param p_Forced (optional) calls :ForceDead() instead of :Kill()
function BRPlayer:Kill(p_Forced)
    -- check if alive
    if not self.m_Player.isAlive then
        return
    end

    -- get soldier entity
    p_Forced = not (not p_Forced)
    local l_Soldier = self.m_Player.soldier or self.m_Player.corpse

    if p_Forced then
        l_Soldier:ForceDead()
    else
        l_Soldier:Kill()
    end
end

function BRPlayer:__eq(p_OtherBrPlayer)
    return self:Equals(p_OtherBrPlayer)
end

--
function BRPlayer:Equals(p_OtherBrPlayer)
    return p_OtherBrPlayer ~= nil and self.m_Player.name == BRPlayer:GetPlayerName(p_OtherBrPlayer)
end

function BRPlayer:__gc()
    self:Destroy()
end

function BRPlayer:Destroy()
    self:LeaveTeam()

    self.m_Player = nil
    self.m_Team = nil
    self.m_Armor = nil
end

-- A helper function to get the name of the player
-- * p_Player is string          --> p_Player
-- * p_Player is vanilla player  --> p_Player.name
-- * p_Player is BRPlayer        --> p_Player.m_Player.name
-- * else                        --> nil
function BRPlayer.static:GetPlayerName(p_Player)
    return (type(p_Player) == "string" and p_Player) or
               (type(p_Player) == "table" and (p_Player.name or (p_Player.m_Player ~= nil and p_Player.m_Player.name))) or
               nil
end
