class "DC"

function DC:__init(p_PartitionGuid, p_InstanceGuid)
	if p_PartitionGuid == nil or p_InstanceGuid == nil then
		error("Invalid guids specified")
	end
	self.m_PartitionGuid = p_PartitionGuid
	self.m_InstanceGuid = p_InstanceGuid
end

function DC:GetInstance()
	local s_Instance = ResourceManager:FindInstanceByGuid(self.m_PartitionGuid, self.m_InstanceGuid)
	return (s_Instance == nil) and s_Instance or _G[s_Instance.typeInfo.name](s_Instance)
end

function DC:CallOrRegisterLoadHandler(p_Userdata, p_Callback)
	local s_Instance = self:GetInstance()
	if s_Instance ~= nil then
		if p_Callback == nil then
			p_Userdata(s_Instance)
		else
			p_Callback(p_Userdata, p_Callback)
		end
	else
		self:RegisterLoadHandlerOnce(p_Userdata, p_Callback)
	end
end

function DC:RegisterLoadHandler(p_Userdata, p_Callback)
	self:_RegisterLoadHandlerInternal(false, p_Userdata, p_Callback)
end

function DC:RegisterLoadHandlerOnce(p_Userdata, p_Callback)
	self:_RegisterLoadHandlerInternal(true, p_Userdata, p_Callback)
end

function DC:_RegisterLoadHandlerInternal(p_Once, p_Userdata, p_Callback)
	local s_Args

	if p_Callback == nil then
		s_Args = { function(p_Instance) p_Userdata(self:_CastedAndWritable(p_Instance)) end }
	else
		s_Args = { p_Userdata, function(p_Userdata, p_Instance) p_Callback(p_Userdata, self:_CastedAndWritable(p_Instance)) end }
	end

	if p_Once then
		ResourceManager:RegisterInstanceLoadHandlerOnce(self.m_PartitionGuid, self.m_InstanceGuid, table.unpack(s_Args))
	else
		ResourceManager:RegisterInstanceLoadHandler(self.m_PartitionGuid, self.m_InstanceGuid, table.unpack(s_Args))
	end
end

function DC:_CastedAndWritable(p_Instance)
	p_Instance = _G[p_Instance.typeInfo.name](p_Instance)
	p_Instance:MakeWritable()
	return p_Instance
end

function DC.static:WaitForInstances(p_Instances, p_Userdata, p_Callback)
	local s_Instances = {}

	for l_Index, l_DC in ipairs(p_Instances) do
		ResourceManager:RegisterInstanceLoadHandlerOnce(l_DC.m_PartitionGuid, l_DC.m_InstanceGuid, function(p_Instance)
			s_Instances[l_Index] = p_Instance

			for i = 1, #p_Instances do
				s_Instances[i] = s_Instances[i] or ResourceManager:FindInstanceByGuid(p_Instances[i].m_PartitionGuid, p_Instances[i].m_InstanceGuid)

				if s_Instances[i] == nil then
					return
				end
			end

			if p_Callback == nil then
				p_Userdata(table.unpack(s_Instances))
			else
				p_Callback(p_Userdata, table.unpack(s_Instances))
			end
		end)
	end
end

return DC
