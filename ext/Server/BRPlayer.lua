require "__shared/Enums/TeamManagerEvents"
require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/BRPlayerState"
require "__shared/Enums/DamageEvents"
require "__shared/Items/Armor"

class "BRPlayer"

function BRPlayer:__init(p_Player)
    -- the vanilla player instance of the player
    self.m_Player = p_Player

    -- the BRTeam that the player is part of
    self.m_Team = nil

    -- indicates if the player is the leader of the team
    self.m_IsTeamLeader = false

    -- the name of the player who killed this BRPlayer
    self.m_KillerName = nil

    self.m_TeamJoinStrategy = TeamJoinStrategy.NoJoin
    self.m_Armor = Armor:BasicArmor()
    self.m_Kills = 0
    self.m_Score = 0
end

-- Returns the username of the player
function BRPlayer:GetName()
    return (self.m_Player ~= nil and self.m_Player.name) or nil
end

function BRPlayer:GetSoldier()
    return self.m_Player ~= nil and self.m_Player.soldier
end

-- 
function BRPlayer:SetArmor(p_Armor)
    self.m_Armor = p_Armor
    NetEvents:SendToLocal(BRPlayerNetEvents.ArmorState, self.m_Player, self.m_Armor:AsTable())
end

function BRPlayer:SetTeamJoinStrategy(p_Strategy)
    if self.m_TeamJoinStrategy == p_Strategy then
        return
    end

    self.m_TeamJoinStrategy = p_Strategy

    if p_Strategy ~= TeamJoinStrategy.Custom then
        if self:LeaveTeam() then
            Events:DispatchLocal(TeamManagerCustomEvents.PutOnATeam, self)
        else
            self.m_Team:SetLock(self, true)
        end
    else
        self.m_Team:SetLock(self, false)
    end

    self:SendState()
end

-- Updates the vanilla player team/squad Ids
function BRPlayer:ApplyTeamSquadIds()
    -- ensure that the player is dead
    if self.m_Player ~= nil and not self.m_Player.alive then
        self.m_Player.teamId = (self.m_Team ~= nil and self.m_Team.m_TeamId) or TeamId.Team1
        self.m_Player.squadId = (self.m_Team ~= nil and self.m_Team.m_SquadId) or SquadId.SquadNone
    end
end

-- 
function BRPlayer:OnDamaged(p_Damage, p_Giver)
    if self:IsTeammate(p_Giver) and not self:Equals(p_Giver) then
        return 0
    end

    NetEvents:SendToLocal(DamageEvents.ConfirmHit, p_Giver.m_Player, p_Damage)

    local l_Soldier = self:GetSoldier()
    if l_Soldier == nil then
        return p_Damage
    end

    local health = l_Soldier.health
    if l_Soldier.isInteractiveManDown and p_Damage >= health then
        self:Kill(true)
        Events:DispatchLocal(TeamManagerCustomEvents.IncrementKill, self, p_Giver)

        return health
    elseif not l_Soldier.isInteractiveManDown then
        -- health = health - 100
        p_Damage = self.m_Armor:ApplyDamage(p_Damage)
        self:SendState()

        if p_Damage >= health then
            -- kill instantly if no teammates left
            if self:HasAliveTeammates() then
                self.m_KillerName = p_Giver:GetName()
                NetEvents:SendToLocal(DamageEvents.ConfirmPlayerDown, p_Giver.m_Player, self:GetName())
            else
                p_Giver:IncrementKills(self:GetName())
                self:Kill(true)
            end

            return health
        end
    end

    return p_Damage
end

-- Alias for `BRTeam:RemovePlayer()`
function BRPlayer:LeaveTeam(p_Forced, p_IgnoreBroadcast)
    if self.m_Team ~= nil then
        return self.m_Team:RemovePlayer(self, p_Forced, p_IgnoreBroadcast)
    end

    return false
end

-- Increments the kill counter of the player
function BRPlayer:IncrementKills(p_VictimName)
    self.m_Kills = self.m_Kills + 1
    NetEvents:SendToLocal(DamageEvents.ConfirmPlayerKill, self.m_Player, p_VictimName)
    self:SendState()
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
    if not self.m_Player.alive then
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

function BRPlayer:SendState(p_Simple, p_TeamData)
    local l_Data = self:AsTable(p_Simple, p_TeamData)
    NetEvents:SendToLocal(TeamManagerNetEvents.PlayerState, self.m_Player, l_Data)
end

function BRPlayer:AsTable(p_Simple, p_TeamData)
    -- state used for squad members
    if p_Simple then
        local l_State = BRPlayerState.Dead
        if self.m_Player ~= nil and self.m_Player.alive and self.m_Player.soldier ~= nil then
            if self.m_Player.soldier.isAlive then
                l_State = BRPlayerState.Alive
            elseif self.m_Player.soldier.isInteractiveManDown then
                l_State = BRPlayerState.Down
            end
        end

        return {Name = self:GetName(), IsTeamLeader = self.m_IsTeamLeader, State = l_State}
    end

    -- get team data
    local l_Team = p_TeamData
    if l_Team == nil and self.m_Team ~= nil then
        l_Team = self.m_Team:AsTable()
    end

    -- state used for local player
    return {
        Team = l_Team,
        Armor = self.m_Armor:AsTable(),
        Data = {
            TeamJoinStrategy = self.m_TeamJoinStrategy,
            IsTeamLeader = self.m_IsTeamLeader,
            Kills = self.m_Kills,
            Score = self.m_Score
        }
    }
end

-- Resets the state of a player
function BRPlayer:Reset()
    self.m_Armor = Armor:BasicArmor()
    self.m_Kills = 0
    self.m_Score = 0
    self.m_KillerName = nil

    self:SendState()
end

--
function BRPlayer:Equals(p_OtherBrPlayer)
    return p_OtherBrPlayer ~= nil and self.m_Player.name == BRPlayer:GetPlayerName(p_OtherBrPlayer)
end

function BRPlayer:__eq(p_OtherBrPlayer)
    return self:Equals(p_OtherBrPlayer)
end

function BRPlayer:Destroy()
    self:LeaveTeam(true)

    self.m_KillerName = nil
    self.m_Player = nil
    self.m_Team = nil
    self.m_Armor = nil
end

function BRPlayer:__gc()
    self:Destroy()
end

-- A helper function to get the name of the player
-- * p_Player is string          --> p_Player
-- * p_Player is vanilla player  --> p_Player.name
-- * p_Player is BRPlayer        --> p_Player.m_Player.name
-- * else                        --> nil
function BRPlayer.static:GetPlayerName(p_Player)
    return (type(p_Player) == "string" and p_Player) or (type(p_Player) == "userdata" and p_Player.name) or
               (type(p_Player) == "table" and p_Player.m_Player ~= nil and p_Player.m_Player.name) or nil
end
