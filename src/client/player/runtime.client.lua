local Void = require(game.ReplicatedStorage.Void)
local Controllers = game.ReplicatedStorage.Controllers

Void.AddControllers(Controllers)

Void.Start():andThen(function()
    print("Void Started!")
end):Catch(warn)