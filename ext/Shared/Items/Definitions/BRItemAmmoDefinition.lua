require "__shared/Items/Definitions/BRItemDefinition"
require "__shared/Enums/ItemEnums"

class("BRItemAmmoDefinition", BRItemDefinition)

function BRItemAmmoDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    -- set fixed shared option values for ammo
    p_Options.Type = ItemType.Ammo
    p_Options.Stackable = true
    p_Options.Price = 0

    -- call super's constructor and set shared options
    BRItemDefinition.__init(self, p_UId, p_Name, p_Options)
end

return {
    ["ammo-556mm"] = BRItemAmmoDefinition(
        "ammo-556mm",
        "5.56mm",
        {
            Description = "The 5.56mm ammo is used for ARs.",
            RandomWeight = 25,
            Mesh = MeshModel(
                DC(Guid("C946156E-C8D8-B16F-B16A-F6A138F20FF1"), Guid("AF8138C2-A6FF-9D8E-162A-00247243D4E4"))
            ),
            UIIcon = "__ammo_556mm",
            MaxStack = 60,
            Transform = LinearTransform(
                Vec3(0.4, 0, 0),
                Vec3(0, 0.4, 0),
                Vec3(0, 0, 0.4),
                Vec3(0, 0, 0)
            ),
        }
    ),
    ["ammo-9mm"] = BRItemAmmoDefinition(
        "ammo-9mm",
        "9mm",
        {
            Description = "The 9mm ammo is used for SMGs and Pistols.",
            RandomWeight = 25,
            Mesh = MeshModel(
                DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
            ),
            UIIcon = "__ammo_9mm",
            MaxStack = 90,
            Transform = LinearTransform(
                Vec3(0.35, 0, 0),
                Vec3(0, 0.35, 0),
                Vec3(0, 0, 0.45),
                Vec3(0, 0, 0)
            ),
        }
    ),
    ["ammo-762mm"] = BRItemAmmoDefinition(
        "ammo-762mm",
        "7.62mm",
        {
            Description = "The 7.62mm ammo is used for Snipers.",
            RandomWeight = 25,
            Mesh = MeshModel(
                DC(Guid("C946156E-C8D8-B16F-B16A-F6A138F20FF1"), Guid("AF8138C2-A6FF-9D8E-162A-00247243D4E4"))
            ),
            UIIcon = "__ammo_762mm",
            MaxStack = 15,
            Transform = LinearTransform(
                Vec3(0.4, 0, 0),
                Vec3(0, 0.4, 0),
                Vec3(0, 0, 0.4),
                Vec3(0, 0, 0)
            ),
        }
    ),
    ["ammo-12-gauge"] = BRItemAmmoDefinition(
        "ammo-12-gauge",
        "12 Gauge", 
        {
            Description = "The 7.62mm ammo is used for Snipers.",
            RandomWeight = 25,
            Mesh = MeshModel(
                DC(Guid("9670A55C-9EAC-2CEB-85B0-74A6CE759BC8"), Guid("1A70719C-0364-11DE-B228-D0C98D09F591"))
            ),
            UIIcon = "__ammo_12-gauge",
            MaxStack = 30,
            Transform = LinearTransform(
                Vec3(0.35, 0, 0),
                Vec3(0, 0.35, 0),
                Vec3(0, 0, 0.6),
                Vec3(0, 0, 0)
            ),
        }
    ),
}
