---@class HudUtils
HudUtils = class "HudUtils"

---@type Logger
local m_Logger = Logger("HudUtils", false)

---@type ConnectionHelper
local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"

function HudUtils:__init()
	self:RegisterVars()
end

function HudUtils:RegisterVars()
	self.m_DisabledFreecamMovement = false
	self.m_IsInEscMenu = false
	self.m_IsInOptionsMenu = false
	self.m_IsMapOpened = false
	self.m_IsInDeployScreen = false
	self.m_IsInInventory = false
	self.m_EnableMouseInstanceId = nil
	self.m_DisableGameInputInstanceId = nil
	self.m_BlurInstanceId = nil
	self.m_ShowSoldierInstanceId = nil
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function HudUtils:OnExtensionUnloading()
	self:DestroyEntities()
	self:RegisterVars()
end

---VEXT Shared Level:Destroy Event
function HudUtils:OnLevelDestroy()
	self:DestroyEntities()
	self:RegisterVars()
end

-- =============================================
-- Functions
-- =============================================

---@param p_Enable boolean
function HudUtils:SetDisabledFreecamMovement(p_Enable)
	self.m_DisabledFreecamMovement = p_Enable
end

---@return boolean
function HudUtils:GetDisabledFreecamMovement()
	return self.m_DisabledFreecamMovement
end

---@param p_Enable boolean
function HudUtils:SetIsInEscMenu(p_Enable)
	self.m_IsInEscMenu = p_Enable
end

---@return boolean
function HudUtils:GetIsInEscMenu()
	return self.m_IsInEscMenu
end

---@param p_Enable boolean
function HudUtils:SetIsInOptionsMenu(p_Enable)
	self.m_IsInOptionsMenu = p_Enable
end

---@return boolean
function HudUtils:GetIsInOptionsMenu()
	return self.m_IsInOptionsMenu
end

---@param p_Enable boolean
function HudUtils:SetIsMapOpened(p_Enable)
	self.m_IsMapOpened = p_Enable
end

---@return boolean
function HudUtils:GetIsMapOpened()
	return self.m_IsMapOpened
end

---@param p_Enable boolean
function HudUtils:SetIsInDeployScreen(p_Enable)
	self.m_IsInDeployScreen = p_Enable
end

---@return boolean
function HudUtils:GetIsInDeployScreen()
	return self.m_IsInDeployScreen
end

---@param p_Enable boolean
function HudUtils:SetIsInventoryOpened(p_Enable)
	self.m_IsInInventory = p_Enable
end

---@return boolean
function HudUtils:GetIsInventoryOpened()
	return self.m_IsInInventory
end

---Show/ Hide crosshair
---@param p_Enable boolean
function HudUtils:ShowCrosshair(p_Enable)
	if SpectatorManager:GetSpectating() then
		return
	end

	local s_UIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	local s_UIGraphEntity = s_UIGraphEntityIterator:Next()

	while s_UIGraphEntity do
		if s_UIGraphEntity.data.instanceGuid == Guid('9F8D5FCA-9B2A-484F-A085-AFF309DC5B7A') then
			s_UIGraphEntity = Entity(s_UIGraphEntity)

			if p_Enable then
				s_UIGraphEntity:FireEvent('ShowCrosshair')
			else
				s_UIGraphEntity:FireEvent('HideCrosshair')
			end

			return
		end

		s_UIGraphEntity = s_UIGraphEntityIterator:Next()
	end
end

---ShowroomCamera (only in DeployScreen)
---@param p_Enable boolean
function HudUtils:ShowroomCamera(p_Enable)
	local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
	local s_CameraEntity = s_CameraEntityIterator:Next()

	while s_CameraEntity do
		if s_CameraEntity.data.instanceGuid == Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19") then
			s_CameraEntity = Entity(s_CameraEntity)

			if p_Enable then
				s_CameraEntity:FireEvent("TakeControl")
			else
				s_CameraEntity:FireEvent("ReleaseControl")
				WebUI:ResetKeyboard()
			end

			return
		end

		s_CameraEntity = s_CameraEntityIterator:Next()
	end
end

---When resuming
function HudUtils:DisableMenuVisualEnv()
	local s_Iterator = EntityManager:GetIterator("LogicVisualEnvironmentEntity")
	local s_Entity = s_Iterator:Next()

	while s_Entity do
		if s_Entity.data.instanceGuid == Guid("A17FCE78-E904-4833-98F8-50BE77EFCC41") then
			s_Entity = Entity(s_Entity)
			s_Entity:FireEvent("Disable")
			return
		end

		s_Entity = s_Iterator:Next()
	end
end

---When resuming
function HudUtils:ExitSoundState()
	if self.m_IsInEscMenu or self.m_IsInDeployScreen then
		return
	end

	local s_SoundStateEntityIterator = EntityManager:GetIterator("SoundStateEntity")
	local s_SoundStateEntity = s_SoundStateEntityIterator:Next()

	while s_SoundStateEntity do
		if s_SoundStateEntity.data.instanceGuid == Guid("AC7A757C-D9FA-4693-97E7-7A5C50EF29C7") then
			s_SoundStateEntity = Entity(s_SoundStateEntity)
			s_SoundStateEntity:FireEvent("Exit")
			return
		end

		s_SoundStateEntity = s_SoundStateEntityIterator:Next()
	end
end

---When resuming
function HudUtils:HUDEnterUIGraph()
	if self.m_IsInEscMenu or self.m_IsInDeployScreen then
		return
	end

	local s_UIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	local s_UIGraphEntity = s_UIGraphEntityIterator:Next()

	while s_UIGraphEntity do
		if s_UIGraphEntity.data.instanceGuid == Guid("133D3825-5F17-4210-A4DB-3694FDBAD26D") then
			s_UIGraphEntity = Entity(s_UIGraphEntity)
			s_UIGraphEntity:FireEvent("EnterUIGraph")
			break
		end

		s_UIGraphEntity = s_UIGraphEntityIterator:Next()
	end

	if self.m_DisabledFreecamMovement then
		self:OnDisableGameInput()
	end

	if self.m_IsMapOpened then
		self:OnEnableMouse()
	end
end

---When resuming
function HudUtils:EnableTabScoreboard()
	local s_UIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	local s_UIGraphEntity = s_UIGraphEntityIterator:Next()

	while s_UIGraphEntity do
		if s_UIGraphEntity.data.instanceGuid == Guid('BD1ED7AE-31AE-495C-9133-DC25ACA30CE4') then
			s_UIGraphEntity = Entity(s_UIGraphEntity)
			s_UIGraphEntity:FireEvent('Startup and hide')
			return
		end

		s_UIGraphEntity = s_UIGraphEntityIterator:Next()
	end
end

---When resuming
function HudUtils:StartupChat()
	local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("7DE28082-B1A7-4C7A-8C6D-8FFB9049F91E") then
			s_Entity:FireEvent("Startup")
		end

		s_Entity = s_EntityIterator:Next()
	end
end

-- =============================================
-- Mouse
-- =============================================

---When going into a menu
function HudUtils:OnEnableMouse()
	if self.m_EnableMouseInstanceId == nil then
		local s_DataMouse = self:GetEnableMouseEntityData()
		local s_EnableMouseGraphEntity = EntityManager:CreateEntity(s_DataMouse, LinearTransform())

		if s_EnableMouseGraphEntity == nil then
			m_Logger:Warning("Failed to create EnableMouseGraphEntity. Enabling mouse with WebUI instead.")
			WebUI:EnableMouse()
			return
		end

		s_EnableMouseGraphEntity:FireEvent('EnableMouseInput')
		self.m_EnableMouseInstanceId = s_EnableMouseGraphEntity.instanceId
	else
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_EnableMouseInstanceId == s_Entity.instanceId then
				s_Entity:FireEvent("EnableMouseInput")
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end
end

---Creates an UIGraphEntityData that is needed to create the Entity
---@return UIGraphEntityData
function HudUtils:GetEnableMouseEntityData()
	local s_MousePopupGraphAsset = UIGraphAsset()
	s_MousePopupGraphAsset.modal = false
	s_MousePopupGraphAsset.protectScreens = true
	s_MousePopupGraphAsset.isWin32UIGraphAsset = true
	s_MousePopupGraphAsset.isXenonUIGraphAsset = true
	s_MousePopupGraphAsset.isPs3UIGraphAsset = true

	local s_InputNode = InstanceInputNode()
	s_InputNode.parentGraph = s_MousePopupGraphAsset
	s_InputNode.name = 'EnableMouseInput'
	s_InputNode.isRootNode = false
	s_InputNode.parentIsScreen = false
	s_MousePopupGraphAsset.nodes:add(s_InputNode)

	local s_ActionNode = ActionNode()
	s_ActionNode.actionKey = MathUtils:FNVHash("MouseInput")
	s_ActionNode.inValue = UINodePort()
	s_ActionNode.out = UINodePort()
	s_ActionNode.appendIncomingParams = false
	s_ActionNode.name = 'EnableMouseInput'
	s_ActionNode.params:add("True")
	s_ActionNode.isRootNode = false
	s_ActionNode.parentGraph = s_MousePopupGraphAsset
	s_ActionNode.parentIsScreen = false
	s_MousePopupGraphAsset.nodes:add(s_ActionNode)

	local s_InputToDialogNodeConnection = UINodeConnection()
	s_InputToDialogNodeConnection.sourceNode = s_InputNode
	s_InputToDialogNodeConnection.targetNode = s_ActionNode
	s_InputToDialogNodeConnection.sourcePort = s_InputNode.out
	s_InputToDialogNodeConnection.targetPort = s_ActionNode.inValue
	s_InputToDialogNodeConnection.numScreensToPop = 0
	s_MousePopupGraphAsset.connections:add(s_InputToDialogNodeConnection)

	local s_OutputNode = InstanceOutputNode()
	s_OutputNode.inValue = UINodePort()
	s_OutputNode.id = MathUtils:FNVHash("exitIngameMenuMP")
	s_OutputNode.destroyGraph = true
	s_OutputNode.name = "exitIngameMenuMP"
	s_OutputNode.isRootNode = false
	s_OutputNode.parentGraph = s_MousePopupGraphAsset
	s_OutputNode.parentIsScreen = false
	s_MousePopupGraphAsset.nodes:add(s_OutputNode)

	local s_ActionToOutputNodeConnection = UINodeConnection()
	s_ActionToOutputNodeConnection.sourceNode = s_ActionNode
	s_ActionToOutputNodeConnection.targetNode = s_OutputNode
	s_ActionToOutputNodeConnection.sourcePort = s_ActionNode.out
	s_ActionToOutputNodeConnection.targetPort = s_OutputNode.inValue
	s_ActionToOutputNodeConnection.numScreensToPop = 1
	s_MousePopupGraphAsset.connections:add(s_ActionToOutputNodeConnection)

	local s_MousePopupGraphEntityData = UIGraphEntityData()
	s_MousePopupGraphEntityData.graphAsset = s_MousePopupGraphAsset
	s_MousePopupGraphEntityData.popPreviousGraph = false

	return s_MousePopupGraphEntityData
end

-- =============================================
-- GameInput
-- =============================================

---When going into a menu
function HudUtils:OnDisableGameInput()
	if self.m_DisableGameInputInstanceId == nil then
		local s_DataGameInput = self:GetDisableGameInputEntityData()
		local s_DisableGameInputGraphEntity = EntityManager:CreateEntity(s_DataGameInput, LinearTransform())

		if s_DisableGameInputGraphEntity == nil then
			m_Logger:Warning("Failed to create Entity to disable GameInput.")
			return
		end

		s_DisableGameInputGraphEntity:FireEvent('DisableGameInput')
		self.m_DisableGameInputInstanceId = s_DisableGameInputGraphEntity.instanceId
	else
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_DisableGameInputInstanceId == s_Entity.instanceId then
				s_Entity:FireEvent("DisableGameInput")
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end
end

---Creates an UIGraphEntityData that is needed to create the Entity
---@return UIGraphEntityData
function HudUtils:GetDisableGameInputEntityData()
	local s_DisableGameInputGraphAsset = UIGraphAsset()
	s_DisableGameInputGraphAsset.modal = false
	s_DisableGameInputGraphAsset.protectScreens = true
	s_DisableGameInputGraphAsset.isWin32UIGraphAsset = true
	s_DisableGameInputGraphAsset.isXenonUIGraphAsset = true
	s_DisableGameInputGraphAsset.isPs3UIGraphAsset = true

	local s_InputNode = InstanceInputNode()
	s_InputNode.parentGraph = s_DisableGameInputGraphAsset
	s_InputNode.name = 'DisableGameInput'
	s_InputNode.isRootNode = false
	s_InputNode.parentIsScreen = false
	s_DisableGameInputGraphAsset.nodes:add(s_InputNode)

	local s_ActionNode = ActionNode()
	s_ActionNode.actionKey = MathUtils:FNVHash("GameInput")
	s_ActionNode.inValue = UINodePort()
	s_ActionNode.out = UINodePort()
	s_ActionNode.appendIncomingParams = false
	s_ActionNode.name = 'DisableGameInput'
	s_ActionNode.params:add("False")
	s_ActionNode.isRootNode = false
	s_ActionNode.parentGraph = s_DisableGameInputGraphAsset
	s_ActionNode.parentIsScreen = false
	s_DisableGameInputGraphAsset.nodes:add(s_ActionNode)

	local s_InputToDialogNodeConnection = UINodeConnection()
	s_InputToDialogNodeConnection.sourceNode = s_InputNode
	s_InputToDialogNodeConnection.targetNode = s_ActionNode
	s_InputToDialogNodeConnection.sourcePort = s_InputNode.out
	s_InputToDialogNodeConnection.targetPort = s_ActionNode.inValue
	s_InputToDialogNodeConnection.numScreensToPop = 0
	s_DisableGameInputGraphAsset.connections:add(s_InputToDialogNodeConnection)

	local s_OutputNode = InstanceOutputNode()
	s_OutputNode.inValue = UINodePort()
	s_OutputNode.id = MathUtils:FNVHash("exitIngameMenuMP")
	s_OutputNode.destroyGraph = true
	s_OutputNode.name = "exitIngameMenuMP"
	s_OutputNode.isRootNode = false
	s_OutputNode.parentGraph = s_DisableGameInputGraphAsset
	s_OutputNode.parentIsScreen = false
	s_DisableGameInputGraphAsset.nodes:add(s_OutputNode)

	local s_ActionToOutputNodeConnection = UINodeConnection()
	s_ActionToOutputNodeConnection.sourceNode = s_ActionNode
	s_ActionToOutputNodeConnection.targetNode = s_OutputNode
	s_ActionToOutputNodeConnection.sourcePort = s_ActionNode.out
	s_ActionToOutputNodeConnection.targetPort = s_OutputNode.inValue
	s_ActionToOutputNodeConnection.numScreensToPop = 1
	s_DisableGameInputGraphAsset.connections:add(s_ActionToOutputNodeConnection)

	local s_DisableGameInputGraphEntityData = UIGraphEntityData()
	s_DisableGameInputGraphEntityData.graphAsset = s_DisableGameInputGraphAsset
	s_DisableGameInputGraphEntityData.popPreviousGraph = false

	return s_DisableGameInputGraphEntityData
end

-- =============================================
-- BlurEffect
-- =============================================

---When going into a menu (true) or leaving it (false)
---@param p_Enable boolean
function HudUtils:EnableBlurEffect(p_Enable)
	if self.m_BlurInstanceId ~= nil then
		local s_EntityIterator = EntityManager:GetIterator('VisualEnvironmentEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_BlurInstanceId == s_Entity.instanceId then
				if p_Enable then
					s_Entity:FireEvent("Enable")
				else
					s_Entity:FireEvent("Disable")
				end

				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	elseif p_Enable then
		self:CreateBlurEffect()
	end
end

---Creates a VisualEnvironmentEntity that has a DofComponent which causes a blur effect
function HudUtils:CreateBlurEffect()
	local s_DofComponentData = ResourceManager:FindInstanceByGuid(Guid("3A3E5533-4B2A-11E0-A20D-FE03F1AD0E2F"), Guid("52FD86B6-00BA-45FC-A87A-683F72CA6916"))

	if s_DofComponentData == nil then
		m_Logger:Error("DofComponentData not found")
	end

	local s_ClonedDofCompData = DofComponentData(s_DofComponentData):Clone()
	s_ClonedDofCompData.excluded = false

	local s_VisualEnvEntityData = VisualEnvironmentEntityData()
	s_VisualEnvEntityData.enabled = true
	s_VisualEnvEntityData.visibility = 1
	s_VisualEnvEntityData.priority = 99999
	s_VisualEnvEntityData.components:add(s_ClonedDofCompData)
	s_VisualEnvEntityData.runtimeComponentCount = 1

	local s_Entity = EntityManager:CreateEntity(s_VisualEnvEntityData, LinearTransform())

	if s_Entity == nil then
		m_Logger:Error("Blurred Entity creation failed")
	end

	s_Entity:Init(Realm.Realm_Client, true)
	self.m_BlurInstanceId = s_Entity.instanceId
end

-- =============================================
-- ShowroomSoldier
-- =============================================

---@param p_Enable boolean
function HudUtils:EnableShowroomSoldier(p_Enable)
	local s_EventId = 'HideSoldier'

	if p_Enable then
		s_EventId = 'ShowSoldier'
	end

	if self.m_ShowSoldierInstanceId == nil then
		local s_ShowSoldierGraphEntityData = self:GetShowSoldierGraphEntityData()
		local s_ShowSoldierGraphEntity = EntityManager:CreateEntity(s_ShowSoldierGraphEntityData, LinearTransform())

		if s_ShowSoldierGraphEntity == nil then
			m_Logger:Warning("EnableShowroomSoldier: Creating Entity failed.")
			return
		end

		s_ShowSoldierGraphEntity:FireEvent(s_EventId)
		self.m_ShowSoldierInstanceId = s_ShowSoldierGraphEntity.instanceId
	else
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_ShowSoldierInstanceId == s_Entity.instanceId then
				s_Entity:FireEvent(s_EventId)
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end
end

---Creates an UIGraphEntityData that is needed to create the Entity
---@return UIGraphEntityData
function HudUtils:GetShowSoldierGraphEntityData()
	local s_GraphAsset = UIGraphAsset()

	-- SpawnCustomization
	---@type InstanceInputNode
	local s_ShowSoldierInputNode = m_ConnectionHelper:GetNode('InstanceInputNode', s_GraphAsset, { 'out' })
	s_ShowSoldierInputNode.name = 'ShowSoldier'

	---@type ActionNode
	local s_ShowSoldierActionNode = m_ConnectionHelper:GetNode('ActionNode', s_GraphAsset, { 'inValue', 'out' })
	s_ShowSoldierActionNode.actionKey = UIAction.SpawnCustomization
	s_ShowSoldierActionNode.params:add('-1')
	m_ConnectionHelper:AddNodeConnection(s_GraphAsset, s_ShowSoldierInputNode, s_ShowSoldierActionNode, s_ShowSoldierInputNode.out, s_ShowSoldierActionNode.inValue)

	-- UnSpawnCustomization
	---@type InstanceInputNode
	local s_HideSoldierInputNode = m_ConnectionHelper:GetNode('InstanceInputNode', s_GraphAsset, { 'out' })
	s_HideSoldierInputNode.name = 'HideSoldier'

	---@type ActionNode
	local s_HideSoldierActionNode = m_ConnectionHelper:GetNode('ActionNode', s_GraphAsset, { 'inValue', 'out' })
	s_HideSoldierActionNode.actionKey = UIAction.UnSpawnCustomization
	s_HideSoldierActionNode.params:add('-1')
	m_ConnectionHelper:AddNodeConnection(s_GraphAsset, s_HideSoldierInputNode, s_HideSoldierActionNode, s_HideSoldierInputNode.out, s_HideSoldierActionNode.inValue)

	-- Outputs
	---@type InstanceOutputNode
	local s_OutputNode = m_ConnectionHelper:GetNode('InstanceOutputNode', s_GraphAsset, { 'inValue' })
	m_ConnectionHelper:AddNodeConnection(s_GraphAsset, s_ShowSoldierActionNode, s_OutputNode, s_ShowSoldierActionNode.out, s_OutputNode.inValue)
	m_ConnectionHelper:AddNodeConnection(s_GraphAsset, s_HideSoldierActionNode, s_OutputNode, s_HideSoldierActionNode.out, s_OutputNode.inValue)

	local s_ShowSoldierGraphEntityData = UIGraphEntityData()
	s_ShowSoldierGraphEntityData.graphAsset = s_GraphAsset
	s_ShowSoldierGraphEntityData.popPreviousGraph = false

	return s_ShowSoldierGraphEntityData
end

-- =============================================
-- Clear Entities
-- =============================================

---Destroy all custom created entities to avoid issues
function HudUtils:DestroyEntities()
	if self.m_BlurInstanceId ~= nil then
		local s_EntityIterator = EntityManager:GetIterator('VisualEnvironmentEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_BlurInstanceId == s_Entity.instanceId then
				s_Entity:Destroy()
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end

	if self.m_DisableGameInputInstanceId ~= nil then
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_DisableGameInputInstanceId == s_Entity.instanceId then
				s_Entity:Destroy()
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end

	if self.m_EnableMouseInstanceId ~= nil then
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_EnableMouseInstanceId == s_Entity.instanceId then
				s_Entity:Destroy()
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end

	if self.m_ShowSoldierInstanceId ~= nil then
		local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = Entity(s_Entity)

			if self.m_ShowSoldierInstanceId == s_Entity.instanceId then
				s_Entity:Destroy()
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end
end

return HudUtils()
