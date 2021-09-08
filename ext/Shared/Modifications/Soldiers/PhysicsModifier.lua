class "PhysicsModifier"

local m_InAirStateData = DC(Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"), Guid("584D7B54-FBFE-4755-8AD4-89065EEB45C3"))
local m_StandPoseInfo = DC(Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"), Guid("6F1DD196-9B9C-4538-B128-71BC14835652"))
local m_CrouchPoseInfo = DC(Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"), Guid("CC8C3596-EEC5-4959-A644-8E5D5677CE15"))
local m_PronePoseInfo = DC(Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"), Guid("64357471-E246-4FCD-B0EF-6F693FA98D71"))

function PhysicsModifier:RegisterCallbacks()
	m_InAirStateData:RegisterLoadHandler(self, self.OnInAirStateDataLoaded)
	m_StandPoseInfo:RegisterLoadHandler(self, self.OnCharacterStatePoseInfoLoaded)
	m_CrouchPoseInfo:RegisterLoadHandler(self, self.OnCharacterStatePoseInfoLoaded)
	m_PronePoseInfo:RegisterLoadHandler(self, self.OnCharacterStatePoseInfoLoaded)
end

function PhysicsModifier:DeregisterCallbacks()
	m_InAirStateData:Deregister()
	m_StandPoseInfo:Deregister()
	m_CrouchPoseInfo:Deregister()
	m_PronePoseInfo:Deregister()
end

-- Change the free fall velocity so free fall state kicks in later
function PhysicsModifier:OnInAirStateDataLoaded(p_InAirStateData)
	p_InAirStateData.freeFallVelocity = 20.0
end

-- Modify the free fall velocity
function PhysicsModifier:OnCharacterStatePoseInfoLoaded(p_CharacterStatePoseInfo)
	p_CharacterStatePoseInfo.velocity = 25.0
	p_CharacterStatePoseInfo.accelerationGain = 0.1
end

return PhysicsModifier()
