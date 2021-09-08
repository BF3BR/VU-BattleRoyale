class 'AntiCheat'

function AntiCheat:__init()
	self.m_GunSwayTimer = 0
	self.m_EngineTimer = 0
end

-- =============================================
-- Events
-- =============================================

function AntiCheat:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	if p_WeaponFiring == nil then
		return
	end

	self.m_GunSwayTimer = self.m_GunSwayTimer + p_DeltaTime

	if self.m_GunSwayTimer < 15 then
		return
	end

	self.m_GunSwayTimer = 0

	if p_GunSway.currentGameplayDeviationScaleFactor < 1.0 or p_GunSway.currentVisualDeviationScaleFactor < 1.0 then
		NetEvents:SendLocal('Cheat', {"No Spread/ No Recoil 1", p_GunSway.currentGameplayDeviationScaleFactor, p_GunSway.currentVisualDeviationScaleFactor, p_GunSway.data.instanceGuid})
	end

	if GunSwayData(p_GunSway.data).gameplayDeviationScaleFactorNoZoom < 1.0 or GunSwayData(p_GunSway.data).gameplayDeviationScaleFactorZoom < 1.0 or GunSwayData(p_GunSway.data).deviationScaleFactorNoZoom < 1.0 or GunSwayData(p_GunSway.data).deviationScaleFactorZoom < 1.0 then
		NetEvents:SendLocal('Cheat', {"No Spread/ No Recoil 2", GunSwayData(p_GunSway.data).gameplayDeviationScaleFactorNoZoom, GunSwayData(p_GunSway.data).gameplayDeviationScaleFactorZoom, GunSwayData(p_GunSway.data).deviationScaleFactorNoZoom, GunSwayData(p_GunSway.data).deviationScaleFactorZoom, p_GunSway.data.instanceGuid})
	end

	local s_WeaponFiringData = WeaponFiringData(p_WeaponFiring.data)

	if s_WeaponFiringData.primaryFire == nil then
		return
	end

	if not p_Weapon.data:Is('SoldierWeaponData') then
		return
	end

	p_Weapon = SoldierWeapon(p_Weapon)

	if ShotConfigData(FiringFunctionData(s_WeaponFiringData.primaryFire).shot).projectileData:Is('BulletEntityData') then
		local s_BulletEntityData = BulletEntityData(ShotConfigData(FiringFunctionData(s_WeaponFiringData.primaryFire).shot).projectileData)

		if p_Weapon.weaponModifier.weaponProjectileModifier ~= nil and p_Weapon.weaponModifier.weaponProjectileModifier.projectileData ~= nil then
			s_BulletEntityData = BulletEntityData(p_Weapon.weaponModifier.weaponProjectileModifier.projectileData)
		elseif p_Weapon.weaponModifier.weaponFiringDataModifier ~= nil and p_Weapon.weaponModifier.weaponFiringDataModifier.weaponFiring ~= nil then
			s_BulletEntityData = BulletEntityData(WeaponFiringData(p_Weapon.weaponModifier.weaponFiringDataModifier.weaponFiring).primaryFire.shot.projectileData)
		end

		if s_BulletEntityData.instantHit == true and s_BulletEntityData.instanceGuid ~= Guid('61D16421-B5B1-4FD7-81E5-2AE21FA0BAEE') and s_BulletEntityData.instanceGuid ~= Guid('BDBFA354-1B1E-4AD3-8826-D7BA1C0C3287') and s_BulletEntityData.instanceGuid ~= Guid('DDE585ED-C043-48E3-A023-C73D549D8F6E') and s_BulletEntityData.instanceGuid ~= Guid('1861554A-8C81-4944-96D1-7347494F7688') and s_BulletEntityData.instanceGuid ~= Guid('71CB722D-BF79-4B6F-858F-95D107C49B36') and s_BulletEntityData.instanceGuid ~= Guid('A075A428-1D08-40C2-A985-2DA85A80B20B') then
			NetEvents:SendLocal('Cheat', {"Instant Bullet 6", s_BulletEntityData.instanceGuid})
		end
	end
end

function AntiCheat:OnEngineUpdate(p_DeltaTime)
	self.m_EngineTimer = self.m_EngineTimer + p_DeltaTime

	if self.m_EngineTimer >= 15 then
		self.m_EngineTimer = 0
		local s_VeniceFPSCameraData = ResourceManager:FindInstanceByGuid(Guid('F256E142-C9D8-4BFE-985B-3960B9E9D189'), Guid('A988B874-7307-49F8-8D18-30A68DDBC3F3'))

		if s_VeniceFPSCameraData == nil then
			goto continue
		end

		s_VeniceFPSCameraData = VeniceFPSCameraData(s_VeniceFPSCameraData)

		if s_VeniceFPSCameraData.suppressionBlurAmountMultiplier < 0.8 or s_VeniceFPSCameraData.suppressionBlurSizeMultiplier < 1.0 then
			NetEvents:SendLocal('Cheat', {"No Suppression 1", s_VeniceFPSCameraData.suppressionBlurAmountMultiplier, s_VeniceFPSCameraData.suppressionBlurSizeMultiplier})
		end

		::continue::
		local s_SoldierSuppressionComponentData = ResourceManager:FindInstanceByGuid(Guid('F256E142-C9D8-4BFE-985B-3960B9E9D189'), Guid('5ECC8031-8DF7-4A38-ACC7-9EFC730B3528'))

		if s_SoldierSuppressionComponentData == nil then
			goto continue2
		end

		s_SoldierSuppressionComponentData = SoldierSuppressionComponentData(s_SoldierSuppressionComponentData)

		if s_SoldierSuppressionComponentData.suppressionSphereRadius < 1.5 or s_SoldierSuppressionComponentData.fallOffDelay > 2 or s_SoldierSuppressionComponentData.suppressionAbortsHealthRegeneration == false or SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionHighThreshold > 0.4001 or SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionLowThreshold > 0.3001 or SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionUIThreshold > 0.15001 then
			NetEvents:SendLocal('Cheat', {"No Suppression 2", s_SoldierSuppressionComponentData.suppressionSphereRadius, s_SoldierSuppressionComponentData.fallOffDelay, s_SoldierSuppressionComponentData.suppressionAbortsHealthRegeneration, SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionHighThreshold, SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionLowThreshold, SuppressionReactionData(s_SoldierSuppressionComponentData.reactionToSuppression).suppressionUIThreshold})
		end

		::continue2::
		local s_DebugRenderSettings = ResourceManager:GetSettings('DebugRenderSettings')

		if s_DebugRenderSettings == nil or ServerConfig.Debug.EnableLootPointSpheres then
			return
		end

		s_DebugRenderSettings = DebugRenderSettings(s_DebugRenderSettings)

		if s_DebugRenderSettings.enable and not ServerConfig.Debug.EnableDebugRenderer and not ServerConfig.Debug.EnableLootPointSpheres then
			NetEvents:SendLocal('Cheat', {"Wallhack"})
		end
	end
end

function AntiCheat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	if p_Channel == ChatChannelType.CctAdmin and p_PlayerId ~= 0 then
		if PlayerManager:GetLocalPlayer() == PlayerManager:GetPlayerById(p_PlayerId) then
			NetEvents:SendLocal('Cheat', {"Chat Hack"})
		end

		p_HookCtx:Return()
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

NetEvents:Subscribe('Verify', function()
	NetEvents:SendLocal('Cheat', {"Verify"})
	-- NetEvents:SendLocal('Debug', {"Verify"})
end)

return AntiCheat()
