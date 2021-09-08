class 'Chat'

local m_HudUtils = require "UI/Utils/HudUtils"

-- =============================================
-- Events
-- =============================================

function Chat:__init()
	self.m_IsChatOpen = false
end

function Chat:OnExtensionUnloading()
	WebUI:ExecuteJS("OnClearChat()")
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
end

function Chat:OnLevelDestroy()
	WebUI:ExecuteJS("OnClearChat()")
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
end

function Chat:OnEngineUpdate(p_DeltaTime)
	if self.m_IsChatOpen then
		WebUI:EnableMouse()
		WebUI:EnableKeyboard()
	end
end

-- =============================================
-- NetEvents
-- =============================================

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

function Chat:OnWebUIOutgoingChatMessage(p_JsonData)
	self.m_IsChatOpen = false
	self:DisableWeapon(false)
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

function Chat:DisableWeapon(p_Disable)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	s_LocalPlayer:EnableInput(EntryInputActionEnum.EIAFire, not p_Disable)
end

return Chat()
