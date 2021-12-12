---@class DisableDebugRenderer
local DisableDebugRenderer = class 'DisableDebugRenderer'

local m_Logger = Logger("DisableDebugRenderer", true)

function DisableDebugRenderer:OnExtensionLoaded()
	local s_DebugRenderSettings = ResourceManager:GetSettings('DebugRenderSettings')

	if s_DebugRenderSettings == nil or ServerConfig.Debug.EnableLootPointSpheres
	or ServerConfig.Debug.EnableDebugRenderer then
		m_Logger:Write("Didn\'t disable DebugRenderer")
		return
	end

	s_DebugRenderSettings = DebugRenderSettings(s_DebugRenderSettings)
	s_DebugRenderSettings.enable = false
end

function DisableDebugRenderer:OnExtensionUnloading()
	local s_DebugRenderSettings = ResourceManager:GetSettings('DebugRenderSettings')

	if s_DebugRenderSettings == nil then
		m_Logger:Write("Couldn\'t find DebugRenderSettings")
		return
	end

	s_DebugRenderSettings = DebugRenderSettings(s_DebugRenderSettings)
	s_DebugRenderSettings.enable = true
end

return DisableDebugRenderer()
