class "WeaponsModifier"

local m_AmmobagFiringData = DC(Guid("0343F80F-06CC-11E0-8BDF-D7443366E28A"), Guid("5B73C5E2-127E-419B-95FB-A69D9F5CAA7B"))
local m_AmmobagResupplyData = DC(Guid("04CD683B-1F1B-11E0-BBD1-F7235575FD24"), Guid("4AE515CE-846D-6070-5F56-1285B7E8E187"))
local m_MedkitFiringData = DC(Guid("B54E9BDA-1F2E-11E0-8602-946E2AD98284"), Guid("F379D6B0-4592-4DC2-9186-5863D3D69C85"))
local m_MedkitHealingData = DC(Guid("1D6061B2-2234-11E0-92F5-C9B649EF6972"), Guid("A867A678-615B-3FA6-7AF5-0DEE6ED69EA0"))
local m_MeleeEntityCommonData = DC(Guid("B6CDC48A-3A8C-11E0-843A-AC0656909BCB"), Guid("F21FB5EA-D7A6-EE7E-DDA2-C776D604CD2E"))

function WeaponsModifier:RegisterCallbacks()
	m_AmmobagFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
	m_AmmobagResupplyData:RegisterLoadHandler(self, self.SetResupplyCapacity)
	m_MedkitFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
	m_MedkitHealingData:RegisterLoadHandler(self, self.SetHealingCapacity)
	m_MeleeEntityCommonData:RegisterLoadHandler(self, self.DisableKnifeTakedownAnimation)
end

function WeaponsModifier:DeregisterCallbacks()
	m_AmmobagFiringData:Deregister()
	m_AmmobagResupplyData:Deregister()
	m_MedkitFiringData:Deregister()
	m_MedkitHealingData:Deregister()
	m_MeleeEntityCommonData:Deregister()
end

-- Disable infinite medkit and ammobag capacity
function WeaponsModifier:DisableAutoReplenish(p_FiringData)
	p_FiringData.ammo.autoReplenishMagazine = false
end

function WeaponsModifier:SetHealingCapacity(p_HealingData)
	p_HealingData.supplyData.healing.infiniteCapacity = false
	p_HealingData.supplyData.healing.supplyPointsCapacity = PickupsConfig.MedkitCapacity
end

function WeaponsModifier:SetResupplyCapacity(p_ResupplyData)
	p_ResupplyData.supplyData.ammo.infiniteCapacity = false
	p_ResupplyData.supplyData.ammo.supplyPointsCapacity = PickupsConfig.AmmobagCapacity
end

-- Disable canned knife takedown animation
function WeaponsModifier:DisableKnifeTakedownAnimation(p_MeleeEntityCommonData)
	p_MeleeEntityCommonData.meleeAttackDistance = 0
	p_MeleeEntityCommonData.maxAttackHeightDifference = 0
end


if g_WeaponsModifier == nil then
	g_WeaponsModifier = WeaponsModifier()
end

return g_WeaponsModifier
