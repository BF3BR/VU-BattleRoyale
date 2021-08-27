class 'DeployScreen'

local m_HudUtils = require "UI/Utils/HudUtils"
local m_Logger = Logger("DeployScreen", true)

function DeployScreen:OnLevelLoaded()
	WebUI:ExecuteJS("ToggleDeployMenu(true);")
	m_HudUtils:ShowroomCamera(true)
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:SetIsInDeployScreen(true)
	g_Timers:Timeout(2, function() m_HudUtils:EnableShowroomSoldier(true) end)
end

function DeployScreen:OpenDeployScreen()
	WebUI:ExecuteJS("ToggleDeployMenu(true);")
	m_HudUtils:ShowroomCamera(true)
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:OnEnableMouse()
	m_HudUtils:EnableShowroomSoldier(true)
	m_HudUtils:SetIsInDeployScreen(true)
end

function DeployScreen:CloseDeployScreen()
	m_HudUtils:SetIsInDeployScreen(false)
	WebUI:ExecuteJS("ToggleDeployMenu(false);")
	m_HudUtils:ShowroomCamera(false)
	m_HudUtils:EnableShowroomSoldier(false)
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
end

if g_DeployScreen == nil then
	g_DeployScreen = DeployScreen()
end

return g_DeployScreen
