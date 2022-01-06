---@class XP5_003_ObjectModifications
XP5_003_ObjectModifications = class 'XP5_003_ObjectModifications'

local m_Tent_01_Mesh = DC(Guid('7399C5F9-F745-522F-1A75-8C235D9DF360'), Guid('E3E4DD13-7444-549D-167B-758EF57B24BB'))
local m_Bulkhead_01_Mesh = DC(Guid('BC838068-4D37-43D6-FCE2-D632D08459CC'), Guid('4A9E53C7-0A3B-11DE-B857-DBBDD7D66D76'))
local m_PowerLine_01B_BrokenBase_Mesh = DC(Guid('1E857D81-FFDF-1EBC-D6F2-082F304F5809'), Guid('AB778B7A-AE12-98BC-5733-90A64F29EFFF'))
local m_FX_DLC3_XP3_Shield_Pollen_CamProx = DC(Guid('381A69CF-695D-4055-B0AD-5218711E3411'), Guid('A24EEEDF-FCF3-46EA-804F-765657A612DE'))
local m_FX_DLC3_XP3_Shield_Pollen_CamProx_02 = DC(Guid('0C1ECED7-AA15-4206-A62F-7D44FE153E3C'), Guid('401F99D9-3093-4F1E-9B23-498C634B9BF5'))
local m_FX_DLC3_XP3_Shield_Pollen_CamProx_03 = DC(Guid('5F470049-4215-4E97-B07E-BA422A57C14C'), Guid('657F2376-0B99-4C78-9024-C7FB74C3C3A0'))
local m_MEC_House_Low_02_V2 = DC(Guid('855DE702-7FA6-11E0-8E76-FC4E665E8C40'), Guid('55E12A0D-C4CC-CF7F-E360-6405B210974A'))
local m_ME_House01_Garage_Destruction = DC(Guid('4C8CED09-9BDE-11E0-A396-819D693420B6'), Guid('4FD89229-7326-6148-92C3-AA6750C1BC2C'))
local m_XP5_003_30_StaticModelEntityData = DC(Guid('CB9932E2-19E0-11E2-93EC-B0D4179CEA18'), Guid('B880E9F7-53E2-F2FB-ADA2-C2E5CEF52751'))


function XP5_003_ObjectModifications:RegisterCallbacks()
	m_Tent_01_Mesh:RegisterLoadHandlerOnce(self, self.OnTent01Mesh)
	m_Bulkhead_01_Mesh:RegisterLoadHandlerOnce(self, self.OnBulkhead01Mesh)
	m_PowerLine_01B_BrokenBase_Mesh:RegisterLoadHandlerOnce(self, self.OnPowerLine01BBrokenBaseMesh)
	m_FX_DLC3_XP3_Shield_Pollen_CamProx:RegisterLoadHandlerOnce(self, self.OnFXDLC3XP3ShieldPollenCamProx)
	m_FX_DLC3_XP3_Shield_Pollen_CamProx_02:RegisterLoadHandlerOnce(self, self.OnFXDLC3XP3ShieldPollenCamProx02)
	m_FX_DLC3_XP3_Shield_Pollen_CamProx_03:RegisterLoadHandlerOnce(self, self.OnFXDLC3XP3ShieldPollenCamProx03)
	m_MEC_House_Low_02_V2:RegisterLoadHandlerOnce(self, self.OnMECHouseLow02V2)
	m_ME_House01_Garage_Destruction:RegisterLoadHandlerOnce(self, self.OnMEHouse01GarageDestruction)
	m_XP5_003_30_StaticModelEntityData:RegisterLoadHandlerOnce(self, self.OnRemoveHavokAssets)
end

function XP5_003_ObjectModifications:DeregisterCallbacks()
	m_Tent_01_Mesh:Deregister()
	m_Bulkhead_01_Mesh:Deregister()
	m_PowerLine_01B_BrokenBase_Mesh:Deregister()
	m_FX_DLC3_XP3_Shield_Pollen_CamProx:Deregister()
	m_FX_DLC3_XP3_Shield_Pollen_CamProx_02:Deregister()
	m_FX_DLC3_XP3_Shield_Pollen_CamProx_03:Deregister()
	m_MEC_House_Low_02_V2:Deregister()
	m_ME_House01_Garage_Destruction:Deregister()
	m_XP5_003_30_StaticModelEntityData:Deregister()
end

-- =============================================
-- Cull Distance & Lod
-- =============================================

function XP5_003_ObjectModifications:OnTent01Mesh(p_CompositeMeshAsset)
	p_CompositeMeshAsset.cullScale = 50.0
end

function XP5_003_ObjectModifications:OnBulkhead01Mesh(p_RigidMeshAsset)
	p_RigidMeshAsset.cullScale = 50.0
end

function XP5_003_ObjectModifications:OnPowerLine01BBrokenBaseMesh(p_RigidMeshAsset)
	p_RigidMeshAsset.cullScale = 50.0
	p_RigidMeshAsset.lodScale = 3.0
end

function XP5_003_ObjectModifications:OnFXDLC3XP3ShieldPollenCamProx(p_EffectEntityData)
	p_EffectEntityData.cullDistance = 10000000.0
	p_EffectEntityData.maxInstanceCount = 100
end

function XP5_003_ObjectModifications:OnFXDLC3XP3ShieldPollenCamProx02(p_EffectEntityData)
	p_EffectEntityData.cullDistance = 10000000.0
	p_EffectEntityData.maxInstanceCount = 100
end

function XP5_003_ObjectModifications:OnFXDLC3XP3ShieldPollenCamProx03(p_EffectEntityData)
	p_EffectEntityData.cullDistance = 10000000.0
	p_EffectEntityData.maxInstanceCount = 100
end

-- =============================================
-- Disable destruction on X assets
-- =============================================

function XP5_003_ObjectModifications:OnMECHouseLow02V2(p_ObjectBlueprint)
	for _, l_Instance in pairs(p_ObjectBlueprint.partition.instances) do
		if l_Instance:Is("BreakablePartComponentData") then
			l_Instance = BreakablePartComponentData(l_Instance)
			l_Instance:MakeWritable()
			l_Instance.healthPercentage = 10000000
		end
	end
end

function XP5_003_ObjectModifications:OnMEHouse01GarageDestruction(p_ObjectBlueprint)
	for _, l_Instance in pairs(p_ObjectBlueprint.partition.instances) do
		if l_Instance:Is("BreakablePartComponentData") then
			l_Instance = BreakablePartComponentData(l_Instance)
			l_Instance:MakeWritable()
			l_Instance.healthPercentage = 10000000
		end
	end
end

function XP5_003_ObjectModifications:OnRemoveHavokAssets(p_StaticModelGroupEntityData)
	p_StaticModelGroupEntityData.enabled = false
	p_StaticModelGroupEntityData.memberDatas:clear()
end

return XP5_003_ObjectModifications()
