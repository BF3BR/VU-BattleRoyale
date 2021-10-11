class("MeshModelPrefab")

function MeshModelPrefab:__init(p_Items)
    self.m_Items = p_Items
end

-- Item = { MeshModel, LinearTransform }
function MeshModelPrefab:Draw(p_Transform)
    local s_Entities = {}

    for _, l_Item in ipairs(self.m_Items) do
        local s_WorldTransform = l_Item[2] * p_Transform
        
        local s_Entity = l_Item[1]:Draw(s_WorldTransform)

        if s_Entity ~= nil then
            s_Entities[s_Entity.instanceId] = s_Entity
        end
    end

    return s_Entities
end
