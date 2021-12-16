---@class AntiCheatServer
AntiCheatServer = class 'AntiCheatServer'

function AntiCheatServer:__init()
	self:Reset()

	NetEvents:Subscribe('Cheat', self, self.OnCheat)
	NetEvents:Subscribe('Debug', self, self.OnDebug)
end

function AntiCheatServer:Reset()
	---@type table<string, integer>
	---`table<string: playerName, integer: bustedTimesCheating>`
	self.m_PlayerCount = {}
	self.m_Timer = 0.0
	self.m_Verify = false
	---@type table<string, boolean>
	---Used to confirm that they receive NetEvents
	self.m_VerifiedPlayers = {}
end

-- =============================================
-- Events
-- =============================================

function AntiCheatServer:OnLevelLoaded()
	self:Reset()
end

function AntiCheatServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	self.m_Timer = self.m_Timer + p_DeltaTime

	if self.m_Timer >= 28.0 then
		if self.m_Verify == false then
			self.m_Verify = true
			NetEvents:Broadcast('Verify')
		end

		if self.m_Timer >= 30.0 and self.m_Verify == true then
			for _, l_Player in pairs(PlayerManager:GetPlayers()) do
				if self.m_VerifiedPlayers[l_Player.name] == nil and l_Player.accountGuid ~= Guid('00000000-0000-0000-0000-000000000000') then
					if self.m_PlayerCount[l_Player.name] == nil then
						self.m_PlayerCount[l_Player.name] = 1
					elseif self.m_PlayerCount[l_Player.name] <= 10 then
						self.m_PlayerCount[l_Player.name] = self.m_PlayerCount[l_Player.name] + 1
					else
						print("----------------------------------------------------------")
						print("Failed Communication")
						print("KICKED PLAYER " .. l_Player.name .. " " .. tostring(l_Player.accountGuid) .. " " .. l_Player.ip)
						print("----------------------------------------------------------")
						l_Player:Kick("Failed Communication.")
						self.m_PlayerCount[l_Player.name] = nil
					end
				end
			end

			self.m_Verify = false
			self.m_Timer = 0.0
			self.m_VerifiedPlayers = {}
		end
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

function AntiCheatServer:OnCheat(p_Player, p_Args)
	if self.m_Verify == false and p_Args[1] ~= "Verify" then
		if self.m_PlayerCount[p_Player.name] == nil then
			self.m_PlayerCount[p_Player.name] = 1
		elseif self.m_PlayerCount[p_Player.name] <= 10 then
			self.m_PlayerCount[p_Player.name] = self.m_PlayerCount[p_Player.name] + 1
			print("----------------------------------------------------------")
			print(p_Player.name .. " " .. tostring(p_Player.accountGuid) .. " " .. p_Player.ip)
			print(p_Args)
			print("----------------------------------------------------------")
		else
			print("----------------------------------------------------------")
			print("BANNED PLAYER " .. p_Player.name .. " " .. tostring(p_Player.accountGuid) .. " " .. p_Player.ip)
			print(p_Args)
			print("----------------------------------------------------------")
			local s_Guid = p_Player.accountGuid
			local s_Name = p_Player.name
			local s_Ip = p_Player.ip
			RCON:SendCommand('banList.add', {"guid", s_Guid:ToString('N'), "perm", p_Args[1]})
			RCON:SendCommand('banList.add', {"name", s_Name, "perm", p_Args[1]})
			RCON:SendCommand('banList.add', {"ip", s_Ip, "perm", p_Args[1]})
			RCON:SendCommand('banList.save')
			self.m_PlayerCount[p_Player.name] = nil
		end
	else
		self.m_VerifiedPlayers[p_Player.name] = true
	end
end

function AntiCheatServer:OnDebug(p_Player, p_Args)
	if p_Args[1] == "404" then
		print(p_Player.name)
		print(p_Args)
	elseif self.m_Verify == true then
		self.m_VerifiedPlayers[p_Player.name] = true
	end
end

return AntiCheatServer()
