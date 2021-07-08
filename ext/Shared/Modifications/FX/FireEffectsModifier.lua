class "FireEffectsModifier"

require "__shared/Configs/FireEffectsConfig"

local m_EmitterHelper = require "__shared/Utils/EmitterHelper"
local m_RegistryManager = require "__shared/Logic/RegistryManager"

local m_Logger = Logger("FireEffectsModifier", true)

function FireEffectsModifier:__init()
	self:RegisterVars()
end

function FireEffectsModifier:RegisterVars()
	self.m_NumberOfAddedFireEffects = 1
end

function FireEffectsModifier:RegisterCallbacks()
	for l_Index, l_Effect in ipairs(FireEffectsConfig.Effects) do
		l_Effect:RegisterLoadHandler(self, self.DisableLightComponent)
	end
end

function FireEffectsModifier:DisableLightComponent(p_EffectBlueprint)
	local s_Partition = p_EffectBlueprint.partition
    local s_Registry = m_RegistryManager:GetRegistry()

	local s_Guid = FireEffectsConfig.CustomEffectsGuid[self.m_NumberOfAddedFireEffects]
	self.m_NumberOfAddedFireEffects = self.m_NumberOfAddedFireEffects + 1

    local s_OriginalEffectBlueprint = EffectBlueprint(p_EffectBlueprint)
    local s_EffectBlueprint = s_OriginalEffectBlueprint:Clone(s_Guid)
    local s_EffectEntityData = EffectEntityData(s_EffectBlueprint.object)
    s_EffectEntityData:MakeWritable()

    for l_Index, l_Component in pairs(s_EffectEntityData.components) do
        if l_Component:Is("EmitterEntityData") then
            local l_EmitterEntityData = EmitterEntityData(l_Component)
			if l_EmitterEntityData.emitter.isLazyLoaded then
				l_EmitterEntityData.emitter:RegisterLoadHandler({s_EffectEntityData, l_Index}, function(p_Table, p_Instance)
					local l_EmitterDocument = EmitterDocument(l_EmitterEntityData.emitter)
					if l_EmitterDocument.templateData ~= nil then
						local l_EmitterTemplateData = EmitterTemplateData(l_EmitterDocument.templateData)
						l_EmitterTemplateData:MakeWritable()
						l_EmitterTemplateData.name = "BattleRoyale/FX/AmbGenericFire_" .. tostring(l_Index)
						l_EmitterTemplateData.killParticlesWithEmitter = false
						l_EmitterTemplateData.actAsPointLight = false
					end

					p_Table[1].components:erase(p_Table[2])
					p_Table[1].components:insert(p_Table[2], l_EmitterEntityData)
				end)
			else
				local l_EmitterDocument = EmitterDocument(l_EmitterEntityData.emitter)
				if l_EmitterDocument.templateData ~= nil then
					local l_EmitterTemplateData = EmitterTemplateData(l_EmitterDocument.templateData)
					l_EmitterTemplateData:MakeWritable()
					l_EmitterTemplateData.name = "BattleRoyale/FX/AmbGenericFire_" .. tostring(l_Index)
					l_EmitterTemplateData.killParticlesWithEmitter = false
					l_EmitterTemplateData.actAsPointLight = false
				end

				s_EffectEntityData.components:erase(l_Index)
				s_EffectEntityData.components:insert(l_Index, l_EmitterEntityData)
			end
        elseif l_Component:Is("VisualEnvironmentEffectEntityData") then
            s_EffectEntityData.components:erase(l_Index)
        end
    end

    s_Registry.blueprintRegistry:add(s_EffectBlueprint)
    s_Registry.entityRegistry:add(s_EffectBlueprint.object)

    s_Partition:AddInstance(s_EffectBlueprint)

	m_Logger:Write("Custom effect bp created")
end

if g_FireEffectsModifier == nil then
	g_FireEffectsModifier = FireEffectsModifier()
end

return g_FireEffectsModifier
