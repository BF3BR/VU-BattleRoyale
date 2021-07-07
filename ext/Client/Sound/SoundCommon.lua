-- Big thanks to the RealityMod dev team!
-- https://github.com/BF3RM/RealityMod/blob/development/ext/Client/Sound/SoundCommon.lua

class "SoundCommon"

local m_Logger = Logger("SoundCommon", false)

local m_RemoveAutotriggerVO = require "Sound/General/RemoveAutoTriggerVO"

function SoundCommon:__init()
	m_Logger:Write("SoundCommon init.")
end

function SoundCommon:RegisterCallbacks()
	--m_RemoveAutotriggerVO:RegisterCallbacks()
end

-- Singleton.
if g_SoundCommon == nil then
    g_SoundCommon = SoundCommon()
end

return g_SoundCommon
