-- Big thanks to the RealityMod dev team!
-- https://github.com/BF3RM/RealityMod/blob/development/ext/Client/Sound/General/RemoveAutoTriggerVO.lua

class "RemoveAutoTriggerVO"

local m_Logger = Logger("RemoveAutoTriggerVO", false)

local m_AutoTriggersMP_VoiceOverLogicAsset = DC(Guid("0663E4AE-5E2A-4512-9012-F80C426A40E4"), Guid("7814D619-FF54-4E6C-8E30-E850A4D55959"))
local m_ComRose_VoiceOverLogicAsset = DC(Guid("BF876C50-4FFB-11E0-BB5C-96166BF39E10"), Guid("CA084EB9-BE72-B3BA-0D73-AAEC80C1CB91"))

function RemoveAutoTriggerVO:__init()
	m_Logger:Write("RemoveAutoTriggerVO initializing")
end

function RemoveAutoTriggerVO:RegisterCallbacks()
	m_AutoTriggersMP_VoiceOverLogicAsset:RegisterLoadHandler(self, self.OnVoiceOverLogicAsset)
	m_ComRose_VoiceOverLogicAsset:RegisterLoadHandler(self, self.OnVoiceOverLogicAsset)
end

function RemoveAutoTriggerVO:OnVoiceOverLogicAsset(p_VoiceOverLogicAsset)
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
