class 'VoipManager'

local m_Logger = Logger("VoipManager", true)

function VoipManager:__init()
	self.m_BrTeamChannelName = nil
	self.m_BrPartyChannelName = nil
	self.m_BrTeamIsTransmitting = false
	self.m_BrPartyIsTransmitting = false
end

function VoipManager:OnClientUpdateInput()
	-- if this player has no microphone we can stop right here
	if not Voip:IsAvailable() then
		return
	end

	if self.m_BrTeamChannelName ~= nil then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_LeftAlt) and not self.m_BrTeamIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrTeamChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StartTransmitting to channel " .. self.m_BrTeamChannelName)
				self.m_BrTeamIsTransmitting = true
				s_Channel:StartTransmitting()
			end
		elseif InputManager:WentKeyUp(InputDeviceKeys.IDK_LeftAlt) and self.m_BrTeamIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrTeamChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StopTransmitting to channel " .. self.m_BrTeamChannelName)
				self.m_BrTeamIsTransmitting = false
				s_Channel:StopTransmitting()
			end
		end
	end

	if self.m_BrPartyChannelName ~= nil then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_RightAlt) and not self.m_BrPartyIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrPartyChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StartTransmitting to channel " .. self.m_BrPartyChannelName)
				self.m_BrPartyIsTransmitting = true
				s_Channel:StartTransmitting()
			end
		elseif InputManager:WentKeyUp(InputDeviceKeys.IDK_RightAlt) and self.m_BrPartyIsTransmitting then
			local s_Channel = Voip:GetChannel(self.m_BrPartyChannelName)

			if s_Channel ~= nil then
				m_Logger:Write("StopTransmitting to channel " .. self.m_BrPartyChannelName)
				self.m_BrPartyIsTransmitting = false
				s_Channel:StopTransmitting()
			end
		end
	end
end

function VoipManager:OnVoipChannelPlayerJoined(p_Channel, p_Player, p_Emitter)
	m_Logger:Write('Player ' .. p_Player.name .. ' joined voip channel ' .. p_Channel.name)

	if p_Player == PlayerManager:GetLocalPlayer() then
		-- We don't want to hear ourselves.
		p_Emitter.volume = 0.0
		p_Emitter.muted = true

		-- Make sure it's push to talk
		-- TODO: BACKLOG: add an option to change it as a player
		p_Channel.transmissionMode = VoipTransmissionMode.PushToTalk

		if p_Channel.name:match("BRTeam") then
			self.m_BrTeamChannelName = p_Channel.name
		else
			self.m_BrPartyChannelName = p_Channel.name
		end
	else
		p_Emitter.volume = 5.0
	end
end

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
		--WebUI:ExecuteJs("VoipEmitterEmitting(" .. p_Emitter.player.name .. "," .. tostring(p_IsEmitting) ..", false);")
	else
		--WebUI:ExecuteJs("VoipEmitterEmitting(" .. p_Emitter.player.name .. "," .. tostring(p_IsEmitting) ..", true);")
	end
end

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

	-- send confirmation back to webui?
	-- WebUI:ExecuteJs("VoipPlayerMuted(" .. p_PlayerName .. "," .. tostring(p_Mute) ..");")
end

return VoipManager()
