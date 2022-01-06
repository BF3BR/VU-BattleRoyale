---@class WeaponsModifier
WeaponsModifier = class "WeaponsModifier"

local m_MeleeEntityCommonData = DC(Guid("B6CDC48A-3A8C-11E0-843A-AC0656909BCB"), Guid("F21FB5EA-D7A6-EE7E-DDA2-C776D604CD2E"))

function WeaponsModifier:RegisterCallbacks()
	m_MeleeEntityCommonData:RegisterLoadHandler(self, self.DisableKnifeTakedownAnimation)
end

function WeaponsModifier:DeregisterCallbacks()
	m_MeleeEntityCommonData:Deregister()
end

-- Disable canned knife takedown animation
function WeaponsModifier:DisableKnifeTakedownAnimation(p_MeleeEntityCommonData)
	p_MeleeEntityCommonData.meleeAttackDistance = 0
	p_MeleeEntityCommonData.maxAttackHeightDifference = 0
end

return WeaponsModifier()
