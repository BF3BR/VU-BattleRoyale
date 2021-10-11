require "__shared/Enums/ItemEnums"

class "BRItemDefinition"

function BRItemDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    self.m_UId = p_UId
    self.m_Name = p_Name
    self.m_Description = p_Options.Description or ""
    self.m_UIIcon = p_Options.UIIcon
    self.m_Type = p_Options.Type or ItemType.Default
    self.m_RandomWeight = p_Options.RandomWeight or 0.0
    self.m_Stackable = p_Options.Stackable or false
    self.m_MaxStack = p_Options.MaxStack
    self.m_Price = p_Options.Price or 0
    self.m_HasAction = p_Options.HasAction or false
    self.m_Mesh = p_Options.Mesh
    self.m_Transform = p_Options.Transform or LinearTransform(
        Vec3(1, 0, 0),
        Vec3(0, 1, 0),
        Vec3(0, 0, 1),
        Vec3(0, 0, 0)
    )
end

function BRItemDefinition:Equals(p_Other)
    return self.m_UId == p_Other.m_UId
end
