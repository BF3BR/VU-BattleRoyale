class 'Settings'

function Settings:__init()
	self.m_UserSettings = {}
end

-- =============================================
-- Events
-- =============================================

function Settings:OnLevelLoaded()
	self:ApplySettings()
end

function Settings:OnExtensionUnloading()
	self:ResetSettings()
end

-- =============================================
-- Functions
-- =============================================

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

if g_Settings == nil then
	g_Settings = Settings()
end

return g_Settings
