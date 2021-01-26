class 'OOBVision'

function OOBVision:__init()
    self.m_IsEnabled = false

    self.m_SoundEntity = nil
    self.m_VisualsEntity = nil

    self:RegisterEvents()
end

function OOBVision:RegisterEvents()
    Events:Subscribe('Level:Loaded', self, self.CreateEntities)
    Events:Subscribe('Extension:Unloading', self, self.Destroy)
    Events:Subscribe('Level:Destroy', self, self.Destroy)
end

function OOBVision:CreateSound()
    if self.m_SoundEntity ~= nil then return end

    -- oob sound resource
    local l_EntityData = ResourceManager:SearchForInstanceByGuid(Guid('0047C675-053C-4D84-860E-661555D20D27'))

    -- create sound entity
    if l_EntityData ~= nil then
        local l_EntityPos = LinearTransform()
        l_EntityPos.trans = Vec3(0.0, 0.0, 0.0)

        local l_Entity = EntityManager:CreateEntity(l_EntityData, l_EntityPos)

        if l_Entity ~= nil then
            l_Entity:Init(Realm.Realm_Client, true)
            self.m_SoundEntity = SoundEntity(l_Entity)
        end
    end
end

function OOBVision:CreateVisuals()
    if self.m_VisualsEntity ~= nil then return end

    local veData = VisualEnvironmentEntityData()
    veData.enabled = true
    veData.visibility = 1.0
    veData.priority = 999999

    local outdoorLight = OutdoorLightComponentData()
    outdoorLight.enable = true
    outdoorLight.sunColor = Vec3(10, 0, 0)
    outdoorLight.skyColor = Vec3(1, 1, 1)
    outdoorLight.groundColor = Vec3(1, 1, 1)

    veData.components:add(outdoorLight)
    veData.runtimeComponentCount = veData.runtimeComponentCount + 1

    local colorCorrection = ColorCorrectionComponentData()
    colorCorrection.enable = true
    colorCorrection.brightness = Vec3(1.0, 1.0, 1.0)
    colorCorrection.contrast = Vec3(1.0, 1.0, 1.0)
    colorCorrection.saturation = Vec3(0.3, 0.3, 1.0)
    colorCorrection.hue = 0.0
    colorCorrection.colorGradingTexture = TextureAsset(ResourceManager:SearchForInstanceByGuid(
                                                           Guid('E79F27A1-7B97-4A63-8ED8-372FE5012A31')))
    colorCorrection.colorGradingEnable = true

    veData.components:add(colorCorrection)
    veData.runtimeComponentCount = veData.runtimeComponentCount + 1

    local fog = FogComponentData()
    fog.enable = true
    fog.fogDistanceMultiplier = 1.0
    fog.fogGradientEnable = true
    fog.start = 0
    fog.endValue = 500
    fog.curve = Vec4(0, 0.5, 5.5, -1)
    fog.fogColorEnable = true
    fog.fogColor = Vec3(1.0, 1.0, 1.0)
    fog.fogColorStart = 4
    fog.fogColorEnd = 110
    fog.fogColorCurve = Vec4(4.8581696, -6.213437, 3.202797, -0.026411323)
    fog.transparencyFadeStart = -500.0
    fog.transparencyFadeEnd = 1500.0
    fog.transparencyFadeClamp = 1.0

    veData.components:add(fog)
    veData.runtimeComponentCount = veData.runtimeComponentCount + 1

    -- create entity
    local l_Entity = EntityManager:CreateEntity(veData, LinearTransform())

    if l_Entity ~= nil then
        l_Entity:Init(Realm.Realm_Client, true)
        self.m_VisualsEntity = l_Entity

        -- disable after creation
        self.m_IsEnabled = true
        self:Disable()
    end
end

function OOBVision:CreateEntities()
    self:CreateSound()
    self:CreateVisuals()
end

function OOBVision:Enable()
    if self.m_IsEnabled or self.m_SoundEntity == nil or self.m_VisualsEntity == nil then return end

    self.m_SoundEntity:FireEvent('Start')
    self.m_VisualsEntity:FireEvent('Enable')
    self.m_IsEnabled = true
end

function OOBVision:Disable()
    if (not self.m_IsEnabled) or self.m_SoundEntity == nil or self.m_VisualsEntity == nil then
        self.m_IsEnabled = false
        return
    end

    self.m_SoundEntity:FireEvent('Stop')
    self.m_VisualsEntity:FireEvent('Disable')
    self.m_IsEnabled = false
end

function OOBVision:Destroy()
    self:Disable()

    -- destroy sound entity
    if self.m_SoundEntity ~= nil then
        self.m_SoundEntity:Destroy()
        self.m_SoundEntity = nil
    end

    -- destroy visuals entity
    if self.m_VisualsEntity ~= nil then
        self.m_VisualsEntity:Destroy()
        self.m_VisualsEntity = nil
    end
end

return OOBVision
