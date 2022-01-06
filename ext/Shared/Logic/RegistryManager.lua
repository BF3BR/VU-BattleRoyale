---@class RegistryManager
RegistryManager = class("RegistryManager")

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

---VEXT Shared Level:LoadResources Event
---@param p_LevelName string
---@param p_GameMode string
---@param p_IsDedicatedServer boolean
function RegistryManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	self.m_Registry = RegistryContainer()
end

---VEXT Shared Level:RegisterEntityResources Event
---@param p_LevelData DataContainer
function RegistryManager:OnRegisterEntityResources(p_LevelData)
	ResourceManager:AddRegistry(self.m_Registry, ResourceCompartment.ResourceCompartment_Game)
	self:ResetVars()
end

return RegistryManager()
