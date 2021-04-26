class "GunSwayManager"

function GunSwayManager:__init()

end

-- Fix ADS accurate hipfire glitch
function GunSwayManager:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
    if p_GunSway.dispersionAngle < p_GunSway.minDispersionAngle then
        p_GunSway.dispersionAngle = p_GunSway.minDispersionAngle
    end
end

if g_GunSwayManager == nil then
    g_GunSwayManager = GunSwayManager()
end

return g_GunSwayManager
