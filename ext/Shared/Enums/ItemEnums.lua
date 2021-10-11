ItemType = {
    Default = 1,
    Weapon = 2,
    Attachment = 3,
    Ammo = 4,
    Consumable = 5,
    Armor = 6,
    Helmet = 7,
    Gadget = 8,
}

Tier = {
    Tier1 = 1,
    Tier2 = 2,
    Tier3 = 3,
}

LootPickupType = {
    Basic = {
        Name = "Basic",
        Mesh = MeshModel(DC(Guid("6519E1BF-BB39-8B7F-47D9-1B4C365318D9"), Guid("BC6154A0-CDFC-D402-ECCA-444811062765"))),
        CheckPrice = false,
        Transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0, 0, 0)
        ),
        PhysicsEntityData = nil,
    },
    Chest = {
        Name = "Chest",
        Mesh = MeshModel(DC(Guid("6D61C008-905F-602A-FC16-FF44B8F563F9"), Guid("2E9A903C-48BA-094B-6FB9-2EF6D89271F0"))),
        CheckPrice = false,
        Transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0, 0, 0)
        ),
        PhysicsEntityData = DC(Guid("6A4E0250-6FA5-11DE-8B6A-B2B60718374F"), Guid("6A6D279B-7870-9FC5-46DA-3B70CF7C1CD9")),
    },
    Airdrop = {
        Name = "Airdrop",
        Mesh = MeshModel(DC(Guid("DA504C92-911F-87DD-0D84-944BD542E835"), Guid("B5CE760E-5220-29BA-3316-23EA12244E88"))),
        CheckPrice = false,
        Transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0, 0, 0)
        ),
        PhysicsEntityData = DC(Guid("A80588DC-4471-11DE-B7E8-80A76CACD9DC"), Guid("598A91F1-B01C-B253-741C-1CF5669BA476")),
    },
    Shop = {
        Name = "Shop",
        Mesh = nil,
        CheckPrice = true,
        Transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0, 0, 0)
        ),
        PhysicsEntityData = nil,
    },
}

RandomWeightsTable = {
    ["Nothing"] = {
        RandomWeight = 25,
    },
    [ItemType.Weapon] = {
        RandomWeight = 100,
        Tiers = {
            [Tier.Tier1] = {
                RandomWeight = 65,
            },
            [Tier.Tier2] = {
                RandomWeight = 32,
            },
            [Tier.Tier3] = {
                RandomWeight = 3,
            },
        },
    },
    [ItemType.Attachment] = {
        RandomWeight = 25,
    },
    [ItemType.Helmet] = {
        RandomWeight = 25,
        Tiers = {
            [Tier.Tier1] = {
                RandomWeight = 65,
            },
            [Tier.Tier2] = {
                RandomWeight = 32,
            },
            [Tier.Tier3] = {
                RandomWeight = 3,
            },
        },
    },
    [ItemType.Armor] = {
        RandomWeight = 25,
        Tiers = {
            [Tier.Tier1] = {
                RandomWeight = 65,
            },
            [Tier.Tier2] = {
                RandomWeight = 32,
            },
            [Tier.Tier3] = {
                RandomWeight = 3,
            },
        },
    },
    [ItemType.Ammo] = {
        RandomWeight = 35,
    },
    [ItemType.Gadget] = {
        RandomWeight = 20,
    },
    [ItemType.Consumable] = {
        RandomWeight = 30,
    },
}

RandomWeaponPatterns = {
    OnlyWeapon = 1,
    WeaponWithAmmo = 2,
    WeaponWithAttachment = 3,
    WeaponWithAttachmentAndAmmo = 4,
    WeaponWithTwoAmmo = 5,
}

RandomAmmoPatterns = {
    OneItem = 1,
    TwoItems = 2,
    ThreeItems = 3,
}

AttachmentType = {
    Optics = 1,
    Barrel = 2,
    Other = 3
}

InventorySlot = {
    -- PrimaryWeapon slots
    PrimaryWeapon = 1,
    PrimaryWeaponAttachmentOptics = 2,
    PrimaryWeaponAttachmentBarrel = 3,
    PrimaryWeaponAttachmentOther = 4,
    -- SecondaryWeapon slots
    SecondaryWeapon = 5,
    SecondaryWeaponAttachmentOptics = 6,
    SecondaryWeaponAttachmentBarrel = 7,
    SecondaryWeaponAttachmentOther = 8,
    -- Gadget slots
    Armor = 9,
    Helmet = 10,
    Gadget = 11,
    -- Backpack slots
    Backpack1 = 12,
    Backpack2 = 13,
    Backpack3 = 14,
    Backpack4 = 15,
    Backpack5 = 16,
    Backpack6 = 17,
    Backpack7 = 18,
    Backpack8 = 19,
    Backpack9 = 20
}
