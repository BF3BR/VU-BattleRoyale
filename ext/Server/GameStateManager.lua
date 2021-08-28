class 'GameStateManager'

local m_Logger = Logger("GameStateManager", true)

function GameStateManager:__init()
	self.m_GameState = GameStates.None
end

function GameStateManager:SetGameState(p_GameState)
	if p_GameState < GameStates.None or p_GameState > GameStates.EndGame then
		m_Logger:Error("Attempted to switch to an invalid gamestate.")
		return
	end

	if p_GameState == self.m_GameState then
		m_Logger:Warning("Attempted to switch to the same gamestate.")
		return
	end

	-- Reset tickets for CQL
	TicketManager:SetTicketCount(TeamId.Team1, 999)
	TicketManager:SetTicketCount(TeamId.Team2, 999)

	m_Logger:Write("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])

	local s_OldGameState = self.m_GameState
	self.m_GameState = p_GameState

	-- Dispatch the gamestate changes
	Events:DispatchLocal(PlayerEvents.GameStateChanged, s_OldGameState, p_GameState)

	-- Broadcast the gamestate changes to the clients
	NetEvents:Broadcast(PlayerEvents.GameStateChanged, s_OldGameState, p_GameState)
end

function GameStateManager:GetGameState()
	return self.m_GameState
end

function GameStateManager:IsGameState(p_GameState)
	return self.m_GameState == p_GameState
end

if g_GameStateManager == nil then
	g_GameStateManager = GameStateManager()
end

return g_GameStateManager
