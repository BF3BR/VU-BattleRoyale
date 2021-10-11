require "__shared/Items/Definitions/BRItemDefinition"
require "__shared/Enums/ItemEnums"

local m_WeaponDefinitions = require "__shared/Items/Definitions/BRItemWeaponDefinition"

class("BRItemAttachmentDefinition", BRItemDefinition)

function BRItemAttachmentDefinition:__init(p_UId, p_Name, p_Options)
    p_Options = p_Options or {}

    p_Options.Type = ItemType.Attachment
    p_Options.Stackable = false
    p_Options.MaxStack = nil
    p_Options.Price = 0

    -- call super's constructor and set shared options
    BRItemDefinition.__init(self, p_UId, p_Name, p_Options)

    -- A list of weapon definitions from BRItemWeaponDefinition
    self.m_AttachmentType = p_Options.AttachmentType
    self.m_AttachmentId = p_Options.AttachmentId -- TODO: Rename this lol
end

return {
    -- Optics
    ["attachment-acog"] = BRItemAttachmentDefinition(
        "attachment-acog",
        "4x ACOG",
        {
            Description = "The ACOG scope allows for the user to engage targets at medium to long ranges.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/acog",
            Mesh = MeshModel(DC(Guid("D01B86C8-5176-E446-85CB-DE8871DAC528"), Guid("D7875B6B-37F1-4C5D-60CD-273DDA3E553F"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.015, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.Acog
        }
    ),
    ["attachment-kobra"] = BRItemAttachmentDefinition(
        "attachment-kobra",
        "Kobra",
        {
            Description = "The Kobra is a Russian Red Dot Sight used by military and police organizations on AK style mounts, with some variants adapted to fit standard accessory rails.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/kobra",
            Mesh = MeshModel(DC(Guid("7F9582C2-34AB-784F-247C-CB482DCF8341"), Guid("67F59CFE-BFF4-1D03-0BD1-8F934C07817C"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.Kobra,
        }
    ),
    ["attachment-holo"] = BRItemAttachmentDefinition(
        "attachment-holo",
        "Holographic Sight",
        {
            Description = "A Holographic Weapon Sight is a non-magnifying gun sight that allows the user to look through a glass optical window and see a cross hair reticle image superimposed at a distance on the field of view.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/eotech",
            Mesh = MeshModel(DC(Guid("08C0F778-5BC7-910E-DFC5-B34684E9CDD4"), Guid("A4F63AF4-5325-B959-1F9C-1A9AB32A5FB7"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.02, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.EOTech
        }
    ),
    ["attachment-pka"] = BRItemAttachmentDefinition(
        "attachment-pka",
        "PK-A",
        {
            Description = "The PK-A red dot sight is a reflex sight produced by BelOMO in Minsk, Belarus.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/pka",
            Mesh = MeshModel(DC(Guid("46360BC0-6E46-C9EA-A066-496A15BE0C70"), Guid("62B277C3-D1BD-3315-DBDB-B4240BBC06E7"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.PKA
        }
    ),
    ["attachment-pka-s"] = BRItemAttachmentDefinition(
        "attachment-pka-s",
        "PKA-S",
        {
            Description = "The PK-AS/ASV is an advanced reflex sight manufactured by BelOMO (Belarusian Optical & Mechanical Association).",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/pkas",
            Mesh = MeshModel(DC(Guid("682809CF-A863-B0C4-0D30-99DFEBF0976A"), Guid("F7FFA7D6-B910-947A-3CA6-1F2127FAE4B1"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.015, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.PK_AS
        }
    ),
    ["attachment-riflescope"] = BRItemAttachmentDefinition(
        "attachment-riflescope",
        "Rifle Scope",
        {
            Description = "The Rifle Scope is a weapon optic available on assault rifles, carbines, shotguns, magazine-fed LMGs, the AS VAL and the Sniper rifles.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/riflescope",
            Mesh = MeshModel(DC(Guid("F8FCC3C3-C08F-E042-7208-671C0C8F66CD"), Guid("B0003C9E-6A96-BAB2-32D9-BB2287FFA784"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Optics,
            AttachmentId = g_AttachmentIds.RifleScope
        }
    ),

    -- Barrels (Primary)
    ["attachment-suppressor"] = BRItemAttachmentDefinition(
        "attachment-suppressor",
        "Suppressor",
        {
            Description = "The Suppressor is a device attached to a firearm which reduces the amount of noise generated by firing the weapon.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/soundsuppressor",
            Mesh = MeshModel(DC(Guid("0B08EAEF-553D-CAD3-D7A4-CA770735FFFA"), Guid("F8FC2931-D0E1-3102-5FD0-E474B9CAAB66"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.015, 0)
            ),
            AttachmentType = AttachmentType.Barrel,
            AttachmentId = g_AttachmentIds.Silencer
        }
    ),
    ["attachment-flash-suppressor"] = BRItemAttachmentDefinition(
        "attachment-flash-suppressor",
        "Flash Hider",
        {
            Description = "A flash suppressor, also known as a flash hider is a device attached to the muzzle of a rifle or other firearm that reduces the visible signature of the burning gases that exit the muzzle, which may also reduce recoil.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/flashsuppressor",
            Mesh = MeshModel(DC(Guid("E36E22DC-F8F5-E5F0-D862-691121A05443"), Guid("5931AD6C-9A8D-60B0-7D0B-93C3AFB45796"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Barrel,
            AttachmentId = g_AttachmentIds.FlashSuppressor
        }
    ),
    ["attachment-heavy-barrel"] = BRItemAttachmentDefinition(
        "attachment-heavy-barrel",
        "Heavy Barrel",
        {
            Description = "A Heavy Barrel is a weapon attachment used to increase a weapon's accuracy by reducing barrel whip.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/heavybarrel",
            Mesh = MeshModel(DC(Guid("0B08EAEF-553D-CAD3-D7A4-CA770735FFFA"), Guid("F8FC2931-D0E1-3102-5FD0-E474B9CAAB66"))), -- TODO FIXME
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Barrel,
            AttachmentId = g_AttachmentIds.HeavyBarrel
        }
    ),

    -- Other (Secondary)
    ["attachment-foregrip"] = BRItemAttachmentDefinition(
        "attachment-foregrip",
        "Foregrip", 
        {
            Description = "A Foregrip is a grip on the front of a firearm that makes controlling recoil easier, and prevents burns from the barrel during firing.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/foregrip",
            Mesh = MeshModel(DC(Guid("3B289843-61BF-474E-531F-F6455B30BBA3"), Guid("D0D95F60-F122-3EBC-2209-035C31682DD3"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0, 0)
            ),
            AttachmentType = AttachmentType.Other,
            AttachmentId = g_AttachmentIds.Foregrip
        }
    ),
    ["attachment-laser-sight"] = BRItemAttachmentDefinition(
        "attachment-laser-sight",
        "Laser Sight", 
        {
            Description = "The laser has in most firearms applications been used as a tool to enhance the targeting of other weapon systems. ",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/targetpointer",
            Mesh = MeshModel(DC(Guid("FA265FB2-DE37-7A01-7EFB-71CBB1CE98DF"), Guid("3BB386D3-9655-556B-CBE1-773BDD3E4A9C"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.2, 0)
            ),
            AttachmentType = AttachmentType.Other,
            AttachmentId = g_AttachmentIds.TargetPointer
        }
    ),
    ["attachment-flashlight"] = BRItemAttachmentDefinition(
        "attachment-flashlight",
        "Tactical Light", 
        {
            Description = "A Tactical Light is a flashlight or torch that can be attached to a user's weapon by means of a standard rail or other mount, freeing the user from having to carry a separate flashlight, or when more advanced night vision equipment is not available.",
            RandomWeight = 25,
            UIIcon = "UI/Art/Persistence/WeaponAccessory/Fancy/flashlight",
            Mesh = MeshModel(DC(Guid("D4D4A69A-A7A0-0AEC-3962-579188852BE7"), Guid("4A244D6B-31BF-4C74-8870-77170B844046"))),
            Transform = LinearTransform(
                Vec3(2, 0, 0),
                Vec3(0, 2, 0),
                Vec3(0, 0, 2),
                Vec3(0, 0.05, 0)
            ),
            AttachmentType = AttachmentType.Other,
            AttachmentId = g_AttachmentIds.Flashlight
        }
    ),
}
