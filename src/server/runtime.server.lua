local Void = require(game.ReplicatedStorage.Void)
local RemoteSignal = require(Void.Util.Remote.RemoteSignal)
local RemoteProperty = require(Void.Util.Remote.RemoteProperty)

Void.AddServices(game.ReplicatedStorage.Services)
local IDService = Void.CreateService{Name = "IdentityService", Client = {GetSanitizedName = RemoteSignal.new(), NameUpdate = RemoteSignal.new()}}

Void.Start():andThen(function()
    print("Void Started!")
end):Catch(warn)

-- game.StarterPlayer.EnableMouseLockOption = false

