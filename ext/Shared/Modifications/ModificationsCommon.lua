class "ModificationsCommon"


local m_SubWorldModifier = require "__shared/Modifications/SubWorldModifier"
local m_WeaponDropModifier = require "__shared/Modifications/Soldiers/WeaponDropModifier"
--local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier"
local m_GunshipModifier = require "__shared/Modifications/GunshipModifier"
local m_LootsModifier = require "__shared/Modifications/LootsModifier"

local m_SubWorldName = "Levels/XP5_003/CQL"

function ModificationsCommon:__init()
	self:ResetVars()
end

function ModificationsCommon:ResetVars()
	self.m_MapName = ""
	self.m_GameModeName = ""
	self.m_IsLevelDataPatched = false
	self.m_Index = 30000
    self.m_Registry = nil
end

function ModificationsCommon:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
    self:ResetVars()
	self.m_MapName = p_MapName
	self.m_GameModeName = p_GameModeName
    -- Route same registry in all events
    self.m_Registry = RegistryContainer()
end

function ModificationsCommon:GetIndex()
	self.m_Index = self.m_Index + 1
	return self.m_Index
end

function ModificationsCommon:OnPartitionLoaded(p_Partition)
	if self.m_IsLevelDataPatched then
		--m_WeaponDropModifier:OnPartitionLoaded(p_Partition, self.m_Registry)
        --m_ManDownModifier:OnPartitionLoaded(p_Partition, self.m_Registry)
	else
		self:OnPartitionLoadedInternal(p_Partition)
	end
end

function ModificationsCommon:OnSubWorldLoaded(p_SubWorldData)
    print("[ModificationsCommon] SubWorld loaded: "..p_SubWorldData.name)
	-- Clear the existing subworld (flags, vehicles, teams...)
	p_SubWorldData:MakeWritable()
	p_SubWorldData.objects:clear()
	p_SubWorldData.eventConnections:clear()
	p_SubWorldData.propertyConnections:clear()
	p_SubWorldData.linkConnections:clear()

	local s_Registry = RegistryContainer()

	-- Create basic subworld
    m_SubWorldModifier:OnSubWorldLoaded(p_SubWorldData, self)
    -- Add dropship spawn
    m_GunshipModifier:OnSubWorldLoaded(p_SubWorldData, self)
    -- Add loot spawns
    m_LootsModifier:OnSubWorldLoaded(p_SubWorldData, self)

	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

function ModificationsCommon:OnRegisterEntityResources(p_LevelData)
	-- Add the registry
	ResourceManager:AddRegistry(self.m_Registry, ResourceCompartment.ResourceCompartment_Game)
	self.m_Registry = nil
end

function ModificationsCommon:OnPartitionLoadedInternal(p_Partition)
    -- Patch the levelData to load XP5_003 gamemode
    if p_Partition.primaryInstance:Is('LevelData') then
        local s_LevelData = LevelData(p_Partition.primaryInstance)
        
        -- Check if the LevelData is from this level (not from injected bundles)
        if s_LevelData.name == self.m_MapName then
            self:OnLevelDataLoaded(s_LevelData)
        end

        return
    end
    -- Patch the XP5_003 gamemode.
    if p_Partition.primaryInstance:Is('SubWorldData') then
        local s_SubWorldData = SubWorldData(p_Partition.primaryInstance)

        -- Check if this SubWorldData is the one we forced to load
        if s_SubWorldData.name == m_SubWorldName then
            self:OnSubWorldLoaded(s_SubWorldData)
        end
    end
end

function ModificationsCommon:OnLevelDataLoaded(p_LevelData)
    print("[ModificationsCommon] LevelData loaded: "..p_LevelData.name)
    -- Iterate gamemode ReferenceObjectDatas
    for _, l_object in ipairs(p_LevelData.objects) do
		if l_object:Is('SubWorldReferenceObjectData') then
			local s_SubWorldReferenceObjectData = SubWorldReferenceObjectData(l_object)

            -- Change the SubWorldReferenceObjectData to load XP5_003
            if self:_IsCurrentSubWorld(s_SubWorldReferenceObjectData) then
				s_SubWorldReferenceObjectData:MakeWritable()
				s_SubWorldReferenceObjectData.bundleName = m_SubWorldName
				return
			end
		end
	end 
end

function ModificationsCommon:_IsCurrentSubWorld(p_SubWorldReferenceObjectData)
	if p_SubWorldReferenceObjectData.inclusionSettings ~= nil then
		local s_InclusionSettings = SubWorldInclusionSettings(p_SubWorldReferenceObjectData.inclusionSettings)

		if #s_InclusionSettings.settings ~= 0 then
			local s_Setting = SubWorldInclusionSetting(s_InclusionSettings.settings[1])

			for _, l_option in ipairs(s_Setting.enabledOptions) do
				if l_option == self.m_GameModeName then
					return true
				end
			end

			return false
		end
	end
end

if g_ModificationsCommon == nil then
	g_ModificationsCommon = ModificationsCommon()
end

return g_ModificationsCommon