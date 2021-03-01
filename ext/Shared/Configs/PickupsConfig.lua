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
    NoPickupWeight = 50,
    Tiers = {
        [1] = {
            Message = "TIER I",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier1,
            Weight = 50,
            Weapons = {
                {
                    Name = "Weapons/PP2000/U_PP2000",
                    Ammo = 100,
                },{
                    Name = "Weapons/XP1_PP-19/U_PP-19",
                    Ammo = 100,
                },{
                    Name = "Weapons/Remington870/U_870",
                    Ammo = 100,
                },{
                    Name = "Weapons/M9/U_M9",
                    Ammo = 100,
                },{
                    Name = "Weapons/MP443/U_MP443_Silenced",
                    Ammo = 100,
                }
            }
        },
        [2] = {
            Message = "TIER II",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier2,
            Weight = 25,
            Weapons = {
                {
                    Name = "Weapons/M249/U_M249",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/M249/U_M249_Foregrip",
                        "Weapons/M249/U_M249_M145",
                    }
                },{
                    Name = "Weapons/M4A1/U_M4A1",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/M4A1/U_M4A1_Eotech",
                        "Weapons/M4A1/U_M4A1_M145",
                        "Weapons/M4A1/U_M4A1_TargetPointer",
                        "Weapons/M4A1/U_M4A1_RX01"
                    }
                },{
                    Name = "Weapons/SCAR-H/U_SCAR-H",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/SCAR-H/U_SCAR-H_Eotech",
                        "Weapons/SCAR-H/U_SCAR-H_M145",
                        "Weapons/SCAR-H/U_SCAR-H_TargetPointer",
                        "Weapons/SCAR-H/U_SCAR-H_RX01"
                    }
                },{
                    Name = "Weapons/SG553LB/U_SG553LB",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/SG553LB/U_SG553LB_EOTech",
                        "Weapons/SG553LB/U_SG553LB_Foregrip",
                    }
                },{
                    Name = "Weapons/SKS/U_SKS",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/SKS/U_SKS_Eotech",
                        "Weapons/SKS/U_SKS_M145",
                        "Weapons/SKS/U_SKS_RX01"
                    }
                }
            }
        },
        [3] = {
            Message = "TIER III",
            HudIcon = UIHudIcon.UIHudIcon_WeaponPickupTier3,
            Weight = 10,
            Weapons = {
                {
                    Name = "Weapons/Model98B/U_M98B",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/Model98B/U_M98B_EOTech",
                    }
                },{
                    Name = "Weapons/XP2_ACR/U_ACR",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/XP2_ACR/U_ACR_RX01",
                        "Weapons/XP2_ACR/U_ACR_TargetPointer",
                    }
                },{
                    Name = "Weapons/XP1_L85A2/U_L85A2",
                    Ammo = 100,
                    Attachments = {
                        "Weapons/XP1_L85A2/U_L85A2_Eotech",
                        "Weapons/XP1_L85A2/U_L85A2_M145",
                        "Weapons/XP1_L85A2/U_L85A2_TargetPointer",
                        "Weapons/XP1_L85A2/U_L85A2_RX01"
                    }
                },
            }
        }
    }   
}