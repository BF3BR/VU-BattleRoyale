-- Big thanks to the RealityMod dev team!
-- https://github.com/BF3RM/RealityMod/blob/development/ext/Client/Sound/SoundCommon.lua

class "SoundCommon"

local m_Logger = Logger("SoundCommon", false)

local m_RemoveAutotriggerVO = require "Sound/General/RemoveAutoTriggerVO"

function SoundCommon:__init()
	m_Logger:Write("SoundCommon init.")
end

function SoundCommon:OnInstanceLoaded(p_Partition, p_Instance)
	m_RemoveAutotriggerVO:OnInstanceLoaded(p_Partition, p_Instance)
end

-- Singleton.
if g_SoundCommon == nil then
    g_SoundCommon = SoundCommon()
end

return g_SoundCommon
