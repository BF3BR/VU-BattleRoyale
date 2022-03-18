---@class OOCVision
OOCVision = class "OOCVision"

---@type Logger
local m_Logger = Logger("OOCVision", false)

---@type MapVEManagerClient
local m_MapVEManager = require "Visuals/MapVEManager"

local m_OutOfCirclePreset = require "Visuals/Presets/Common/OutOfCirclePreset"
local m_OutOfCircleNightPreset = require "Visuals/Presets/Common/OutOfCircleNightPreset"

local m_OutOfCirclePresetName = "OutOfCircle"
local m_OutOfCircleNightPresetName = "OutOfCircleNight"

---@type DC
local m_OOBSoundEntityData = DC(Guid("9C1F7ED0-61F0-4987-82FA-469AD965DCAB"), Guid("0047C675-053C-4D84-860E-661555D20D27"))

function OOCVision:__init()
	---@type SoundEntity|nil
	self.m_SoundEntity = nil
end

---VEXT Shared Level:LoadResources Event
---@param p_LevelName string
---@param p_GameModeName string
---@param p_IsDedicatedServer boolean
function OOCVision:OnLevelLoadResources(p_LevelName, p_GameModeName, p_IsDedicatedServer)
	m_Logger:Write("Dispatching event to load preset " .. m_OutOfCirclePresetName .. "!")
	Events:Dispatch("VEManager:RegisterPreset", m_OutOfCirclePresetName, m_OutOfCirclePreset)

	m_Logger:Write("Dispatching event to load preset " .. m_OutOfCircleNightPresetName .. "!")
	Events:Dispatch("VEManager:RegisterPreset", m_OutOfCircleNightPresetName, m_OutOfCircleNightPreset)
end

function OOCVision:CreateSoundEntity()
	if self.m_SoundEntity ~= nil then
		return
	end

	-- oob sound resource
	local s_EntityData = m_OOBSoundEntityData:GetInstance()

	-- create sound entity
	if s_EntityData ~= nil then
		local s_Entity = EntityManager:CreateEntity(s_EntityData, LinearTransform())

		if s_Entity ~= nil then
			s_Entity:Init(Realm.Realm_Client, true)
			self.m_SoundEntity = SoundEntity(s_Entity)
		end
	end
end

---@return SoundEntity|nil
function OOCVision:GetSoundEntity()
	if self.m_SoundEntity == nil then
		self:CreateSoundEntity()
	end

	return self.m_SoundEntity
end

function OOCVision:Enable()
	if self.m_IsEnabled then
		return
	end

	-- start OOB sound
	local s_SoundEntity = self:GetSoundEntity()
	if s_SoundEntity ~= nil then
		s_SoundEntity:FireEvent("Start")
	end

	-- change VE state
	local s_CurrentPresetName = m_MapVEManager.m_CurrentMapPresetNames[m_MapVEManager.m_CurrentMapPresetIndex]
	if string.find(s_CurrentPresetName, "Night") then
		Events:Dispatch("VEManager:FadeIn", m_OutOfCircleNightPresetName, 400)
	else
		Events:Dispatch("VEManager:FadeIn", m_OutOfCirclePresetName, 400)
	end

	self.m_IsEnabled = true
end

function OOCVision:Disable()
	if not self.m_IsEnabled then
		self.m_IsEnabled = false
		return
	end

	-- stop OOB sound
	local s_SoundEntity = self:GetSoundEntity()
	if s_SoundEntity ~= nil then
		s_SoundEntity:FireEvent("Stop")
	end

	-- change VE state
	local s_CurrentPresetName = m_MapVEManager.m_CurrentMapPresetNames[m_MapVEManager.m_CurrentMapPresetIndex]
	if string.find(s_CurrentPresetName, "Night") then
		Events:Dispatch("VEManager:FadeOut", m_OutOfCircleNightPresetName, 400)
	else
		Events:Dispatch("VEManager:FadeOut", m_OutOfCirclePresetName, 400)
	end

	self.m_IsEnabled = false
end

---VEXT Shared Level:Destroy Event
function OOCVision:OnLevelDestroy()
	self:Disable()

	-- destroy sound entity
	if self.m_SoundEntity ~= nil then
		self.m_SoundEntity:Destroy()
		self.m_SoundEntity = nil
	end
end

return OOCVision()
