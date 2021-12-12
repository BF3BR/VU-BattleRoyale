---@class GameModeSettingsModifier
local GameModeSettingsModifier = class 'GameModeSettingsModifier'

local m_GameModeSettings = DC(Guid("C4DCACFF-ED8F-BC87-F647-0BC8ACE0D9B4"), Guid("AD413546-DEAF-8115-B89C-D666E801C67A"))

local m_Logger = Logger("GameModeSettingsModifier", true)

function GameModeSettingsModifier:RegisterCallbacks()
	m_GameModeSettings:CallOrRegisterLoadHandler(self, self.OnGameModeSettings)
	self:OnGameModeSettings(ResourceManager:GetSettings("GameModeSettings"))
end

function GameModeSettingsModifier:DeregisterCallbacks()
	self:OnGameModeSettings(m_GameModeSettings:GetInstance(), true)
	self:OnGameModeSettings(ResourceManager:GetSettings("GameModeSettings"), true)
	m_GameModeSettings:Deregister()
end

function GameModeSettingsModifier:OnGameModeSettings(p_GameModeSettings, p_Remove)
	if p_GameModeSettings == nil then
		return
	end

	p_GameModeSettings = GameModeSettings(p_GameModeSettings)
	p_GameModeSettings:MakeWritable()

	local s_GameModeTeamSize = GameModeTeamSize()
	s_GameModeTeamSize.playerCount = 127
	s_GameModeTeamSize.squadSize = 4

	if not p_Remove then
		if #p_GameModeSettings.information[1].sizes[3].teams == 127 then
			return
		end

		m_Logger:Write("Adding Teams to GameModeSettings")

		for l_Index = 4, 127 do
			p_GameModeSettings.information[1].sizes[3].teams:add(s_GameModeTeamSize)
		end
	else
		if #p_GameModeSettings.information[1].sizes[3].teams == 3 then
			return
		end

		m_Logger:Write("Removing Teams from GameModeSettings")

		for l_Index = 127, 4, -1 do
			p_GameModeSettings.information[1].sizes[3].teams:erase(l_Index)
		end
	end
end

return GameModeSettingsModifier()
