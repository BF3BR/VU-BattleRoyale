require "__shared/Items/Definitions/BRItemProtectionDefinition"
require "__shared/Enums/ItemEnums"

class("BRItemHelmetDefinition", BRItemProtectionDefinition)

function BRItemHelmetDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    -- set fixed shared option values for helmets
    p_Options.Type = ItemType.Helmet
    p_Options.Mesh = SkeletonMeshModel(DC(Guid("0202751D-1ACE-3542-43E4-9BFFA6EF7F98"), Guid("9558CB54-0238-B2BD-643B-403FEE4A613D")), 0, 213)
    p_Options.Transform = LinearTransform(
        Vec3(1.2, 0, 0),
        Vec3(0, 1.2, 0),
        Vec3(0, 0, 1.2),
        Vec3(0, -2, 0)
    )

    -- call super's constructor and set shared options
    BRItemProtectionDefinition.__init(self, p_UId, p_Name, p_Options)
end

return {
    ["helmet-tier-1"] = BRItemHelmetDefinition(
        "helmet-tier-1",
        "Helmet",
        {
            Description = "Adds +50 headshot protection.",
            UIIcon = "__helmet",
            Tier = Tier.Tier1,
            Durability = 50,
            RandomWeight = 60,
        }
    ),
    ["helmet-tier-2"] = BRItemHelmetDefinition(
        "helmet-tier-2",
        "Helmet",
        {
            Description = "Adds +75 headshot protection.",
            UIIcon = "__helmet",
            Tier = Tier.Tier2,
            Durability = 75,
            RandomWeight = 30,
        }
    ),
    ["helmet-tier-3"] = BRItemHelmetDefinition(
        "helmet-tier-3",
        "Helmet",
        {
            Description = "Adds +100 headshot protection.",
            UIIcon = "__helmet",
            Tier = Tier.Tier3,
            Durability = 100,
            RandomWeight = 10,
        }
    ),
}
