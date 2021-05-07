class 'Chat'

require "__shared/Utils/Timers"

-- =============================================
-- Events
-- =============================================

function Chat:OnLevelDestroy()
    WebUI:ExecuteJS("OnClearChat()")
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
		if p_Action == UIInputAction.UIInputAction_SayAllChat and ServerConfig.Debug.EnableAllChat then
			WebUI:ExecuteJS(string.format("OnFocus('%s')", "all"))
			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
		WebUI:ExecuteJS(string.format("OnFocus('%s')", "squad"))
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_ToggleChat then
		WebUI:ExecuteJS("OnChangeType()")
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
end

function Chat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	if p_Message == nil then
		return
	end
	-- Get the player sending the message, and our local player.
	local s_OtherPlayer = PlayerManager:GetPlayerById(p_PlayerId)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	local s_Target
	local s_Table = {}
	local s_PlayerRelation = "none"
	local s_TargetName = nil

	-- Region SquadLeaderMessage, DirectMessage, AdminMessage
	if p_Channel == ChatChannelType.CctAdmin then
		local s_Author = ""
		s_Target = "admin"

		-- This is a workaround because many RCON tools prepend
		-- "Admin: " to admin messages.
		local s_String = p_Message:gsub("^Admin: ", '')
		s_Table = {author = s_Author, content = s_String, target = s_Target, playerRelation = s_PlayerRelation, targetName = s_TargetName}
		WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))
		goto continue
	end
	-- Endregion

	-- Players not found; cancel.
	if s_OtherPlayer == nil or s_LocalPlayer == nil then
		goto continue
	end

	-- Region target: spectator, enemy, all, team, squad
	-- Player is a spectator.
	if s_OtherPlayer.teamId == 0 then
		s_Target = "spectator"
	-- Player is on a different team; display enemy message.
	elseif (s_LocalPlayer.teamId == 0 and s_OtherPlayer.teamId == 2) or (s_LocalPlayer.teamId ~= 0 and s_OtherPlayer.teamId ~= s_LocalPlayer.teamId) then
		s_Target = "enemy"
	-- Player is in the same team.
	-- Display global message.
	elseif p_Channel == ChatChannelType.CctSayAll then
		s_Target = "all"
	-- Display team message.
	elseif p_Channel == ChatChannelType.CctTeam then
		s_Target = "team"
	-- Display squad message.
	elseif p_Channel == ChatChannelType.CctSquad then
		s_Target = "squad"
	else
		goto continue
	end

	s_PlayerRelation = self:GetPlayerRelation(s_OtherPlayer, s_LocalPlayer)
	s_Table = {author = s_OtherPlayer.name, content = p_Message, target = s_Target, playerRelation = s_PlayerRelation}
	WebUI:ExecuteJS(string.format("OnMessage(%s)", json.encode(s_Table)))

	::continue::

	-- A new chat message is being created;
	-- prevent the game from rendering it.
	p_HookCtx:Return()
end

-- =============================================
-- WebUI Events
-- =============================================

function Chat:OnWebUIOutgoingChatMessage(p_JsonData)
	local s_DecodedData = json.decode(p_JsonData)

	-- Load params from the decoded JSON.
	local p_Target = s_DecodedData.target
	local p_Message = s_DecodedData.message

	-- Trim the message.
	local s_From = p_Message:match"^%s*()"
 	p_Message = s_From > #p_Message and "" or p_Message:match(".*%S", s_From)

	-- Ignore if the message is empty.
	if p_Message:len() == 0 then
		return
	end

	-- Get the local player.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- We can't send a message if we don't have an active player.
	if s_LocalPlayer == nil then
		return
	end

	-- Dispatch message based on the specified target.
	if p_Target == 'all' and ServerConfig.Debug.EnableAllChat then
		ChatManager:SendMessage(p_Message)
		return
	end

	ChatManager:SendMessage(p_Message, s_LocalPlayer.teamId, s_LocalPlayer.squadId)
end

function Chat:OnWebUISetCursor()
	local s_WindowSize = ClientUtils:GetWindowSize()
	InputManager:SetCursorPosition(s_WindowSize.x / 2, s_WindowSize.y / 2)
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

if g_Chat == nil then
    g_Chat = Chat()
end

return g_Chat
