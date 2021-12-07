class 'DeployScreen'

local m_HudUtils = require "UI/Utils/HudUtils"
local m_Logger = Logger("DeployScreen", true)

function DeployScreen:OnLevelLoaded()
	WebUI:ExecuteJS("ToggleDeployMenu(true);")
	m_HudUtils:ShowroomCamera(true)
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:SetIsInDeployScreen(true)
	g_Timers:Timeout(7.0, function()
		if m_HudUtils:GetIsInDeployScreen() then
			m_HudUtils:EnableShowroomSoldier(true)
			g_Timers:Timeout(1.15, function()
				NetEvents:Send(PlayerEvents.PlayerSetSkin)
			end)
		end
	end)
end

function DeployScreen:OpenDeployScreen()
	if m_HudUtils:GetIsInventoryOpened() then
		m_HudUtils:SetIsInventoryOpened(false)
		WebUI:ExecuteJS("OnInventoryOpen(false);")
	end

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

return DeployScreen()
