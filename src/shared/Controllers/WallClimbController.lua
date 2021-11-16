--// System
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid") 
local root = char:WaitForChild("HumanoidRootPart")
local original = root:WaitForChild("RootJoint").C0
local time = os.time

plr.CharacterAdded:Connect(function()
    char = plr.Character or plr.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    original = root:WaitForChild("RootJoint").C0
    hum = char:WaitForChild("Humanoid")
end)

local uis = game:GetService("UserInputService")
local v3 = Vector3.new 
local RenderS = game:GetService("RunService").RenderStepped
local ts = game.TweenService

local Modules = game.ReplicatedStorage.Modules
local Springs = require(Modules.Springs)

--// Void
local Void = require(game.ReplicatedStorage.Void)
local WallClimbController = Void.CreateController{Name = "WallClimbController"}
local StatesController

--// Script Values
local isClimbing = false
local climbSpeed = 6
local ClimbVel = Instance.new("BodyVelocity")
ClimbVel.Velocity = v3()
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Whitelist
rayParams.FilterDescendantsInstances = {workspace.Climbable}
local ClimbLoop;

--// Support Functions
local function CastRay(pos, dir)
    local rayResult = workspace:Raycast(pos, dir, rayParams)
    return rayResult
end

local function EndClimb()
    isClimbing = false
    print("climb ended.")
    ClimbLoop:Disconnect()
    ClimbLoop = nil
    ClimbVel.Parent = nil

    hum.JumpPower = 0
    hum.JumpHeight = 10

    if StatesController then
        StatesController.Signals.Climbing.ended:Fire()
    end
end

local function StartClimb()
    isClimbing = true
    print("climb started!")
    StatesController.Signals.Climbing.started:Fire()

    hum.JumpPower = 0
    hum.JumpHeight = 0

    ClimbLoop = RenderS:Connect(function()
    
        local frontRay = CastRay(root.Position, root.CFrame.LookVector*5)
        if not frontRay then
            EndClimb()
        else
            ClimbVel.Parent = root

        root.CFrame = CFrame.new(root.Position, root.Position + frontRay.Normal) * CFrame.Angles(0, math.rad(180), 0)
        end

    end)    
end


local HeldKeys = {
    Front = false,
    Back = false,
    Left = false,
    Right = false
}

--// Events
uis.InputBegan:Connect(function(input, typing)
    if typing then return end
    local key = input.KeyCode 
    
    if key == Enum.KeyCode.G then
        -- WallClimbController:TryClimb()
    end
    if isClimbing then
        if key == Enum.KeyCode.W then
            ClimbVel.Velocity += v3(0,1,0) * climbSpeed
        end 
        if key == Enum.KeyCode.S then
            ClimbVel.Velocity += v3(0,-1,0) * climbSpeed
        end 
    end
end)
uis.InputEnded:Connect(function(input)
    local key = input.KeyCode

    if isClimbing then
        if key == Enum.KeyCode.W then
            HeldKeys.Front = true
            ClimbVel.Velocity += v3(0,-1,0) * climbSpeed 
        end    
        if key == Enum.KeyCode.S then
            ClimbVel.Velocity += v3(0,1,0) * climbSpeed
        end
    end
end)

--// Main Functions
function WallClimbController:VoidInit()
    StatesController = Void.GetController("StatesController")
end

function WallClimbController:TryClimb()
    local Pos = root.Position
        local startAlt = root.Position.Y

    local rayRes = CastRay(root.Position * v3(1,0,1) + v3(0,startAlt,0), root.CFrame.LookVector*2)
    if rayRes then
        
        if ClimbLoop then
            EndClimb()
        else
           StartClimb()
        end

    end
end

--// Return
return WallClimbController
