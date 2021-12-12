---@class Settings
local Settings = class 'Settings'

function Settings:__init()
	self.m_UserSettings = {}
end

-- =============================================
-- Events
-- =============================================

---VEXT Client Level:Loaded Event
function Settings:OnLevelLoaded()
	self:ApplySettings()
end

---VEXT Shared Extension:Unloading Event
function Settings:OnExtensionUnloading()
	self:ResetSettings()
end

-- =============================================
-- Functions
-- =============================================

---Function to change Settings with ResourcManager
function Settings:ApplySettings()
	for l_SettingsName, l_Settings in pairs(SettingsConfig) do
		local s_TempSettings = ResourceManager:GetSettings(l_SettingsName)
		s_TempSettings = _G[l_SettingsName](s_TempSettings)

		for l_SettingName, l_Setting in pairs(l_Settings) do
			if self.m_UserSettings[l_SettingsName] == nil then
				self.m_UserSettings[l_SettingsName] = {}
			end

			self.m_UserSettings[l_SettingsName][l_SettingName] = s_TempSettings[l_SettingName]
			s_TempSettings[l_SettingName] = l_Setting
		end
	end
end

---Reset all settings to default
function Settings:ResetSettings()
	for l_SettingsName, l_Settings in pairs(self.m_UserSettings) do
		local s_TempSettings = ResourceManager:GetSettings(l_SettingsName)
		s_TempSettings = _G[l_SettingsName](s_TempSettings)

		for l_SettingName, l_Setting in pairs(l_Settings) do
			s_TempSettings[l_SettingName] = l_Setting
		end
	end

	self.m_UserSettings = {}
end

return Settings()
