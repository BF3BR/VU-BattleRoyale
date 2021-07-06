-- Big thanks to the RealityMod dev team!
-- https://github.com/BF3RM/RealityMod/blob/development/ext/Client/Sound/General/RemoveAutoTriggerVO.lua

class "RemoveAutoTriggerVO"

local m_Logger = Logger("RemoveAutoTriggerVO", false)

function RemoveAutoTriggerVO:__init()
	m_Logger:Write("RemoveAutoTriggerVO initializing")
	self:RegisterVars()
end

function RemoveAutoTriggerVO:RegisterVars()
	self.m_AutoTriggersMP_VoiceOverLogicAsset_Guid = Guid("7814D619-FF54-4E6C-8E30-E850A4D55959", "D")
	self.m_ComRose_VoiceOverLogicAsset_Guid = Guid("CA084EB9-BE72-B3BA-0D73-AAEC80C1CB91", "D")
end

function RemoveAutoTriggerVO:OnInstanceLoaded(p_Partition, p_Instance)
	if p_Instance.instanceGuid == self.m_AutoTriggersMP_VoiceOverLogicAsset_Guid or
		p_Instance.instanceGuid == self.m_ComRose_VoiceOverLogicAsset_Guid then
		self:ClearEventsArray(p_Instance)
	end

	-- if p_Instance.typeInfo.name ~= "SoundWaveAsset" then
	-- 	return
	-- end

	-- local s_SoundWaveAsset = SoundWaveAsset(p_Instance)
	-- local s_SoundWaveAssetName = s_SoundWaveAsset.name

	-- if s_SoundWaveAssetName:startsWith("Sound/VO/Common/RU") or
	-- 	s_SoundWaveAssetName:startsWith("Sound/VO/EN") then
	-- 		s_SoundWaveAsset.variations:clear()
	-- end
end

function RemoveAutoTriggerVO:ClearEventsArray(p_VoiceOverLogicAsset)
	local s_VoiceOverLogicAsset = VoiceOverLogicAsset(p_VoiceOverLogicAsset)
	s_VoiceOverLogicAsset:MakeWritable()

	s_VoiceOverLogicAsset.events:clear()
	s_VoiceOverLogicAsset.groups:clear()
	s_VoiceOverLogicAsset.flows:clear()
	m_Logger:Write("Removed automatic VoiceOver / Shoutouts")
end

-- Singleton.
if g_RemoveAutoTriggerVO == nil then
    g_RemoveAutoTriggerVO = RemoveAutoTriggerVO()
end

return g_RemoveAutoTriggerVO
