---@class Chat
local Chat = class 'Chat'

---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"

-- =============================================
-- Events
-- =============================================

function Chat:__init()
	self.m_IsChatOpen = false
end

---VEXT Shared Extension:Unloading Event
function Chat:OnExtensionUnloading()
	WebUI:ExecuteJS("OnClearChat()")
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
end

---VEXT Shared Level:Destroy Event
function Chat:OnLevelDestroy()
	WebUI:ExecuteJS("OnClearChat()")
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
end

---VEXT Shared Engine:Update Event
---@param p_DeltaTime number
function Chat:OnEngineUpdate(p_DeltaTime)
	if self.m_IsChatOpen then
		WebUI:EnableMouse()
		WebUI:EnableKeyboard()
	end
end

-- =============================================
-- NetEvents
-- =============================================

---Custom Client ChatMessage:SquadReceive NetEvent
---@param p_PlayerName string
---@param p_Message string
function Chat:OnChatMessageSquadReceive(p_PlayerName, p_Message)
	local s_OtherPlayer = PlayerManager:GetPlayerByName(p_PlayerName)

	if s_OtherPlayer == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	local s_PlayerRelation = "squadMate"

	if s_OtherPlayer == s_LocalPlayer then
		s_PlayerRelation = "localPlayer"
	end

	local s_Table = {author = p_PlayerName, content = p_Message, target = "squad", playerRelation = s_PlayerRelation}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
end

---Custom Client ChatMessage:AllReceive NetEvent
---@param p_PlayerName string
---@param p_Message string
function Chat:OnChatMessageAllReceive(p_PlayerName, p_Message)
	local s_OtherPlayer = PlayerManager:GetPlayerByName(p_PlayerName)

	if s_OtherPlayer == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	local s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)
	local s_Table = {author = s_OtherPlayer.name, content = p_Message, target = "all", playerRelation = s_PlayerRelation}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Client UI:InputConceptEvent Hook
---@param p_HookCtx HookContext
---@param p_EventType UIInputActionEventType|integer
---@param p_Action UIInputAction|integer
function Chat:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	if p_EventType ~= UIInputActionEventType.UIInputActionEventType_Pressed then
		return
	end

	if p_Action == UIInputAction.UIInputAction_SayAllChat or p_Action == UIInputAction.UIInputAction_TeamChat
	or p_Action == UIInputAction.UIInputAction_SquadChat then
		if m_HudUtils:GetIsInOptionsMenu() then
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end

		local s_Target = "squad"

		if p_Action == UIInputAction.UIInputAction_SayAllChat and ServerConfig.Debug.EnableAllChat then
			s_Target = "all"
		end

		WebUI:ExecuteJS(string.format("OnFocus('%s')", s_Target))
		self.m_IsChatOpen = true
		self:DisableWeapon(true)
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_ToggleChat then
		if m_HudUtils:GetIsInOptionsMenu() then
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end

		WebUI:ExecuteJS("OnChangeType()")
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
end

---VEXT Client UI:CreateChatMessage Hook
---@param p_HookCtx HookContext
---@param p_Message string
---@param p_Channel ChatChannelType|integer
---@param p_PlayerId integer
---@param p_RecipientMask integer
---@param p_SenderIsDead boolean
function Chat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	if p_Message == nil then
		return
	end

	-- Region AdminMessage
	if p_Channel == ChatChannelType.CctAdmin then
		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = p_Message:gsub("^Admin: ", '')

		local s_Table = {author = "Admin", content = s_String, target = "admin", playerRelation = "none"}
		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
	end

	p_HookCtx:Return()
end

-- =============================================
-- WebUI Events
-- =============================================

---Custom Client WebUI:OutgoingChatMessage WebUI Event
---@param p_JsonData string @json table
function Chat:OnWebUIOutgoingChatMessage(p_JsonData)
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
	---@type string[]
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local s_Target = s_DecodedData.target
	local s_Message = s_DecodedData.message

	if s_Target == nil or s_Message == nil or type(s_Message) ~= "string" then
		return
	end

	-- Trim the message.
	local s_From = s_Message:match"^%s*()"
 	s_Message = s_From > #s_Message and "" or s_Message:match(".*%S", s_From)

	-- Ignore if the message is empty.
	if s_Message:len() == 0 then
		return
	end

	-- Dispatch message based on the specified target.
	if s_Target == 'all' and ServerConfig.Debug.EnableAllChat then
		NetEvents:SendLocal("ChatMessage:AllSend", s_Message)
		return
	end

	NetEvents:SendLocal("ChatMessage:SquadSend", s_Message)
end

---Custom Client WebUI:SetCursor WebUI Event
function Chat:OnWebUISetCursor()
	InputManager:SetCursorPosition(WebUI:GetScreenWidth() / 2, WebUI:GetScreenHeight() / 2)
	WebUI:ResetKeyboard()
	g_Timers:Timeout(0.035, function()
		WebUI:ResetMouse()
	end)
end

-- =============================================
-- Functions
-- =============================================

---Returns the relation between these 2 players
---@param p_OtherPlayer Player
---@param p_LocalPlayer Player
---@return string
function Chat:GetPlayerRelation(p_OtherPlayer, p_LocalPlayer)
	if p_OtherPlayer.name == p_LocalPlayer.name then
		return "localPlayer"
	elseif p_OtherPlayer.teamId == p_LocalPlayer.teamId then
		if p_OtherPlayer.squadId == p_LocalPlayer.squadId and p_LocalPlayer.squadId ~= 0 then
			return "squadMate"
		else
			return "teamMate"
		end
	elseif p_OtherPlayer.teamId == 0 then
		return "spectator"
	else
		return "enemy"
	end
end

---Disables/ Enables EIAFire input
---@param p_Disable boolean
function Chat:DisableWeapon(p_Disable)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	s_LocalPlayer:EnableInput(EntryInputActionEnum.EIAFire, not p_Disable)
end

return Chat()
