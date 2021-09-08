class "MapVEManager"

require "__shared/Configs/MapsConfig"
require "__shared/Utils/LevelNameHelper"

local m_Logger = Logger("MapVEManager", false)

function MapVEManager:__init()
	self:RegisterVars()
end

function MapVEManager:RegisterVars()
	self:ResetVars()
end

function MapVEManager:ResetVars()
	self.m_CurrentMapPresetNames = nil
	self.m_CurrentMapPresetIndex = 1
	--self.m_TransitionInProgress = false
end

function MapVEManager:OnLevelLoadResources()
	local m_Map = MapsConfig[LevelNameHelper:GetLevelName()]

	-- Update new map presets
	if m_Map then
		self.m_CurrentMapPresetNames = m_Map.VEPresets
	else
		m_Logger:Error("Map hasn't been loaded yet, this should never happen")
	end
end

function MapVEManager:OnLevelDestroy()
	self:ResetVars()
end

function MapVEManager:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    local m_Map = MapsConfig[LevelNameHelper:GetLevelName()]
    self:SetMapVEPreset(math.random(1, #m_Map.VEPresets))
end

function MapVEManager:SetMapVEPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
	p_OldFadeTime = p_OldFadeTime or 0
	p_NewFadeTime = p_NewFadeTime or 0

	if not self.m_CurrentMapPresetNames[p_VEIndex] then
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

function MapVEManager:OnPlayerAuthenticated(p_Player)
	if p_Player == nil then
		return
	end

	m_Logger:Write("Player " .. p_Player.name .. " joined, updating him with current preset")

	NetEvents:SendToLocal("MapVEManager:SetMapVEPreset", p_Player, self.m_CurrentMapPresetIndex)
end

return MapVEManager()
