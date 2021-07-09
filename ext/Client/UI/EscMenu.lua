class 'EscMenu'

local m_HudUtils = require "Utils/HudUtils"
local m_Logger = Logger("EscMenu", true)

function EscMenu:__init()
	self.m_HudOnSetUIState = CachedJsExecutor("OnSetUIState('%s')", UiStates.Loading)
end

-- =============================================
-- Event
-- =============================================

function EscMenu:OnClientUpdateInput()
	if m_HudUtils:GetIsInOptionsMenu() then
		return
	elseif m_HudUtils:GetIsInEscMenu() then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_Escape) then
			WebUI:ExecuteJS("OnMenuEsc()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowUp)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_W) then
			WebUI:ExecuteJS("OnMenuArrowUp()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowDown)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_S) then
			WebUI:ExecuteJS("OnMenuArrowDown()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowRight)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_D) then
			WebUI:ExecuteJS("OnMenuArrowRight()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowLeft)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_A) then
			WebUI:ExecuteJS("OnMenuArrowLeft()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_Enter)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_NumpadEnter)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_Space) then
			WebUI:ExecuteJS("OnMenuEnter()")
		end
	elseif m_HudUtils:GetIsInDeployScreen() then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_Escape) then
			self:OnOpenEscapeMenu()
		end
	end
end

function EscMenu:OnWebUITriggerMenuFunction(p_Function)
	if p_Function == "resume" then
		self:OnResume()
	elseif p_Function == "team" then
		m_Logger:Write("INFO: Team / Squad is missing.")
	elseif p_Function == "inventory" then
		m_Logger:Write("INFO: Inventory is missing.")
	elseif p_Function == "options" then
		self:OnOptions()
	elseif p_Function == "quit" then
		self:OnQuit()
	end
end

-- =============================================
	-- Esc Menu Callbacks
-- =============================================

function EscMenu:RegisterEscMenuCallbacks()
	local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("B9437F95-2EBC-4F22-A5F6-F4D0F1331A5E") then
			-- Registering the EventCallback on modreload => crash on first call
			s_Entity:RegisterEventCallback(self, self.OnEscapeMenuCallback)
		end

		s_Entity = s_EntityIterator:Next()
	end
end

function EscMenu:OnEscapeMenuCallback(p_Entity, p_EntityEvent)
	if p_EntityEvent.eventId == MathUtils:FNVHash("EnterFromGame") then
		self:OnOpenEscapeMenu()
		return false
	elseif p_EntityEvent.eventId == MathUtils:FNVHash("ExitUIGraph") then
		self:OnResume()
	end
end


-- =============================================
	-- Open Escape Menu
-- =============================================

function EscMenu:OnOpenEscapeMenu()
	m_HudUtils:SetIsInOptionsMenu(false)
	m_HudUtils:OnEnableMouse()
	m_HudUtils:OnDisableGameInput()
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:EnableBlurEffect(true)
	m_HudUtils:SetIsInEscMenu(true)
	self.m_HudOnSetUIState:Update(UiStates.Menu)
end


-- =============================================
	-- Close Escape Menu
-- =============================================

function EscMenu:OnResume()
	m_HudUtils:SetIsInEscMenu(false)
	m_HudUtils:DisableMenuVisualEnv()
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
	m_HudUtils:EnableTabScoreboard()
	m_HudUtils:EnableBlurEffect(false)
	m_HudUtils:StartupChat()
	self.m_HudOnSetUIState:Update(UiStates.Game)
end

-- =============================================
	-- Open Options
-- =============================================

function EscMenu:OnOptions()
	m_HudUtils:SetIsInOptionsMenu(true)
	self.m_HudOnSetUIState:Update(UiStates.Hidden)
	local s_UIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	local s_UIGraphEntity = s_UIGraphEntityIterator:Next()

	while s_UIGraphEntity do
		if s_UIGraphEntity.data.instanceGuid == Guid("EDF20470-4AD7-44BC-96E1-9DF61989BE58") then
			s_UIGraphEntity = Entity(s_UIGraphEntity)
			s_UIGraphEntity:FireEvent("EnterOptions")
			return
		end

		s_UIGraphEntity = s_UIGraphEntityIterator:Next()
	end
end

-- =============================================
	-- Quit the game
-- =============================================

function EscMenu:OnQuit()
	local s_Data = self:GetQuitEntityData()
	local s_QuitPopupGraphEntity = EntityManager:CreateEntity(s_Data, LinearTransform())
	s_QuitPopupGraphEntity:FireEvent('Quit')
end

function EscMenu:GetQuitEntityData()
	local s_QuitPopupGraphAsset = UIGraphAsset()
	s_QuitPopupGraphAsset.modal = false
	s_QuitPopupGraphAsset.protectScreens = true
	s_QuitPopupGraphAsset.isWin32UIGraphAsset = true
	s_QuitPopupGraphAsset.isXenonUIGraphAsset = true
	s_QuitPopupGraphAsset.isPs3UIGraphAsset = true

	local s_InputNode = InstanceInputNode()
	s_InputNode.parentGraph = s_QuitPopupGraphAsset
	s_InputNode.name = 'Quit'
	s_InputNode.isRootNode = false
	s_InputNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_InputNode)

	local s_ActionNode = ActionNode()
	s_ActionNode.actionKey = MathUtils:FNVHash("QuitGame")
	s_ActionNode.inValue = UINodePort()
	s_ActionNode.out = UINodePort()
	s_ActionNode.appendIncomingParams = false
	s_ActionNode.name = 'Quit'
	s_ActionNode.isRootNode = false
	s_ActionNode.parentGraph = s_QuitPopupGraphAsset
	s_ActionNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_ActionNode)

	local s_InputToDialogNodeConnection = UINodeConnection()
	s_InputToDialogNodeConnection.sourceNode = s_InputNode
	s_InputToDialogNodeConnection.targetNode = s_ActionNode
	s_InputToDialogNodeConnection.sourcePort = s_InputNode.out
	s_InputToDialogNodeConnection.targetPort = s_ActionNode.inValue
	s_InputToDialogNodeConnection.numScreensToPop = 0
	s_QuitPopupGraphAsset.connections:add(s_InputToDialogNodeConnection)

	local s_OutputNode = InstanceOutputNode()
	s_OutputNode.inValue = UINodePort()
	s_OutputNode.id = MathUtils:FNVHash("QuitOrSuicide")
	s_OutputNode.destroyGraph = true
	s_OutputNode.name = "QuitOrSuicide"
	s_OutputNode.isRootNode = false
	s_OutputNode.parentGraph = s_QuitPopupGraphAsset
	s_OutputNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_OutputNode)

	local s_ActionToOutputNodeConnection = UINodeConnection()
	s_ActionToOutputNodeConnection.sourceNode = s_ActionNode
	s_ActionToOutputNodeConnection.targetNode = s_OutputNode
	s_ActionToOutputNodeConnection.sourcePort = s_ActionNode.out
	s_ActionToOutputNodeConnection.targetPort = s_OutputNode.inValue
	s_ActionToOutputNodeConnection.numScreensToPop = 1
	s_QuitPopupGraphAsset.connections:add(s_ActionToOutputNodeConnection)

	local s_QuitPopupGraphEntityData = UIGraphEntityData()
	s_QuitPopupGraphEntityData.graphAsset = s_QuitPopupGraphAsset
	s_QuitPopupGraphEntityData.popPreviousGraph = false

	return s_QuitPopupGraphEntityData
end

if g_EscMenu == nil then
	g_EscMenu = EscMenu()
end

return g_EscMenu
