---@class GunSwayManager
GunSwayManager = class "GunSwayManager"

-- Fix ADS accurate hipfire glitch.
---VEXT Shared GunSway:Update Event
---@param p_GunSway GunSway
---@param p_Weapon Entity|nil
---@param p_WeaponFiring WeaponFiring|nil
---@param p_DeltaTime number
function GunSwayManager:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	if p_GunSway.dispersionAngle < p_GunSway.minDispersionAngle then
		p_GunSway.dispersionAngle = p_GunSway.minDispersionAngle
	end
end

return GunSwayManager()
