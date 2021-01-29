require "__shared/Enums/PhaseManagerEvents"
require "__shared/Enums/SubphaseTypes"
require "__shared/PhaseManagerShared"
require "__shared/Utils/Timers"
require "__shared/Circle"

class ("PhaseManagerServer", PhaseManagerShared)

function PhaseManagerServer:RegisterVars()
    PhaseManagerShared.RegisterVars(self)

    -- TODO
    self.m_InnerCircle = Circle(Vec3(148, 0, -864), 300)
    self.m_OuterCircle = Circle(Vec3(148, 0, -864), 3000)
end

function PhaseManagerServer:RegisterEvents()
    PhaseManagerShared.RegisterEvents(self)

    NetEvents:Subscribe(PhaseManagerNetEvents.InitialState, self, self.BroadcastState)

    -- Debug
    Events:Subscribe("Player:Chat", self, self.OnChat)
end

-- Starts the PhaseManager logic
function PhaseManagerServer:Start()
    self:SetTimer("Damage", g_Timers:Interval(1, self, self.ApplyDamage))
    self:InitPhase()
end

-- Ends the PhaseManager logic
function PhaseManagerServer:End()
    self:RemoveTimers()
    self:Finalize()
end

-- 
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
    if self.m_PhaseIndex >= #self.m_Phases then return false end

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
        local l_Phase = self:GetCurrentPhase()
        local l_NewRadius = l_Phase.Ratio * self.m_InnerCircle.m_Radius
        local l_NewCenter = nil

        -- pick a random circle center
        if self.phaseIndex == 1 then
            l_NewCenter = Vec3(148, 0, -864) -- TODO pick random point from polygon, this is a fixed initial center for Kiasar
        else
            self.m_OuterCircle = self.m_InnerCircle:Clone()
            l_NewCenter = self.m_InnerCircle:RandomInnerPoint(self.m_InnerCircle.m_Radius - l_NewRadius)
        end

        -- set new safezone
        self.m_InnerCircle:Update(l_NewCenter, l_NewRadius)

        -- update initial outer circle center
        if self.phaseIndex == 1 then self.m_OuterCircle.m_Center = l_NewCenter end
    elseif self.m_SubphaseIndex == SubphaseType.Moving then
        self.m_PrevOuterCircle = self.m_OuterCircle:Clone()
        self:SetTimer("MovingCircle",
                      g_Timers:Sequence(0.5, math.floor(self:GetCurrentDelay() / 0.5), self, self.MoveOuterCircle))
    end

    self:DebugMessage()
    self:BroadcastState()
end

-- 
function PhaseManagerServer:Finalize()
    self.m_Completed = true

    -- clear timers
    self:RemoveTimer("NextSubphase")
    self:RemoveTimer("MovingCircle")

    -- Match outer circle with inner circle
    self.m_OuterCircle = self.m_InnerCircle:Clone()

    -- display debug message and update clients
    self:DebugMessage()
    self:BroadcastState()
end

-- Broadcasts PhaseManager's state to all players
function PhaseManagerServer:BroadcastState(p_Player)
    local l_Duration = 0
    local l_Timer = self:GetTimer("NextSubphase")

    -- Send remaning time to complete
    if l_Timer ~= nil then l_Duration = l_Timer:Remaining() end

    local l_Data = {
        PhaseIndex = self.m_PhaseIndex,
        SubphaseIndex = self.m_SubphaseIndex,
        InnerCircle = self.m_InnerCircle:AsTable(),
        OuterCircle = self.m_OuterCircle:AsTable(),
        Duration = l_Duration
    }

    if p_Player ~= nil then
        NetEvents:SendToLocal(PhaseManagerNetEvents.UpdateState, p_Player, l_Data)
    else
        NetEvents:BroadcastLocal(PhaseManagerNetEvents.UpdateState, l_Data)
    end
end

-- Damages every player outside of the outer circle
function PhaseManagerServer:ApplyDamage()
    if self:IsIdle() then return end

    local l_Damage = self:GetCurrentPhase().Damage
    for _, l_Player in ipairs(PlayerManager:GetPlayers()) do
        if l_Player.soldier ~= nil then
            if not self.m_OuterCircle:IsInnerPoint(l_Player.soldier.transform.trans) then
                local l_NewHealth = l_Player.soldier.health - l_Damage
                l_Player.soldier.health = math.max(0, l_NewHealth)
            end
        end
    end
end

-- Starts the PhaseManager from the chat
function PhaseManagerServer:OnChat(player, recipientMask, message)
    if message == "!pmstart" then self:Start() end
end

-- Prints a debug message about the current status of PhaseManager
function PhaseManagerServer:DebugMessage()
    local l_Delay = self:GetCurrentDelay()

    -- check if PhaseManager's work is completed
    if l_Delay < 0 then
        print("PM: Completed")
        return
    end

    -- debug messages for each SubphaseType
    local l_Messages = {
        [SubphaseType.InitialDelay] = "Initial Delay",
        [SubphaseType.Waiting] = "Circle is waiting",
        [SubphaseType.Moving] = "Circle is moving"
    }

    print(string.format("PM: [%d] %s for %.2f seconds", self.m_PhaseIndex, l_Messages[self.m_SubphaseIndex], l_Delay))
end
