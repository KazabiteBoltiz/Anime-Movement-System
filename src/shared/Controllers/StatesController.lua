-- doesnt need variables, so I haven't initialized any setups

local Void = require(game.ReplicatedStorage.Void)
local Signal = require(Void.Util.Signal)
local StatesController = Void.CreateController{Name = "StatesController"}

--// Signals
StatesController.Signals = {
    Climbing = {started = Signal.new(), ended = Signal.new()} 
}

return StatesController