---@class PickupLight
PickupLight = class("PickupLight")

local m_Colors = {
	[Tier.Tier1] = Vec3(1.0, 0.9, 0.9),
	[Tier.Tier2] = Vec3(0.039, 0.702, 1),
	[Tier.Tier3] = Vec3(1, 0.6, 0),
}

function PickupLight:Draw(p_Transform, p_Tier)
	local s_Color = Vec3(1.0, 0.9, 0.9)

	if p_Tier ~= nil then
		s_Color = m_Colors[p_Tier]
	end

	local s_Data = PointLightEntityData()
	s_Data.transform = LinearTransform(
		Vec3(1, 0, 0),
		Vec3(0, 1, 0),
		Vec3(0, 0, 1),
		Vec3(0, 0.35, 0)
	)
	s_Data.color = s_Color
	s_Data.radius = 2.65
	s_Data.width = 0.5
	s_Data.intensity = 7
	s_Data.visible = true
	s_Data.enlightenEnable = false

	local s_Entity = EntityManager:CreateEntity(s_Data, p_Transform)

	if s_Entity ~= nil then
		s_Entity:Init(Realm.Realm_Client, true)
		return s_Entity
	end

	return nil
end

return PickupLight()
