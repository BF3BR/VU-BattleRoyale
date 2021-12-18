---@class DeployScreen
DeployScreen = class 'DeployScreen'

---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
local m_Logger = Logger("DeployScreen", true)

---VEXT Client Level:Loaded Event
function DeployScreen:OnLevelLoaded()
	WebUI:ExecuteJS("ToggleDeployMenu(true);")
	m_HudUtils:ShowroomCamera(true)
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:SetIsInDeployScreen(true)
	m_TimerManager:Timeout(7.0, function()
		if m_HudUtils:GetIsInDeployScreen() then
			m_HudUtils:EnableShowroomSoldier(true)
			m_TimerManager:Timeout(1.15, function()
				NetEvents:Send(PlayerEvents.PlayerSetSkin)
			end)
		end
	end)
end

---Opens the DeployScreen and does a bunch of entity related stuff
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

---Closes the DeployScreen and does a bunch of entity related stuff
function DeployScreen:CloseDeployScreen()
	m_HudUtils:SetIsInDeployScreen(false)
	WebUI:ExecuteJS("ToggleDeployMenu(false);")
	m_HudUtils:ShowroomCamera(false)
	m_HudUtils:EnableShowroomSoldier(false)
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
end

return DeployScreen()
