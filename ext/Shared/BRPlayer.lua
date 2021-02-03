require "__shared/Items/Armor"

class "BRPlayer"

function BRPlayer:__init(p_Player)
    self.m_Player = p_Player
    self.m_Team = nil
    self.m_Armor = Armor:NoArmor()
    self.m_Score = 0
end

function BRPlayer:SetTeam(p_Team)
    -- TODO send NetEvent to update team
    self.m_Team = p_Team

    -- update vanilla player team/squad id
    if p_Team ~= nil then
        self.m_Player.TeamId = p_Team.m_TeamId
        self.m_Player.SquadId = p_Team.m_SquadId
    end
end

function BRPlayer:SetArmor(p_Armor)
    -- TODO send NetEvent to update armor
    self.m_Armor = p_Armor
end

-- 
function BRPlayer:ApplyDamage(p_Damage)
    -- TODO add a lot...
    local l_Damage = self.m_Armor:ApplyDamage(p_Damage)
    self.m_Player.soldier.health = self.m_Player.soldier.health - l_Damage
end

-- Checks if the player and `p_OtherBrPlayer` are on the same team
function BRPlayer:IsTeammate(p_OtherBrPlayer)
    return self.m_Team ~= nil and self.m_Team:IsEqual(p_OtherBrPlayer.m_Team)
end

-- Kills the player
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
