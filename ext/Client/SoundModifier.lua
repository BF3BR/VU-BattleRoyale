class "SoundModifier"

local m_Logger = Logger("SoundModifier", false)

function SoundModifier:__init()
	self.m_WeaponAttenuationMultipliers = {
		{Distance = 8, Gain = 8},
		{Distance = 8, Gain = 8},
		{Distance = 4, Gain = 4},
		{Distance = 1.4, Gain = 1.4},
		{Distance = 1.3, Gain = 1.3},
		{Distance = 1.7, Gain = 1.7},
	}

	self.m_WeaponMaxDistanceMultiplier = 3
	self.m_WeaponMinDistanceMultiplier = 3

	self.m_AirVehiclesAttenuationMultipliers = {
		{Distance = 4, Gain = 4},
		{Distance = 3, Gain = 3},
		{Distance = 2, Gain = 2},
		{Distance = 1.3, Gain = 1.3},
		{Distance = 1.2, Gain = 1.2},
		{Distance = 1, Gain = 1},
	}

	self.m_AirVehicleMaxDistanceMultiplier = 3
	self.m_AirVehicleMinDistanceMultiplier = 3

	self.m_BulletImpactMinDistanceMultiplier = 5
	self.m_BulletImpactMaxDistanceMultiplier = 5

	self.m_WeaponNames = {
		"assaultrifle",
		"sniper",
		"lmg",
		"carbine",
		"smg",
		"shotgun",
		"pistol",
		"hmg_mounted"
	}

	self.m_AirVehicleSoundNodesToIgnore = {
		"Turbine",
		"Bwd Engine"
	}

	self.m_GunSoundNodesToIgnore = {
		"Handling"
	}

	self.m_AirVehicles = {
		"uh1",
        "c130"
	}
end

function SoundModifier:OnPartitionLoaded(p_Partition)
	if p_Partition == nil then
		return
	end

	if p_Partition.primaryInstance:Is("SoundPatchAsset") then
		--NOTE: Comment this out to remove gun sound mods
		self:ModifyWeaponSounds(SoundPatchAsset(p_Partition.primaryInstance))
		self:ModifyBulletImpactSounds(SoundPatchAsset(p_Partition.primaryInstance))
		self:ModifyAirVehicleSounds(SoundPatchAsset(p_Partition.primaryInstance))
	end
end

function SoundModifier:IsSoundPatchAssetForGun(p_SoundPatchAsset)
	local s_Name = p_SoundPatchAsset.name:lower()

	for _, l_WeaponName in pairs(self.m_WeaponNames) do
		if string.find(s_Name, l_WeaponName) then
			return true
		end
	end

	return false
end

function SoundModifier:IsSoundPatchAssetForAirVehicles(p_SoundPatchAsset)
	local s_Name = p_SoundPatchAsset.name:lower()

	for _, l_VehicleName in pairs(self.m_AirVehicles) do
		if string.find(s_Name, l_VehicleName) then
			return true
		end
	end

	return false
end

function SoundModifier:IsSoundPatchAssetForBulletImpact(p_SoundPatchAsset)
	local s_Name = p_SoundPatchAsset.name:lower()

	return string.find(s_Name, "bullet_impact")
end

function SoundModifier:ModifyAirVehicleSounds(p_SoundPatchAsset)
	if self:IsSoundPatchAssetForAirVehicles(p_SoundPatchAsset) then
		m_Logger:Write("Found sound for air vehicles")
		self:ModifySoundPatchAsset(p_SoundPatchAsset, self.m_AirVehiclesAttenuationMultipliers, self.m_AirVehicleMinDistanceMultiplier, self.m_AirVehicleMaxDistanceMultiplier, self.m_AirVehicleSoundNodesToIgnore)
	end
end

function SoundModifier:ModifyWeaponSounds(p_SoundPatchAsset)
	if self:IsSoundPatchAssetForGun(p_SoundPatchAsset) then
		m_Logger:Write("Found sound for gun")
		self:ModifySoundPatchAsset(p_SoundPatchAsset, self.m_WeaponAttenuationMultipliers, self.m_WeaponMinDistanceMultiplier, self.m_WeaponMaxDistanceMultiplier, self.m_GunSoundNodesToIgnore)
	end
end

function SoundModifier:ModifyBulletImpactSounds(p_SoundPatchAsset)
	if self:IsSoundPatchAssetForBulletImpact(p_SoundPatchAsset) then
		m_Logger:Write("Found sound for bullet impact")
		self:ModifySoundPatchAsset(p_SoundPatchAsset, nil, self.m_BulletImpactMinDistanceMultiplier, self.m_BulletImpactMaxDistanceMultiplier, nil)
	end
end

function SoundModifier:ModifySoundPatchAsset(p_SoundPatchAsset, p_AttenuationMultipliers, p_MinDistanceMultiplier, p_MaxDistanceMultiplier, p_NodesToIgnore)
	-- Seems like the instance itself doesn't get modified at all, so no need to make it writable
	--p_SoundPatchAsset:MakeWritable()

	for _, l_Node in pairs(p_SoundPatchAsset.outputNodes) do
		l_Node = _G[l_Node.typeInfo.name](l_Node)
		l_Node:MakeWritable()

		if p_NodesToIgnore == nil or not self:ShouldNodeBeIgnored(l_Node.outputName, p_NodesToIgnore) then
			l_Node.minDistance = l_Node.minDistance * p_MinDistanceMultiplier

			--Unsure if all audio output nodes contain an attenuationCurve, so better safe than sorry
			if l_Node['attenuationCurve'] and p_AttenuationMultipliers ~= nil then
				for l_CurveKey, l_Curve in pairs(l_Node.attenuationCurve.points) do
					local s_Multiplier = p_AttenuationMultipliers[l_CurveKey]

					if s_Multiplier == nil then
						s_Multiplier = {Distance = 1, Gain = 1}
					end

					--Make louder
					l_Curve.y = l_Curve.y / s_Multiplier.Gain

					--Increase distance
					l_Curve.x = l_Curve.x * s_Multiplier.Distance

					m_Logger:Write('\nKey: ' .. l_CurveKey .. '\nDist Multi: ' .. s_Multiplier.Distance .. '\n Gain Multi: ' .. s_Multiplier.Gain .. '\nX: ' .. l_Curve.x .. '\nY: ' .. l_Curve.y)
				end
			end
		end
	end

	local s_AudioGraph = SoundGraphData(p_SoundPatchAsset.graph)
	s_AudioGraph:MakeWritable()

	--Increase maximum audibility distance
	for _, l_Node in pairs(s_AudioGraph.nodes) do
		if l_Node:Is("MultiCrossfaderNodeData") then
			l_Node = MultiCrossfaderNodeData(l_Node)
			l_Node:MakeWritable()

			for _, l_Group in pairs(l_Node.crossfaderGroups) do
				l_Group = MultiCrossfaderGroup(l_Group)
				l_Group:MakeWritable()
				l_Group.fadeEnd = l_Group.fadeEnd * p_MaxDistanceMultiplier
				m_Logger:Write('\nFadeStart: ' .. l_Group.fadeBegin .. '\nFadeEnd: ' .. l_Group.fadeEnd)
			end
		end
	end
end

function SoundModifier:ShouldNodeBeIgnored(p_NodeName, p_IgnoreList)
	for l_Index, l_Value in ipairs(p_IgnoreList) do
		if p_NodeName == l_Value then
			return true
		end
	end

	return false
end

return SoundModifier()
