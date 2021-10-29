class "ShowroomModifier"

local m_ShowRoomReferenceObject = DC(Guid("51D7CE33-5181-11E0-A781-B6644A4BE024"), Guid("0EF06698-B9EA-4557-AFE0-78CA4575E726"))
local m_MenuBlackCover = DC(Guid("36F339C4-C749-11E0-ABFA-BD1C98CDBFEF"), Guid("36F339C5-C749-11E0-ABFA-BD1C98CDBFEF"))
local m_CharacterBackdrop = DC(Guid("0AD4EFCA-9274-11E0-B66D-8C5A10A76E54"), Guid("0AD6284A-9274-11E0-B66D-8C5A10A76E54"))
local m_VEFrontEndCustomize = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("415E1F2C-07C9-4CDD-AC1D-5896DC7E414D"))
local m_Camera = DC(Guid("08F255D1-499D-4090-B114-4CE8D1B3AC65"), Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19"))

local m_Logger = Logger("ShowroomModifier", true)

function ShowroomModifier:RegisterCallbacks()
	m_ShowRoomReferenceObject:RegisterLoadHandler(self, self.ModifyShowRoomReferenceObject)
	m_MenuBlackCover:RegisterLoadHandler(self, self.Disable)
	m_CharacterBackdrop:RegisterLoadHandler(self, self.Disable)
	m_VEFrontEndCustomize:RegisterLoadHandler(self, self.DisableVE)
	m_Camera:RegisterLoadHandler(self, self.ModifyCamera)
end

function ShowroomModifier:DeregisterCallbacks()
	m_ShowRoomReferenceObject:Deregister()
	m_MenuBlackCover:Deregister()
	m_CharacterBackdrop:Deregister()
	m_VEFrontEndCustomize:Deregister()
	m_Camera:Deregister()
end

function ShowroomModifier:ModifyShowRoomReferenceObject(p_ReferenceObjectData)
	-- TODO: We should get this from the map config
	p_ReferenceObjectData.blueprintTransform = LinearTransform(
		Vec3(-0.740595, 0.000000, 0.671952),
		Vec3(0.000000, 1.000000, 0.000000),
		Vec3(-0.671952, 0.000000, -0.740595),
		Vec3(470.017578, 173.259598, -978.172791)
	)
end

function ShowroomModifier:Disable(p_Data)
	p_Data.enabled = false
end

function ShowroomModifier:DisableVE(p_Data)
	p_Data.enabled = false
	p_Data.visibility = 0
	p_Data.priority = 999
	p_Data.components:clear()
end

function ShowroomModifier:ModifyCamera(p_Data)
	p_Data.fov = 20
end

return ShowroomModifier()
