class "OOCVision"

local m_Logger = Logger("OOCVision", false)

local m_OutOfCirclePreset = require "Visuals/Presets/Common/OutOfCirclePreset"
local m_OutOfCirclePresetName = "OutOfCircle"

function OOCVision:__init()
	m_Logger:Write("OOCVision init.")
end

function OOCVision:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_Logger:Write("Dispatching event to load preset " .. m_OutOfCirclePresetName .. "!")
	Events:Dispatch("VEManager:RegisterPreset", m_OutOfCirclePresetName, m_OutOfCirclePreset)
end

function OOCVision:Enable()
	if self.m_IsEnabled then
		return
	end

	Events:Dispatch("VEManager:FadeIn", m_OutOfCirclePresetName, 400)
	self.m_IsEnabled = true
end

function OOCVision:Disable()
	if not self.m_IsEnabled then
		self.m_IsEnabled = false
		return
	end

	Events:Dispatch("VEManager:FadeOut", m_OutOfCirclePresetName, 400)
	self.m_IsEnabled = false
end

if g_OOCVision == nil then
    g_OOCVision = OOCVision()
end

return g_OOCVision
