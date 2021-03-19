require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/BRPlayerState"
require "__shared/Enums/CustomEvents"
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
            Events:DispatchLocal(TeamManagerEvent.PutOnATeam, self)
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

    NetEvents:SendToLocal(DamageEvent.Hit, p_Giver.m_Player, p_Damage)

    local l_Soldier = self:GetSoldier()
    if l_Soldier == nil then
        return p_Damage
    end

    local health = l_Soldier.health
    if l_Soldier.isInteractiveManDown and p_Damage >= health then
        self:Kill(true)
        Events:DispatchLocal(TeamManagerEvent.RegisterKill, self, p_Giver)

        return health
    elseif not l_Soldier.isInteractiveManDown then
         health = health - 100
        p_Damage = self.m_Armor:ApplyDamage(p_Damage)
        self:SendState()

        if p_Damage >= health then
            -- kill instantly if no teammates left
            if self:HasAliveTeammates() then
                self.m_KillerName = p_Giver:GetName()
                NetEvents:SendToLocal(DamageEvent.PlayerDown, p_Giver.m_Player, self:GetName())
            else
                -- p_Giver:IncrementKills(self)
                self.m_KillerName = nil -- TODO move to onRevive
                self:Kill(true)
                Events:DispatchLocal(TeamManagerEvent.RegisterKill, self, p_Giver)
            end

            return health + 100
        end
    end

    return math.max(0.001, p_Damage)
end

-- Alias for `BRTeam:RemovePlayer()`
function BRPlayer:LeaveTeam(p_Forced, p_IgnoreBroadcast)
    if self.m_Team ~= nil then
        return self.m_Team:RemovePlayer(self, p_Forced, p_IgnoreBroadcast)
    end

    return false
end

-- Increments the kill counter of the player
function BRPlayer:IncrementKills(p_Victim)
    if p_Victim == nil or not self:Equals(p_Victim) then
        self.m_Kills = self.m_Kills + 1
        self:SendState()
    end

    -- send related net events
    NetEvents:SendToLocal(DamageEvent.PlayerKill, self.m_Player, p_Victim:GetName())
    NetEvents:SendToLocal(DamageEvent.PlayerKilled, p_Victim.m_Player, self:GetName())
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

    p_Forced = not (not p_Forced)

    -- get soldier entity
    local l_Soldier = self:GetSoldier()
    if l_Soldier == nil then
        return
    end

    if p_Forced then
        l_Soldier:ForceDead()
    else
        l_Soldier:Kill()
    end
end

-- Spawns the player
-- @param p_Trans - where to spawn the player
function BRPlayer:Spawn(p_Trans)
    -- check if alive
    if self.m_Player.alive then
        return
    end

    local s_SoldierAsset = nil
    local s_Appearance = nil
    local s_SoldierBlueprint = ResourceManager:SearchForDataContainer("Characters/Soldiers/MpSoldier")

    -- TODO: @Janssent's appearance code gonna land here probably
    if self.m_Player.teamId == TeamId.Team1 then
        s_SoldierAsset = ResourceManager:SearchForDataContainer("Gameplay/Kits/USAssault")
        s_Appearance = ResourceManager:SearchForDataContainer(
                           "Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Assault_Appearance_Wood01")
    else
        s_SoldierAsset = ResourceManager:SearchForDataContainer("Gameplay/Kits/RUAssault")
        s_Appearance = ResourceManager:SearchForDataContainer(
                           "Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Assault_Appearance_Wood01")
    end

    if s_SoldierAsset == nil or s_Appearance == nil or s_SoldierBlueprint == nil then
        return
    end

    self.m_Player:SelectUnlockAssets(s_SoldierAsset, {s_Appearance})

    local s_SpawnedSoldier = self.m_Player:CreateSoldier(s_SoldierBlueprint, p_Trans)

    self.m_Player:SpawnSoldierAt(s_SpawnedSoldier, p_Trans, CharacterPoseType.CharacterPoseType_Stand)
    self.m_Player:AttachSoldier(s_SpawnedSoldier)

    self.m_Player.soldier:ApplyCustomization(self:CreateCustomizeSoldierData())
    self.m_Player.soldier.weaponsComponent.currentWeapon.secondaryAmmo = 8
end

function BRPlayer:CreateCustomizeSoldierData()
    local s_CustomizeSoldierData = CustomizeSoldierData()
    s_CustomizeSoldierData.restoreToOriginalVisualState = false
    s_CustomizeSoldierData.clearVisualState = true
    s_CustomizeSoldierData.overrideMaxHealth = -1.0
    s_CustomizeSoldierData.overrideCriticalHealthThreshold = -1.0

    local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
    s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
                                                                Guid("0003DE1B-F3BA-11DF-9818-9F37AB836AC2"),
                                                                Guid("8963F500-E71D-41FC-4B24-AE17D18D8C73")))
    s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_7
    s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot)

    local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
    s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
                                                                Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),
                                                                Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B")))
    s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_9
    s_CustomizeSoldierData.weapons:add(s_UnlockWeaponAndSlot)

    s_CustomizeSoldierData.activeSlot = WeaponSlot.WeaponSlot_9
    s_CustomizeSoldierData.removeAllExistingWeapons = true
    s_CustomizeSoldierData.disableDeathPickup = false

    return s_CustomizeSoldierData
end

function BRPlayer:SendState(p_Simple, p_TeamData)
    local l_Data = self:AsTable(p_Simple, p_TeamData)
    NetEvents:SendToLocal(TeamManagerNetEvent.PlayerState, self.m_Player, l_Data)
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

-- Compare two BRPlayer instances for equality
function BRPlayer:Equals(p_OtherBrPlayer)
    return p_OtherBrPlayer ~= nil and self:GetName() == p_OtherBrPlayer:GetName()
end

-- `==` metamethod
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

-- Garbage collector metamethod
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
               (type(p_Player) == "table" and p_Player:GetName()) or nil
end
