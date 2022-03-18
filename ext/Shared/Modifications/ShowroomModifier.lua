---@class ShowroomModifier
ShowroomModifier = class "ShowroomModifier"

local m_ShowRoomReferenceObject = DC(Guid("51D7CE33-5181-11E0-A781-B6644A4BE024"), Guid("0EF06698-B9EA-4557-AFE0-78CA4575E726"))
local m_MenuBlackCover = DC(Guid("36F339C4-C749-11E0-ABFA-BD1C98CDBFEF"), Guid("36F339C5-C749-11E0-ABFA-BD1C98CDBFEF"))
local m_CharacterBackdrop = DC(Guid("0AD4EFCA-9274-11E0-B66D-8C5A10A76E54"), Guid("0AD6284A-9274-11E0-B66D-8C5A10A76E54"))
-- local m_VEFrontEndCustomize = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("415E1F2C-07C9-4CDD-AC1D-5896DC7E414D"))
local m_Camera = DC(Guid("08F255D1-499D-4090-B114-4CE8D1B3AC65"), Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19"))

local m_VESkyComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("D8D3C91C-C829-4EBA-8C37-C49CA2540D66"))
local m_VEFogComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("12D22137-FAC1-4FD3-B7DF-6A71CC8239EA"))
local m_VEColorCorrectionComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("0340AC6F-90E8-45D8-9CA2-47EFA779B297"))
local m_VETonemapComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("0445FB43-A201-429F-A1D2-73E26769D823"))
local m_VEEnlightenComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("8813E7F6-A8A1-406B-B877-42E8DF10E0CE"))
local m_VEOutdoorLightComponentData = DC(Guid("E65B7FFD-7E1E-447D-871D-43FF2E82183C"), Guid("CCB966AF-93D4-48EC-A09D-6BF10D2F70EA"))

local m_Logger = Logger("ShowroomModifier", false)

function ShowroomModifier:RegisterCallbacks()
	m_ShowRoomReferenceObject:RegisterLoadHandler(self, self.ModifyShowRoomReferenceObject)
	m_MenuBlackCover:RegisterLoadHandler(self, self.Disable)
	m_CharacterBackdrop:RegisterLoadHandler(self, self.Disable)
	m_Camera:RegisterLoadHandler(self, self.ModifyCamera)

	m_VESkyComponentData:RegisterLoadHandler(self, self.Exclude)
	m_VEFogComponentData:RegisterLoadHandler(self, self.Exclude)
	m_VEColorCorrectionComponentData:RegisterLoadHandler(self, self.Exclude)
	m_VETonemapComponentData:RegisterLoadHandler(self, self.Exclude)
	m_VEEnlightenComponentData:RegisterLoadHandler(self, self.Exclude)
	m_VEOutdoorLightComponentData:RegisterLoadHandler(self, self.Exclude)
end

function ShowroomModifier:DeregisterCallbacks()
	m_ShowRoomReferenceObject:Deregister()
	m_MenuBlackCover:Deregister()
	m_CharacterBackdrop:Deregister()
	m_Camera:Deregister()

	m_VESkyComponentData:Deregister()
	m_VEFogComponentData:Deregister()
	m_VEColorCorrectionComponentData:Deregister()
	m_VETonemapComponentData:Deregister()
	m_VEEnlightenComponentData:Deregister()
	m_VEOutdoorLightComponentData:Deregister()
end

function ShowroomModifier:ModifyShowRoomReferenceObject(p_ReferenceObjectData)
	local s_MapId = LevelNameHelper:GetLevelName()
	if MapsConfig[s_MapId] ~= nil and MapsConfig[s_MapId]["ShowroomTransform"] ~= nil then
		p_ReferenceObjectData.blueprintTransform = MapsConfig[s_MapId]["ShowroomTransform"]
	end
end

function ShowroomModifier:Disable(p_Data)
	p_Data.enabled = false
end

function ShowroomModifier:Exclude(p_Data)
	p_Data.excluded = true
end

function ShowroomModifier:ModifyCamera(p_Data)
	p_Data.fov = 20
end

return ShowroomModifier()
