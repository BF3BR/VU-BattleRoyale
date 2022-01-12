---@class WeaponDropModifier
WeaponDropModifier = class "WeaponDropModifier"

local m_Logger = Logger("WeaponDropModifier", false)

-- =============================================
-- Callbacks
-- =============================================

-- Replace vanilla DropWeaponComponentData (drops a kit) with 5 DropWeaponComponentDatas that all drop a weapon
function WeaponDropModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	-- Update runtimeComponentCount (the client will crash if this is wrong), erasing 1 component
	local s_SoldierEntityData = SoldierEntityData(p_SoldierBlueprint.object)
	s_SoldierEntityData:MakeWritable()
	s_SoldierEntityData.runtimeComponentCount = s_SoldierEntityData.runtimeComponentCount - 1

	local s_SoldierBodyComponent = SoldierBodyComponentData(s_SoldierEntityData.components[1])
	s_SoldierBodyComponent:MakeWritable()
	-- Erase the kit DropWeaponComponent
	s_SoldierBodyComponent.components:erase(11)

	m_Logger:Write("WeaponDropComponents removed from SoldierBlueprint")
end

return WeaponDropModifier()
