local Void = require(game.ReplicatedStorage.Void)
Void.OnStart():Await()

--// System
local Players = game.Players
local PlayerUIFolder = game.ServerStorage.PlayerUI

--// Void
local Promise = require(Void.Util.Promise)
local RemoteSignal = require(Void.Util.Remote.RemoteSignal)
local DataFetchService = Void.GetService("DataFetchService")
local StarterPlayer = game:GetService("StarterPlayer")
local IDService = Void.GetService("IdentityService")

--// Supportive Functions

local function giveNameTag(plr, name, level)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")

    if not head:FindFirstChild("CharacterUI") then
        local Billboard = PlayerUIFolder.CharacterUI:Clone()
        Billboard.Adornee = char:WaitForChild("Head")
        Billboard.Parent = char:WaitForChild("Head")
        Billboard.PlayerName.Text = name
        Billboard.Level.Text = "Level : "..tostring(level)
    end
end

local function InitNewPlayers(plr, firstName, clan)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local DBTable = {
        Exp = 0, FirstName = firstName,
        Clan = clan, Registered = true,
        Strength = 0, Muscle = 0, 
        Endurance = 0, Agility = 0, 
        Durability = 0, Intelligence = 0,
        BackMuscle = 0, GripStrength = 0
    }

    DataFetchService:SetPlayerStat(plr, DBTable, false)
        :andThen(function()
            local Billboard = PlayerUIFolder.CharacterUI:Clone()
            Billboard.Adornee = char:WaitForChild("Head")
            Billboard.Parent = char:WaitForChild("Head")
            Billboard.PlayerName.Text = DBTable.FirstName.." "..DBTable.Clan
            Billboard.Level.Text = "Level : "..tostring(1)
        end)
end

IDService.Client.GetSanitizedName:Connect(function(plr, text)
    local FilteredInstance = game:GetService("TextService"):FilterStringAsync(text, plr.UserId, Enum.TextFilterContext.PublicChat)
    local FilteredString = FilteredInstance:GetNonChatStringForUserAsync(plr.UserId)
    IDService.Client.GetSanitizedName:Fire(plr, FilteredString)
end)

local ClanNames = {
"Hanma",
"Shura",
"Miyamoto",
"Hanayama",
"Oliva",
"Motobe",
"Gengoku",
"Doyle",
"Sakamoto",
"Oasagawa"
}

local AlreadyInitPlayers = {}

local ClanChancesNormalized = {0.33,2.97,6.27,12.07,18.67,26.92,36.22,47.72,64.22,100.0}

IDService.Client.NameUpdate:Connect(function(plr, FirstName)
    if not table.find(AlreadyInitPlayers,plr) then
        local ClanOdds = math.random(1,1000*100)/1000

        for i,v in ipairs(ClanChancesNormalized) do
            if ClanOdds <= v then
                IDService.Client.NameUpdate:Fire(plr, ClanNames[i])
                InitNewPlayers(plr, FirstName, ClanNames[i])
                table.insert(AlreadyInitPlayers, plr)
                break;
            end
        end   
    end
end)

local function HandleNewPlayers(plr, fetchedStats)
    local char = plr.Character or plr.CharacterAdded:Wait()

    char:WaitForChild("Humanoid").DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    if fetchedStats then
        print("has player registered:",(fetchedStats.Registered))
        if fetchedStats.Registered == true then 
            print("Player Has Joined Before!")
            giveNameTag(plr,fetchedStats.FirstName.." "..fetchedStats.Clan,1)
        else
            print("Player is joining for the first time!")
            local UIClone = PlayerUIFolder.NewPlayerUI:Clone()
            UIClone.Parent = plr.PlayerGui
            UIClone.NameFrame.Visible = true
        end 
    else
        print("Player is joining for the first time! 2")
        local UIClone = PlayerUIFolder.NewPlayerUI:Clone()
        UIClone.Parent = plr.PlayerGui
        UIClone.NameFrame.Visible = true
    end
end

--// Main Events
Players.PlayerAdded:Connect(function(plr)
    DataFetchService:GetPlayerStat(plr)
    :andThen(function(fetchedStats)
        HandleNewPlayers(plr, fetchedStats)

        plr.CharacterAdded:Connect(function()
            HandleNewPlayers(plr, fetchedStats)
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    DataFetchService:HandleLeavingPlayers(plr)
end)