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

return VoipManager()
