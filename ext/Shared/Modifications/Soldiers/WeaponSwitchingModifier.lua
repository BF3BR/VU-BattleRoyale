class "WeaponSwitchingModifier"

local m_SoldierWeaponSwitchingData = DC(Guid("9942F328-35C1-11DF-9556-FDADABD0ADCC"), Guid("FE76DD4D-CA25-2382-1ACB-40117A0AC957"))

function WeaponSwitchingModifier:__init()

end

function WeaponSwitchingModifier:RegisterCallbacks()
    m_SoldierWeaponSwitchingData:RegisterLoadHandler(self, self.OnSoldierWeaponSwitchingData)
end

function WeaponSwitchingModifier:OnSoldierWeaponSwitchingData(p_WeaponSwitchingData)
    -- add EIASwitchPrimaryWeapon from Slot0 to Slot9 if there is no weapon in Slot1
    p_WeaponSwitchingData.switchMap[1].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot1 to Slot9 if there is no weapon in Slot0
    p_WeaponSwitchingData.switchMap[7].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot2 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[13].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot3 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[19].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot4 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[25].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot5 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[31].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot6 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[37].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot7 to Slot9 if there is no weapon in Slot0 and Slot1
    p_WeaponSwitchingData.switchMap[43].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- EIASwitchPrimaryWeapon from Slot8 to Slot0 or Slot1
    p_WeaponSwitchingData.switchMap:add(WeaponSwitchingMapData())
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].fromWeapon = WeaponSwitchingEnum.wsSlot8
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].action = EntryInputActionEnum.EIASwitchPrimaryWeapon
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot0)
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot1)
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].fireAndSwitchBackToPrev = false
    -- EIASwitchPrimaryWeapon from Slot9 to Slot0 or Slot1
    p_WeaponSwitchingData.switchMap:add(WeaponSwitchingMapData())
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].fromWeapon = WeaponSwitchingEnum.wsSlot9
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].action = EntryInputActionEnum.EIASwitchPrimaryWeapon
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot0)
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot1)
    p_WeaponSwitchingData.switchMap[#p_WeaponSwitchingData.switchMap].fireAndSwitchBackToPrev = false
end

if g_WeaponSwitchingModifier == nil then
    g_WeaponSwitchingModifier = WeaponSwitchingModifier()
end

return g_WeaponSwitchingModifier
