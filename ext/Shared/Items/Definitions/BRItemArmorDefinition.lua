require "__shared/Items/Definitions/BRItemProtectionDefinition"
require "__shared/Enums/ItemEnums"

class("BRItemArmorDefinition", BRItemProtectionDefinition)

function BRItemArmorDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    -- set fixed shared option values for vests
    p_Options.Type = ItemType.Armor
    p_Options.Mesh = SkeletonMeshModel(DC(Guid("577909B4-EA3A-BF50-2B09-67278E0B0D7A"), Guid("163CAD89-E917-4B51-ED38-814A5F961C1C")), 0, 213)
    p_Options.Transform = LinearTransform(
        Vec3(1.2, 0, 0),
        Vec3(0, 1.2, 0),
        Vec3(0, 0, 1.2),
        Vec3(0, -1.25, 0)
    )

    -- call super's constructor and set shared options
    BRItemProtectionDefinition.__init(self, p_UId, p_Name, p_Options)
end

return {
    ["armor-tier-1"] = BRItemArmorDefinition(
        "armor-tier-1",
        "Armor",
        {
            Description = "Adds +50 body armor.",
            UIIcon = "__armor",
            Tier = Tier.Tier1,
            Durability = 50,
            RandomWeight = 60,
        }
    ),
    ["armor-tier-2"] = BRItemArmorDefinition(
        "armor-tier-2",
        "Armor",
        {
            Description = "Adds +75 body armor.",
            UIIcon = "__armor",
            Tier = Tier.Tier2,
            Durability = 75,
            RandomWeight = 30,
        }
    ),
    ["armor-tier-3"] = BRItemArmorDefinition(
        "armor-tier-3",
        "Armor",
        {
            Description = "Adds +100 body armor.",
            UIIcon = "__armor",
            Tier = Tier.Tier3,
            Durability = 100,
            RandomWeight = 10,
        }
    ),
}
