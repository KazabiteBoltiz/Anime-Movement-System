-- local Void = require(game.ReplicatedStorage.Void)
-- Void.OnStart():Await()

-- --// System
-- local Players = game.Players
-- local PlayerUIFolder = game.ServerStorage.PlayerUI

-- --// Void
-- local Promise = require(Void.Util.Promise)
-- local RemoteSignal = require(Void.Util.Remote.RemoteSignal)
-- local DataFetchService = Void.GetService("DataFetchService")
-- local StarterPlayer = game:GetService("StarterPlayer")
-- local IDService = Void.GetService("IdentityService")

-- Players.PlayerAdded:Connect(function(plr)
--     DataFetchService:GetPlayerStat(plr)
--     :andThen(function(fetchedValue)
--         print(fetchedValue)
--     end) 
-- end)

-- Players.PlayerAdded:Connect(function(plr)
--     DataFetchService:SetPlayerStat(plr, "AAA")
--     :andThen(function(setValue)
--         print(setValue)
--     end)
-- end)