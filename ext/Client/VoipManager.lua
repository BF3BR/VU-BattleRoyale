---@class VoipManager
VoipManager = class 'VoipManager'

---@type Logger
local m_Logger = Logger("VoipManager", false)

---@param p_String '"Party"'|'"Team"'
---@return ModSetting
local function GetPushToTalkSetting(p_String)
	local s_PushToTalkSetting = SettingsManager:GetSetting("Voip_" .. p_String .. "_PushToTalk_Key")

	if s_PushToTalkSetting == nil then
		---@type InputDeviceKeys|integer
		local s_DefaultInputDeviceKey = nil

		if p_String == "Party" then
			s_DefaultInputDeviceKey = InputDeviceKeys.IDK_1
		else
			s_DefaultInputDeviceKey = InputDeviceKeys.IDK_0
		end

		s_PushToTalkSetting = SettingsManager:DeclareKeybind("Voip_" .. p_String .. "_PushToTalk_Key", s_DefaultInputDeviceKey, { displayName = p_String .. " Voip Push-To-Talk Key", showInUi = true})
		s_PushToTalkSetting.value = s_DefaultInputDeviceKey

		m_Logger:Write("GetPushToTalkSetting created setting for " .. p_String)
	end

	return s_PushToTalkSetting
end

---@param p_String '"Party"'|'"Team"'
---@return ModSetting
local function GetTransmissionModeSetting(p_String)
	local s_TransmissionModeSetting = SettingsManager:GetSetting("Voip_" .. p_String .. "_TransmissionMode")

	if s_TransmissionModeSetting == nil then
		---@type SettingOptions
		local s_SettingOptions = SettingOptions()
		s_SettingOptions.displayName = p_String .. " Voip TransmissionMode"
		s_SettingOptions.showInUi = true
		s_TransmissionModeSetting = SettingsManager:DeclareOption("Voip_" .. p_String .. "_TransmissionMode", "PushToTalk", { "AlwaysOn", "PushToTalk", "VoiceActivation"}, false, s_SettingOptions)
		s_TransmissionModeSetting.value = "PushToTalk"

		m_Logger:Write("GetTransmissionModeSetting created setting for " .. p_String)
	end

	if VoipTransmissionMode[s_TransmissionModeSetting.value] == nil then
		m_Logger:Warning("The " .. p_String .. " TransmissionModeSetting is invalid. We reset this setting to default.")
		s_TransmissionModeSetting.value = "PushToTalk"
	end

	return s_TransmissionModeSetting
end

function VoipManager:OnExtensionLoaded()
	---@type string|nil
	self.m_BrTeamChannelName = nil
	---@type string|nil
	self.m_BrPartyChannelName = nil
	self.m_BrTeamIsTransmitting = false
	self.m_BrPartyIsTransmitting = false

	self.m_BrTeam_TransitionModeSetting = GetTransmissionModeSetting("Team")
	self.m_BrTeam_PushToTalk_KeySetting = GetPushToTalkSetting("Team")
	self.m_BrParty_TransitionModeSetting = GetTransmissionModeSetting("Party")
	self.m_BrParty_PushToTalk_KeySetting = GetPushToTalkSetting("Party")
end

---VEXT Client Client:UpdateInput Event
function VoipManager:OnClientUpdateInput()
	-- if this player has no microphone we can stop right here
	if not Voip:IsAvailable() then
		return
	end

	if self.m_BrTeamChannelName ~= nil and VoipTransmissionMode[self.m_BrTeam_TransitionModeSetting.value] == VoipTransmissionMode.PushToTalk then
		if InputManager:WentKeyDown(self.m_BrTeam_PushToTalk_KeySetting.value) and not self.m_BrTeamIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrTeamChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StartTransmitting to channel " .. self.m_BrTeamChannelName)
				self.m_BrTeamIsTransmitting = true
				s_Channel:StartTransmitting()
			end
		elseif InputManager:WentKeyUp(self.m_BrTeam_PushToTalk_KeySetting.value) and self.m_BrTeamIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrTeamChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StopTransmitting to channel " .. self.m_BrTeamChannelName)
				self.m_BrTeamIsTransmitting = false
				s_Channel:StopTransmitting()
			end
		end
	end

	if self.m_BrPartyChannelName ~= nil and VoipTransmissionMode[self.m_BrParty_TransitionModeSetting.value] == VoipTransmissionMode.PushToTalk then
		if InputManager:WentKeyDown(self.m_BrParty_PushToTalk_KeySetting.value) and not self.m_BrPartyIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrPartyChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StartTransmitting to channel " .. self.m_BrPartyChannelName)
				self.m_BrPartyIsTransmitting = true
				s_Channel:StartTransmitting()
			end
		elseif InputManager:WentKeyUp(self.m_BrParty_PushToTalk_KeySetting.value) and self.m_BrPartyIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrPartyChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StopTransmitting to channel " .. self.m_BrPartyChannelName)
				self.m_BrPartyIsTransmitting = false
				s_Channel:StopTransmitting()
			end
		end
	end
end

---VEXT Client VoipChannel:PlayerJoined Event
---@param p_Channel VoipChannel
---@param p_Player Player
---@param p_Emitter VoipEmitter
function VoipManager:OnVoipChannelPlayerJoined(p_Channel, p_Player, p_Emitter)
	m_Logger:Write('Player ' .. p_Player.name .. ' joined voip channel ' .. p_Channel.name)

	if p_Player == PlayerManager:GetLocalPlayer() then
		-- We don't want to hear ourselves.
		p_Emitter.volume = 0.0
		p_Emitter.muted = true

		if p_Channel.name:match("BRTeam") then
			self.m_BrTeamChannelName = p_Channel.name
			p_Channel.transmissionMode = VoipTransmissionMode[self.m_BrTeam_TransitionModeSetting.value]
		else
			self.m_BrPartyChannelName = p_Channel.name
			p_Channel.transmissionMode = VoipTransmissionMode[self.m_BrParty_TransitionModeSetting.value]
		end
	else
		p_Emitter.volume = 5.0
	end
end

---VEXT Client VoipChannel:PlayerLeft Event
---@param p_Channel VoipChannel
---@param p_Player Player
function VoipManager:OnVoipChannelPlayerLeft(p_Channel, p_Player)
	m_Logger:Write('Player ' .. p_Player.name .. ' left voip channel ' .. p_Channel.name)

	if p_Player == PlayerManager:GetLocalPlayer() then
		if p_Channel.name:match("BRTeam") then
			self.m_BrTeamChannelName = nil
			self.m_BrTeamIsTransmitting = false
		else
			self.m_BrPartyChannelName = nil
			self.m_BrPartyIsTransmitting = false
		end
	end
end

---VEXT Client VoipEmitter:Emitting Event
---@param p_Emitter VoipEmitter
---@param p_IsEmitting boolean
function VoipManager:OnVoipEmitterEmitting(p_Emitter, p_IsEmitting)
	-- player can be nil if the client is in the loading screen
	if p_Emitter.player == nil then
		return
	end

	if p_Emitter.muted then
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()

		-- we want to update our localPlayer speaking icon
		-- so we can see that we are talking
		if s_LocalPlayer == nil or s_LocalPlayer ~= p_Emitter.player then
			return
		end
	end

	if p_Emitter.channel.name:match("BRTeam") then
		WebUI:ExecuteJS("VoipEmitterEmitting('" .. p_Emitter.player.name .. "'," .. tostring(p_IsEmitting) ..", false);")
	else
		WebUI:ExecuteJS("VoipEmitterEmitting('" .. p_Emitter.player.name .. "'," .. tostring(p_IsEmitting) ..", true);")
	end
end

---Custom Client WebUI:VoipMutePlayer WebUI Event
---@param p_PlayerName string
---@param p_Mute boolean
function VoipManager:OnWebUIVoipMutePlayer(p_PlayerName, p_Mute)
	if self.m_BrTeamChannelName == nil then
		m_Logger:Warning("Tried (un-)muting a player from team voip channel while not being in one.")
		return
	end

	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)

	if s_Player == nil then
		m_Logger:Write("Couldn\'t find the player: " .. p_PlayerName)
		return
	end

	local s_Channel = Voip:GetChannel(self.m_BrTeamChannelName)

	if s_Channel == nil then
		m_Logger:Warning("Couldn\'t find VoipChannel: " .. self.m_BrTeamChannelName)
		return
	end

	local s_Emitter = s_Channel:GetEmitter(s_Player)

	if s_Emitter == nil then
		m_Logger:Warning("Couldn\'t find emitter for player: " .. p_PlayerName)
		return
	end

	s_Emitter.muted = p_Mute
	s_Emitter.volume = p_Mute and 0.0 or 5.0

	-- send confirmation back to webui
	WebUI:ExecuteJS("VoipPlayerMuted('" .. p_PlayerName .. "'," .. tostring(p_Mute) ..");")
end

return VoipManager()
