---@class MapVEManager
MapVEManager = class "MapVEManager"

local m_Logger = Logger("MapVEManager", false)

function MapVEManager:__init()
	self:RegisterVars()
end

function MapVEManager:RegisterVars()
	self:ResetVars()
end

function MapVEManager:SetMapVEPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
	-- If map presets have been loaded already we apply the current preset, otherwise it
	-- will be applied when VEManager registers them.
	if self.m_CurrentMapPresetNames then
		if self.m_CurrentMapPresetNames[p_VEIndex] then
			self:SwitchPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
		else
			m_Logger:Error("Cannot switch preset, incorrect index. This should never happen.")
		end
	end

	self.m_CurrentMapPresetIndex = p_VEIndex
end

function MapVEManager:OnLevelDestroy()
	self:ResetVars()
end

function MapVEManager:ResetVars()
	self.m_CurrentMapPresetNames = nil
	self.m_CurrentMapPresetIndex = 1

	if self.m_RegisteredPresets ~= nil then
		for _, l_VEPresetName in pairs(self.m_RegisteredPresets) do
			self:UnregisterPreset(l_VEPresetName)
		end
	end

	self.m_RegisteredPresets = nil
end

function MapVEManager:OnPresetsLoaded()
	if self.m_CurrentMapPresetNames then
		if self.m_CurrentMapPresetNames[self.m_CurrentMapPresetIndex] then
			self:EnablePreset(self.m_CurrentMapPresetNames[self.m_CurrentMapPresetIndex])
		else
			m_Logger:Error("Cannot switch preset, incorrect index. This should never happen.")
		end
	else
		m_Logger:Warning(string.format("No custom preset loaded! m_CurrentPresetName not defined."))
	end
end

function MapVEManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	local m_Map = MapsConfig[LevelNameHelper:GetLevelName()]

	if m_Map then
		self.m_CurrentMapPresetNames = m_Map.VEPresets
		for _, s_PresetName in pairs(m_Map.VEPresets) do
			local s_PresetPath = self:GetPresetPath(s_PresetName)
			local s_JSONPreset = require(s_PresetPath)

			m_Logger:Write("Registering preset with name: ".. s_PresetName .. " - Path: " .. s_PresetPath)
			self:RegisterPreset(s_PresetName, s_JSONPreset)
		end
	end
end

function MapVEManager:GetPresetPath(p_PresetName)
	return string.format("Visuals/Presets/Maps/%s/%s.lua", LevelNameHelper:GetLevelName(), p_PresetName)
end

function MapVEManager:RegisterPreset(p_PresetName, p_Preset)
	m_Logger:Write(string.format("Dispatching event to register preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:RegisterPreset", p_PresetName, p_Preset)
end

function MapVEManager:UnregisterPreset(p_PresetName)
	m_Logger:Write(string.format("Dispatching event to unregister preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:UnregisterPreset", p_PresetName) -- this doesnt actually exist yet on the VEManager
end

function MapVEManager:FadeInPreset(p_PresetName, p_Time)
	m_Logger:Write(string.format("Dispatching event to fade in preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:FadeIn", p_PresetName, p_Time)
end

function MapVEManager:FadeOutPreset(p_PresetName, p_Time)
	m_Logger:Write(string.format("Dispatching event to fade out preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:FadeOut", p_PresetName, p_Time)
end

function MapVEManager:EnablePreset(p_PresetName)
	m_Logger:Write(string.format("Dispatching event to enable preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:EnablePreset", p_PresetName)
end

function MapVEManager:DisablePreset(p_PresetName)
	m_Logger:Write(string.format("Dispatching event to disable preset \"%s\"", p_PresetName))
	Events:Dispatch("VEManager:DisablePreset", p_PresetName)
end

function MapVEManager:SwitchPreset(p_NewPresetIndex, p_OldFadeTime, p_NewFadeTime) -- this can be invoked by the server later on (admin command - not implemented)
	if not self.m_CurrentMapPresetNames then
		m_Logger:Error("Cannot switch preset, as there were no visual environments defined.")
		return
	end

	if not p_NewPresetIndex then
		m_Logger:Error("Cannot switch preset, preset index invalid.")
		return
	end

	p_OldFadeTime = p_OldFadeTime or 0
	p_NewFadeTime = p_NewFadeTime or 0

	local s_CurrentPresetName = self.m_CurrentMapPresetNames[self.m_CurrentMapPresetIndex]
	local s_NewPresetName = self.m_CurrentMapPresetNames[p_NewPresetIndex]
	if not s_NewPresetName then
		m_Logger:Error("Cannot switch preset, preset name not found in visual environments definition.")
		return
	end

	m_Logger:Write("Switching map VE preset to " .. s_NewPresetName)

	-- Disable old preset
	self:FadeOutPreset(s_CurrentPresetName, p_OldFadeTime * 1000)


	-- Enable new preset
	if p_OldFadeTime == 0 then
		self:FadeInPreset(s_NewPresetName, p_NewFadeTime * 1000)
	end
end

return MapVEManager()
