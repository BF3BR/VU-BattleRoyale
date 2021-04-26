PickupsConfig = {
    InteractionRadius = 2.5,
    WeaponTransform = LinearTransform(
        Vec3(0,-1, 0),
        Vec3(1, 0, 0),
        Vec3(0, 0, 1),
        Vec3(0, 0.4, -0.3)
    ),
    MarkerTransform = Vec3(0, 0.5, 0),
    MarkerShowRadius = 6,
    MarkerHideRadius = 1,
    MedkitCapacity = 10,
    AmmobagCapacity = 10,
    NoPickupWeight = 35,
    Tiers = {
        [1] = {
            Slots = { WeaponSlot.WeaponSlot_0, WeaponSlot.WeaponSlot_1 },
            Message = "TIER I",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier1,
            Weight = 70,
            Weapons = {
                {
                    Type = g_Weapons.PP2000,
                    Ammo = 100,
                },{
                    Type = g_Weapons.PP_19,
                    Ammo = 100,
                },{
                    Type = g_Weapons.Remington870,
                    Ammo = 100,
                },{
                    Type = g_Weapons.M9,
                    Ammo = 100,
                },{
                    Type = g_Weapons.MP443_Silenced,
                    Ammo = 100,
                }
            }
        },
        [2] = {
            Slots = { WeaponSlot.WeaponSlot_0, WeaponSlot.WeaponSlot_1 },
            Message = "TIER II",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier2,
            Weight = 15,
            Weapons = {
                {
                    Type = g_Weapons.M249,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.Foregrip,
                        g_Attachments.M145
                    }
                },{
                    Type = g_Weapons.M4A1,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.EOTech,
                        g_Attachments.M145,
                        g_Attachments.TargetPointer,
                        g_Attachments.RX01
                    }
                },{
                    Type = g_Weapons.SCAR_H,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.EOTech,
                        g_Attachments.M145,
                        g_Attachments.TargetPointer,
                        g_Attachments.RX01
                    }
                },{
                    Type = g_Weapons.SG553LB,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.EOTech,
                        g_Attachments.Foregrip,
                    }
                },{
                    Type = g_Weapons.SKS,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.EOTech,
                        g_Attachments.M145,
                        g_Attachments.RX01
                    }
                }
            }
        },
        [3] = {
            Slots = { WeaponSlot.WeaponSlot_0, WeaponSlot.WeaponSlot_1 },
            Message = "TIER III",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier3,
            Weight = 2,
            Weapons = {
                {
                    Type = g_Weapons.M98B,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.RifleScope
                    }
                },{
                    Type = g_Weapons.ACR,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.RX01,
                        g_Attachments.TargetPointer,
                    }
                },{
                    Type = g_Weapons.L85A2,
                    Ammo = 100,
                    Attachments = {
                        g_Attachments.EOTech,
                        g_Attachments.M145,
                        g_Attachments.TargetPointer,
                        g_Attachments.RX01
                    }
                },
            }
        },
        --[[[4] = {
            Slots = { WeaponSlot.WeaponSlot_2, WeaponSlot.WeaponSlot_5 },
            Message = "HEALTH",
            HudIcon = UIHudIcon.UIHudIcon_MedicBag,
            Mesh = DC(Guid("6519E1BF-BB39-8B7F-47D9-1B4C365318D9"), Guid("BC6154A0-CDFC-D402-ECCA-444811062765")),
            MeshTransform = LinearTransform(),
            Weight = 10,
            Weapons = {
                {
                    Type = g_Gadgets.Medkit,
                    Ammo = 1,
                },
            }
        },
        [5] = {
            Slots = { WeaponSlot.WeaponSlot_2, WeaponSlot.WeaponSlot_5 },
            Message = "AMMO",
            HudIcon = UIHudIcon.UIHudIcon_AmmoCrate,
            Mesh = DC(Guid("50BB59D3-DFAB-C286-EBAC-B5CF4BAB7AC0"), Guid("6412D2CA-7AF5-A459-E048-688143B6E35B")),
            MeshTransform = LinearTransform(),
            Weight = 10,
            Weapons = {
                {
                    Type = g_Gadgets.Ammobag,
                    Ammo = 1,
                }
            }
        }]]
    }
}
