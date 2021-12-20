---@class AirdropSmoke
AirdropSmoke = class("AirdropSmoke")

---@type DC
local m_Airdrop_Object_FX_Smoke = DC(Guid("25B9AFF0-6622-11DE-9DCF-A96EA7FB2539"), Guid("EB9BAF48-75CA-3413-DE82-0CF9EC98603F"))

---@param p_Transform LinearTransform
---@return table<integer, Entity>|nil
function AirdropSmoke:Draw(p_Transform)
	local s_Data = EntityManager:CreateEntitiesFromBlueprint(
		m_Airdrop_Object_FX_Smoke:GetInstance(),
		LinearTransform(
			p_Transform.left,
			p_Transform.up,
			p_Transform.forward,
			Vec3(
				p_Transform.trans.x,
				p_Transform.trans.y + 1.35,
				p_Transform.trans.z
			)
		)
	)

	if s_Data ~= nil then
		local s_Entities = {}

		for _, l_Entity in pairs(s_Data.entities) do
			l_Entity:Init(Realm.Realm_Client, false)
			l_Entity:FireEvent("Start")
			s_Entities[l_Entity.instanceId] = l_Entity
		end

		return s_Entities
	end

	return nil
end

return AirdropSmoke()
