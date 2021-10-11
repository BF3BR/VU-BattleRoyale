require "__shared/Items/Definitions/BRItemDefinition"
require "__shared/Enums/ItemEnums"

class("BRItemGadgetDefinition", BRItemDefinition)

function BRItemGadgetDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    -- set fixed shared option values for gadgets
    p_Options.Type = ItemType.Gadget
    p_Options.Stackable = true
    p_Options.Price = 0

    -- call super's constructor and set shared options
    BRItemDefinition.__init(self, p_UId, p_Name, p_Options)

    -- set gadget only options
    self.m_SoldierWeaponBlueprint = p_Options.SoldierWeaponBlueprint
    self.m_EbxName = p_Options.EbxName
    self.m_IsMinusAmmo = p_Options.IsMinusAmmo
end

return {
    ["gadget-m320-smoke"] = BRItemGadgetDefinition(
        "gadget-m320-smoke",
        "M320 Smoke",
        {
            Description = "The M320 Smoke is a variant of the M320 grenade launcher that fires smoke grenades.",
            MaxStack = 3,
            RandomWeight = 35,
            UIIcon = "UI/Art/Persistence/Weapons/Fancy/m320",
            EbxName = "Weapons/Gadgets/M320/M320",
            Mesh = WeaponSkeletonMeshModel(DC(Guid("C1C59CFB-D2DD-5C43-CF76-4A465CB9007A"), Guid("579D4CB4-1937-D2CA-C7EA-23193B0B0B7B"))),
            SoldierWeaponBlueprint = DC(Guid("5407475F-7E82-44A8-99D2-8009B925A528"), Guid("2F200B5C-4958-467C-9E12-B99DDADE2332")),
            Transform = LinearTransform(
                Vec3(0, -1, 0),
                Vec3(1, 0, 0),
                Vec3(0, 0, 1),
                Vec3(0, 0.04, -0.5)
            )
        }
    ),
    ["gadget-rpg"] = BRItemGadgetDefinition(
        "gadget-rpg",
        "RPG-7",
        {
            Description = "A widely-produced, anti-tank rocket propelled grenade weapon, the RPG-7 has been used in almost all conflicts across all continents since the mid-1960s. Modernized into the RPG-7v2, which is lighter, and more accurate than the original RPG-7 and firing GP-7VL rocket propelled grenades the RPG-7v2 is effective against both fortifications and armor.",
            MaxStack = 3,
            RandomWeight = 15,
            UIIcon = "UI/Art/Persistence/Weapons/Fancy/rpg7",
            EbxName = "Weapons/RPG7/RPG7",
            Mesh = WeaponSkeletonMeshModel(DC(Guid("58C89ADC-1A6A-5110-34C6-4CCE674F3F74"), Guid("6B9C428D-0E7F-EB04-8691-686085200903"))),
            SoldierWeaponBlueprint = DC(Guid("8B6957EA-8AF3-4827-9DA7-F411F74E1076"), Guid("08F58ECD-BC99-48AA-A9B3-47D412E99A4E")),
            Transform = LinearTransform(
                Vec3(0, -1, 0),
                Vec3(1, 0, 0),
                Vec3(0, 0, 1),
                Vec3(0, 0.04, -0.5)
            )
        }
    ),
    --[[["gadget-m67-grenade"] = BRItemGadgetDefinition(
        "gadget-m67-grenade",
        "M67 GRENADE",
        {
            Description = "A common defensive hand grenade, the M67 has a 3.5 second fuse and can be thrown approximately 30 meters by the average soldier. The lethal effect of this grenade is limited against targets with modern body armor.",
            MaxStack = 4,
            RandomWeight = 50,
            UIIcon = "UI/Art/Persistence/Weapons/Fancy/m67 grenade",
            EbxName = "Weapons/M67/M67",
            Mesh = MeshModel(
                DC(Guid("30BB276A-38BC-5354-ABF3-59CA85EB9339"), Guid("388539AF-C6EA-C4B3-5577-3CC232B89519"))
            ),
            SoldierWeaponBlueprint = DC(Guid("31EBAC8C-F32E-11DF-8153-F8368A2EF9E0"), Guid("9F789F05-CE7B-DADC-87D7-16E847DBDD09")),
            Transform = LinearTransform(
                Vec3(1.35, 0, 0),
                Vec3(0, 1.35, 0),
                Vec3(0, 0, 1.35),
                Vec3(0, 0.04, 0)
            )
        }
    ),]]
}
