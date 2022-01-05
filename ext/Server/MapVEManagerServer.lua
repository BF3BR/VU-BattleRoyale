---@class MapVEManagerServer
MapVEManagerServer = class "MapVEManagerServer"

---@type Logger
local m_Logger = Logger("MapVEManagerServer", false)

function MapVEManagerServer:__init()
	self:RegisterVars()
end

function MapVEManagerServer:RegisterVars()
	self:ResetVars()
end

function MapVEManagerServer:ResetVars()
	self.m_CurrentMapPresetNames = nil
	self.m_CurrentMapPresetIndex = 1
	--self.m_TransitionInProgress = false
end

---VEXT Shared Extension:Loaded Event
function MapVEManagerServer:OnLevelLoadResources()
	local m_Map = MapsConfig[LevelNameHelper:GetLevelName()]

	-- Update new map presets
	if m_Map then
		self.m_CurrentMapPresetNames = m_Map.VEPresets
	else
		m_Logger:Error("Map hasn't been loaded yet, this should never happen")
	end
end

---VEXT Shared Level:Destroy Event
function MapVEManagerServer:OnLevelDestroy()
	self:ResetVars()
end

---VEXT Server Level:Loaded Event
---@param p_LevelName string
---@param p_GameMode string
---@param p_Round integer
---@param p_RoundsPerMap integer
function MapVEManagerServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    local m_Map = MapsConfig[LevelNameHelper:GetLevelName()]

	if m_Map == nil or m_Map.VEPresets == nil or #m_Map.VEPresets == 0 then
		return
	end

    self:SetMapVEPreset(math.random(1, #m_Map.VEPresets))
end

---@param p_VEIndex integer
---@param p_OldFadeTime number
---@param p_NewFadeTime number
function MapVEManagerServer:SetMapVEPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
	p_OldFadeTime = p_OldFadeTime or 0.0
	p_NewFadeTime = p_NewFadeTime or 0.0

	if self.m_CurrentMapPresetNames == nil or not self.m_CurrentMapPresetNames[p_VEIndex] then
		m_Logger:Warning("Tried setting a map VE preset that doesn't exist, id: " .. p_VEIndex)
		return
	end

	m_Logger:Write("Requested map VE preset change, " .. self.m_CurrentMapPresetNames[p_VEIndex])

	-- Ignore if preset is the current one.
	if self.m_CurrentMapPresetIndex == p_VEIndex then
		m_Logger:Write("Ignored preset change because it's currently enabled")
		return
	end

	self.m_CurrentMapPresetIndex = p_VEIndex
	NetEvents:BroadcastLocal("MapVEManager:SetMapVEPreset", p_VEIndex, p_OldFadeTime, p_NewFadeTime)
end

---VEXT Server Player:Created Event
---@param p_Player Player
function MapVEManagerServer:OnPlayerCreated(p_Player)
	m_Logger:Write("Player " .. p_Player.name .. " joined, updating him with current preset")

	NetEvents:SendToLocal("MapVEManager:SetMapVEPreset", p_Player, self.m_CurrentMapPresetIndex)
end

return MapVEManagerServer()
