require "__shared/Configs/MapsConfig"
require "__shared/Enums/CustomEvents"
require "__shared/Enums/SubphaseTypes"
require "__shared/Utils/MathHelper"
require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/Timers"
require "__shared/Logic/PhaseManagerShared"
require "__shared/Types/Circle"

class("PhaseManagerServer", PhaseManagerShared)

local m_BRTeamManager = require "BRTeamManager"
local m_Logger = Logger("PhaseManagerServer", true)

function PhaseManagerServer:RegisterVars()
	PhaseManagerShared.RegisterVars(self)

	self.m_InnerCircle = Circle(Vec3(0, 0, 0), 5000)
	self.m_OuterCircle = Circle(Vec3(0, 0, 0), 5000)
end

-- =============================================
-- Events
-- =============================================

function PhaseManagerServer:OnPhaseManagerInitialState(p_Player)
	self:BroadcastState(p_Player)
end

-- =============================================
-- Functions
-- =============================================

-- Starts the PhaseManager logic
function PhaseManagerServer:Start()
	self:SetTimer("Damage", g_Timers:Interval(1, self, self.ApplyDamage))
	self:SetTimer("ClientTimer", g_Timers:Interval(1, self, self.ClientTimer))
	self:InitPhase()
end

-- Ends the PhaseManager logic
function PhaseManagerServer:End()
	self:RemoveTimers()
	self:Finalize()
end

function PhaseManagerServer:Next()
	if not self:NextSubphase() then
		if not self:NextPhase() then
			self:Finalize()
			return false
		end
	end

	self:InitPhase()
	return true
end

-- Moves to the next Phase
function PhaseManagerServer:NextPhase()
	-- check if it reached the end
	if self.m_PhaseIndex >= #self.m_Phases then
		return false
	end

	-- increment phase
	self.m_PhaseIndex = self.m_PhaseIndex + 1
	self.m_SubphaseIndex = SubphaseType.Waiting

	return true
end

-- Moves to the next Subphase
function PhaseManagerServer:NextSubphase()
	-- check if it reached the end of the subphases for the current phase
	if self.m_SubphaseIndex ~= SubphaseType.InitialDelay and self.m_SubphaseIndex >= SubphaseType.Moving then
		return false
	end

	-- increment subphase
	self.m_SubphaseIndex = self.m_SubphaseIndex + 1
	return true
end

function PhaseManagerServer:InitPhase()
	self:RemoveTimer("NextSubphase")
	self:RemoveTimer("MovingCircle")

	-- start the timer for the next phase
	self:SetTimer("NextSubphase", g_Timers:Timeout(self:GetCurrentDelay(), self, self.Next))

	if self.m_SubphaseIndex == SubphaseType.Waiting then
		local s_Phase = self:GetCurrentPhase()
		local s_NewRadius = s_Phase.Ratio * self.m_InnerCircle.m_Radius
		local s_NewCenter = nil

		-- pick a random circle center
		if self.m_PhaseIndex == 1 then
			s_NewRadius = MapsConfig[LevelNameHelper:GetLevelName()].InitialCircle.Radius
			s_NewCenter = self:GetRandomInitialCenter()
		else
			self.m_OuterCircle = self.m_InnerCircle:Clone()
			s_NewCenter = self.m_InnerCircle:RandomInnerPoint(self.m_InnerCircle.m_Radius - s_NewRadius)
		end

		-- set new safezone
		self.m_InnerCircle:Update(s_NewCenter, s_NewRadius)

		-- update initial outer circle center
		if self.m_PhaseIndex == 1 then
			self.m_OuterCircle:Update(s_NewCenter, s_NewRadius * 3)
		end
	elseif self.m_SubphaseIndex == SubphaseType.Moving then
		self.m_PrevOuterCircle = self.m_OuterCircle:Clone()
		self:SetTimer("MovingCircle",
					g_Timers:Sequence(0.5, math.floor(self:GetCurrentDelay() / 0.5), self, self.MoveOuterCircle))
	end

	self:DebugMessage()
	self:BroadcastState()
end

function PhaseManagerServer:Finalize()
	self.m_Completed = true

	-- clear timers
	self:RemoveTimer("NextSubphase")
	self:RemoveTimer("MovingCircle")

	-- match outer circle with inner circle
	if self.m_PhaseIndex == #self.m_Phases then
		self.m_OuterCircle = self.m_InnerCircle:Clone()
	end

	-- display debug message and update clients
	self:DebugMessage()
	self:BroadcastState()
end

-- Broadcasts PhaseManager's state to all players
function PhaseManagerServer:BroadcastState(p_Player)
	local s_Duration = 0
	local s_Timer = self:GetTimer("NextSubphase")

	-- Send remaning time to complete
	if s_Timer ~= nil then
		s_Duration = s_Timer:Remaining()
	end

	local s_Data = {
		PhaseIndex = self.m_PhaseIndex,
		SubphaseIndex = self.m_SubphaseIndex,
		InnerCircle = self.m_InnerCircle:AsTable(),
		OuterCircle = self.m_OuterCircle:AsTable(),
		Duration = s_Duration
	}

	if p_Player ~= nil then
		NetEvents:SendToLocal(PhaseManagerNetEvent.UpdateState, p_Player, s_Data)
	else
		NetEvents:BroadcastLocal(PhaseManagerNetEvent.UpdateState, s_Data)
	end
end

-- Damages every player outside of the outer circle
function PhaseManagerServer:ApplyDamage()
	if self:IsIdle() then
		return
	end

	-- get damage for current phase
	local s_Damage = self:GetCurrentPhase().Damage

	for _, l_BrPlayer in pairs(m_BRTeamManager.m_Players) do
		local s_Soldier = l_BrPlayer:GetSoldier()

		-- check if soldier is outside of the circle
		if s_Soldier ~= nil and not self.m_OuterCircle:IsInnerPoint(l_BrPlayer:GetPosition()) then
			-- update player's health if needed
			if l_BrPlayer.m_Player.alive then
				s_Soldier.health = math.max(0, s_Soldier.health - s_Damage)
			end
		end
	end
end

function PhaseManagerServer:ClientTimer()
	local s_CurrentTimer = self:GetTimer("NextSubphase")

	if self.m_SubphaseIndex == SubphaseType.Waiting or self.m_SubphaseIndex == SubphaseType.InitialDelay then
		if s_CurrentTimer ~= nil then
			NetEvents:Broadcast(PlayerEvents.UpdateTimer, s_CurrentTimer:Remaining())
		end
	elseif self.m_SubphaseIndex == SubphaseType.Moving then
		s_CurrentTimer = self:GetTimer("MovingCircle")

		if s_CurrentTimer ~= nil then
			NetEvents:Broadcast(PlayerEvents.UpdateTimer, s_CurrentTimer:Remaining())
		end
	end
end

function PhaseManagerServer:GetRandomInitialCenter()
	local s_LevelName = LevelNameHelper:GetLevelName()

	-- pick triangle index
	local s_Rnd = MathUtils:GetRandom(0, 1)
	local s_Index = 0

	for l_CurrentIndex, l_Value in ipairs(MapsConfig[s_LevelName].InitialCircle.CumulativeDistribution) do
		if s_Index < 1 and l_Value > s_Rnd then
			s_Index = l_CurrentIndex
		end
	end

	-- get random point from the triangle
	local s_Triangle = MapsConfig[s_LevelName].InitialCircle.Triangles[s_Index]
	local s_Center2 = MathHelper:RandomTrianglePoint(s_Triangle)

	return Vec3(s_Center2.x, 0, s_Center2.y)
end

-- Prints a debug message about the current status of PhaseManager
function PhaseManagerServer:DebugMessage()
	local s_Delay = self:GetCurrentDelay()

	-- check if PhaseManager's work is completed
	if s_Delay < 0 then
		m_Logger:Write("Completed")
		return
	end

	-- debug messages for each SubphaseType
	local s_Messages = {
		[SubphaseType.InitialDelay] = "Initial Delay",
		[SubphaseType.Waiting] = "Circle is waiting",
		[SubphaseType.Moving] = "Circle is moving"
	}

	m_Logger:Write(string.format("[%d] %s for %.2f seconds", self.m_PhaseIndex, s_Messages[self.m_SubphaseIndex], s_Delay))
end

if g_PhaseManagerServer == nil then
	g_PhaseManagerServer = PhaseManagerServer()
end

return g_PhaseManagerServer
