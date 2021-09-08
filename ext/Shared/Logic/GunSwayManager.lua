class "GunSwayManager"

-- Fix ADS accurate hipfire glitch
function GunSwayManager:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	if p_GunSway.dispersionAngle < p_GunSway.minDispersionAngle then
		p_GunSway.dispersionAngle = p_GunSway.minDispersionAngle
	end
end

return GunSwayManager()
