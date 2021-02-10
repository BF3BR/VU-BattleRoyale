class "ResourceHelper"


function ResourceHelper:WaitForInstances(p_Guids, p_Handler)
    local s_Instances = {}
    -- Register a load handler for each instance
    for l_Index, l_Guids in ipairs(p_Guids) do
        -- Each time an instance loads, check if the others have loaded.
        ResourceManager:RegisterInstanceLoadHandlerOnce(l_Guids.partitionGuid, l_Guids.instanceGuid, function(p_Instance)
            s_Instances[l_Index] = p_Instance
            for i = 1, #p_Guids do
                -- If an instance hasn't loaded, check if it already was loaded
                s_Instances[i] = s_Instances[i] or ResourceManager:FindInstanceByGuid(p_Guids[i].partitionGuid, p_Guids[i].instanceGuid)
                if s_Instances[i] == nil then 
                    return
                end
            end
            p_Handler(table.unpack(s_Instances))
        end)
    end
end
