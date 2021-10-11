class "PostReloadEvent"

local m_Logger = Logger("PostReloadEvent", true)

function PostReloadEvent:__init()
    self:ResetVars()

    Events:Subscribe("Player:ChangingWeapon", self, self.OnPlayerChangingWeapon)
    Events:Subscribe("Player:Reload", self, self.OnPlayerReload)
    Events:Subscribe("WeaponFiring:Update", self, self.OnWeaponFiring)
end

function PostReloadEvent:ResetVars()
    self.m_ReloadEvents = {}
end

-- a bit of ugly solution but this f****g shotgun messes things up
function PostReloadEvent:OnPlayerChangingWeapon(p_Player)
    if p_Player == nil or p_Player.soldier == nil then
        return
    end

    local s_PlayerWeapons = p_Player.soldier.weaponsComponent.weapons

    for l_Key, l_ReloadData in pairs(self.m_ReloadEvents) do
        if p_Player.id == l_ReloadData.PlayerId then
            local s_ReloadEvent = self.m_ReloadEvents[l_Key]

            -- check if weapon of reload event still belongs to player
            for _, l_Weapon in pairs(s_PlayerWeapons) do
                -- m_Logger:Write(s_ReloadEvent.WeaponInstanceId == l_Weapon.instanceId)
                if l_Weapon ~= nil and
                    s_ReloadEvent.WeaponInstanceId == l_Weapon.instanceId and 
                    l_Weapon.primaryAmmo ~= s_ReloadEvent.Ammo then
                    Events:Dispatch("Player:PostReload", p_Player, l_Weapon.primaryAmmo - s_ReloadEvent.Ammo, l_Weapon)
                end
            end

            -- clear reload event reference
            self.m_ReloadEvents[l_Key] = nil
        end
    end
end

function PostReloadEvent:OnPlayerReload(p_Player, p_WeaponName, p_Position)
    if p_Player == nil or p_Player.soldier == nil then
        return
    end

    local s_CurrentWeapon = p_Player.soldier.weaponsComponent.currentWeapon

    -- Save pre reload ammo
    self.m_ReloadEvents[s_CurrentWeapon.weaponFiring.instanceId] = {
        PlayerId = p_Player.id,
        WeaponInstanceId = s_CurrentWeapon.instanceId,
        Ammo = s_CurrentWeapon.primaryAmmo
    }
end

function PostReloadEvent:OnWeaponFiring(p_WeaponFiring)
    if p_WeaponFiring.weaponState == WeaponState.Reload or
        p_WeaponFiring.weaponState == WeaponState.ReloadDelay or
        self.m_ReloadEvents[p_WeaponFiring.instanceId] == nil then
        return
    end

    -- get current reload data and clear reference
    local s_Data = self.m_ReloadEvents[p_WeaponFiring.instanceId]
    self.m_ReloadEvents[p_WeaponFiring.instanceId] = nil

    -- Event parameters
    local s_Player = PlayerManager:GetPlayerById(s_Data.PlayerId)
    local s_AmmoAdded = s_Player.soldier.weaponsComponent.currentWeapon.primaryAmmo - s_Data.Ammo

    -- fix for shotguns shooting while reloading
    if p_WeaponFiring.weaponState == WeaponState.PrimarySingle then
        s_AmmoAdded = s_AmmoAdded + 1
    end

    -- Dispatch custom post reload event
    if s_AmmoAdded > 0 then
        Events:Dispatch("Player:PostReload", s_Player, s_AmmoAdded)
    end
end

function PostReloadEvent:OnLevelDestroy()
    self:ResetVars()
end

-- don't return
PostReloadEvent()
