class("RegistryManager")

function RegistryManager:__init()
	self:ResetVars()
end

function RegistryManager:ResetVars()
	self.m_Index = 0x7FFF
	self.m_Registry = nil
end

function RegistryManager:GetIndex()
	self.m_Index = self.m_Index + 1
	return self.m_Index
end

function RegistryManager:GetRegistry()
	return self.m_Registry
end

function RegistryManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	self.m_Registry = RegistryContainer()
end

function RegistryManager:OnRegisterEntityResources(p_LevelData)
	ResourceManager:AddRegistry(self.m_Registry, ResourceCompartment.ResourceCompartment_Game)
	self:ResetVars()
end

if g_RegistryManager == nil then
	g_RegistryManager = RegistryManager()
end

return g_RegistryManager
