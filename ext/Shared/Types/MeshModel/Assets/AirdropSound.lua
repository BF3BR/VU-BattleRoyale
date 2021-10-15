class("AirdropSound")

local m_Airdrop_Object_SFX = DC(Guid("CE2EF674-9C22-11E0-9F7B-CD3BC4364C43"), Guid("EBF2202A-9716-2A81-EA34-464432189CD0"))

function AirdropSound:Draw(p_Transform)
	local s_Data = EntityManager:CreateEntitiesFromBlueprint(
		m_Airdrop_Object_SFX:GetInstance(),
		p_Transform
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

return AirdropSound()
