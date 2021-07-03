class "BRMerchant"

-- Include the shared config
require("__shared/Configs/MerchantsConfig")

function BRMerchant:__init(p_Name, p_TeamId, p_SquadId, p_Transform, p_MerchantType)


    --[[
        Fancy Additions,

        These include greeting players, as well as reacting to hostile players
    ]]--

    -- When a player first interacts with a merchant, they will greet the player
    self.m_GreetedPlayerIds = { }

    -- If a player damages a merchant past the default amount, when they interact with the merchant they will become hostile
    self.m_HostilePlayerIds = { }

    -- Transform of the merchant
    self.m_Transform = p_Transform

    -- Bot player id
    self.m_BotPlayerId = -1
    self.m_BotEntryInput = EntryInput()

    -- MerchantsConfig.Types
    self.m_MerchantType = p_MerchantType

    -- Defaults to create the bot
    self.m_BotName = p_Name
    self.m_BotTeamId = p_TeamId
    self.m_BotSquadId = p_SquadId
end

function BRMerchant:GetPlayerId()
    return self.m_BotPlayerId
end

function BRMerchant:Spawn()
    local s_BotPlayer = nil

    -- Check to see if we already have a bot and he's just dead
    if self.m_BotPlayerId == -1 then
        -- We do not have any player, create a new one

        s_BotPlayer = PlayerManager:CreatePlayer(self.m_Name, self.m_BotTeamId, self.m_BotSquadId)
        if s_BotPlayer == nil then
            print("could not create a new bot with (Name: " .. self.m_Name .. " Team: " .. self.m_BotTeamId .. " Squad: " .. self.m_BotSquadId .. ")")
            return
        end

        -- Create a new input for this bot
        self.m_BotEntryInput.deltaTime = 1.0 / SharedUtils:GetTickrate()

        -- Assign our input, we need to keep the EntryInput around because VEXT will GC it otherwise and we WILL crash
        s_BotPlayer.input = self.m_BotEntryInput

        -- Assign our bot player id
        self.m_BotPlayerId = s_BotPlayer.id
    else -- We have a valid player id
        s_BotPlayer = PlayerManager:GetPlayerById(self.m_BotPlayerId)
        if s_BotPlayer == nil then
            print("bot player id: " .. self.m_BotPlayerId .. " does not exist destroying merchant.")
            self.m_BotPlayerId = -1
            return
        end
    end

    -- If this bot already has a soldier, kill it
    self:Kill()

    -- TODO: Kit and Unlocks

    -- Get the default soldier blueprint
    -- Characters/Soldiers/MpSoldier/ SoldierBlueprint 261E43BF-259B-41D2-BF3B-9AE4DDA96AD2 #primary instance
    local s_SoldierBlueprint = ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-9AE4DDA96AD2'))
    if s_SoldierBlueprint == nil then
        print("could not find the Characters/Soldiers/MpSoldier blueprint.")
        return
    end

    -- Get the soldier customization
    -- Gameplay/Kits/USAssault/ VeniceSoldierCustomizationAsset A15EE431-88B8-4B35-B69A-985CEA934855 #primary instance
    local s_SoldierKit = ResourceManager:SearchForInstanceByGuid(Guid('A15EE431-88B8-4B35-B69A-985CEA934855'))
    if s_SoldierKit == nil then
        print("could not get Gameplay/Kits/USAssault customization.")
        return
    end

    -- Set the unlocks for this soldier
    s_BotPlayer:SelectUnlockAssets(s_SoldierKit, { })

    -- Create a new soldier
    local s_BotSoldier = s_BotPlayer:CreateSoldier(s_SoldierBlueprint, self.m_Transform)
    if s_BotSoldier == nil then
        print("could not create bot soldier for id: " .. self.m_BotPlayerId)
        return
    end

    -- Spawn the new soldier
    s_BotPlayer:SpawnSoldierAt(s_BotSoldier, self.m_Transform, CharacterPoseType.CharacterPoseType_Stand)

    -- Attach the soldier to the player
    s_BotPlayer:AttachSoldier(s_BotSoldier)
end

function BRMerchant:Kill()
    -- Check that our merchant has a valid player id
    if self.m_BotPlayerId == -1 then
        return
    end

    -- Get the player by player id
    local s_BotPlayer = PlayerManager:GetPlayerById(self.m_BotPlayerId)
    if s_BotPlayer == nil then
        print("bot player id: (" .. self.m_BotPlayerId .. ") does not exist")
        return
    end

    -- Check to see if the player is already dead
    if not s_BotPlayer.alive then
        print("attempted to kill a merchant that is already dead (id: " .. self.m_BotPlayerId .. ")")
        return
    end

    -- Get the soldier
    local s_BotSoldier = s_BotPlayer.soldier
    if s_BotSoldier == nil then
        print("bot player id: (" .. self.m_BotPlayerId .. ") soldier does not exist, dead?")
        return
    end

    -- Kill the bot
    s_BotSoldier:Kill()
end

function BRMerchant:Destroy()
    local s_BotPlayer = PlayerManager:GetPlayerById(self.m_BotPlayerId)
    if s_BotPlayer == nil then
        print("could not find bot player id: " .. self.m_BotPlayerId .. " to delete.")
        return
    end

    -- Remove the input from the bot
    s_BotPlayer.input = nil

    -- Clear the saved player id
    self.m_BotPlayerId = -1

    -- Delete the player
    PlayerManager:DeletePlayer(s_BotPlayer)

    -- Clear out all of the hostile and greeted players
    self:ClearHostilePlayers()
    self:ClearGreetedPlayers()
end

function Merchant:ClearHostilePlayers()
    self.m_HostilePlayerIds = { }
end

function Merchant:ClearGreetedPlayers()
    self.m_GreetedPlayerIds = { }
end

function Merchant:HasGreetedPlayer(p_Player)
    if p_Player == nil then
        return false
    end

    return self.m_GreetedPlayerIds[p_Player.id] ~= nil
end

function BRMerchant:AddDamageForPlayer(p_AttackerPlayerId, p_Damage)
    -- Attempt to get the existing player damage by player id
    local s_CurrentDamage = self.m_GreetedPlayerIds[p_AttackerPlayerId]

    -- If there is no current damage for the player add them to the list
    if s_CurrentDamage == nil then
        self.m_GreetedPlayerIds[p_AttackerPlayerId] = p_Damage
        return
    end

    -- Update the current player damage
    self.m_GreetedPlayerIds[p_AttackerPlayerId] = s_CurrentDamage + p_Damage
end

function Merchant:GreetPlayer(p_Player)
    -- Validate our player
    if p_Player == nil then
        return
    end

    -- Get the player id
    local s_PlayerId = p_Player.id

    -- Iterate all of the already greeted players
    for _, l_PlayerId in pairs(self.m_GreetedPlayerIds) do
        -- If the player has already been greeted do not greet again
        if l_PlayerId == s_PlayerId then
            return
        end
    end

    -- Add our player to the existing list with 0 damage
    self:AddDamageForPlayer(p_Player, 0.0)

    -- Get the player name
    local s_PlayerName = p_Player.name

    -- Format the print
    local s_CannedGreeting = MerchantsConfig.Greetings[MathUtils.GetRandomInt(1, #self.m_CannedGreetings)]

    -- Yell at the player only the greeting
    ChatManager:Yell(s_CannedGreeting .. " " .. s_PlayerName, 2.0, p_Player)
end

return BRMerchant