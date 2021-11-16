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
local MovementController = Void.CreateController{Name = "MovementController"}
local StatesController

--// Script Values
local isClimbing = false
local MovementLoop
local WalkSpeed, RunSpeed, JumpCD = 16, 26, 5
local inShiftLock = false

local DashCD = 2
local lastDashed = 0

local isDashing = false
local DashTime, DashSpeed = .2, 80
local SprintTime = .2

local SpeedTarget = v3()

local SpeedSpring = Springs.new(v3())
SpeedSpring.Speed = 70
SpeedSpring.Damper = 1

local isSprinting = false
local WLastPressed = 0
local JLastPressed = 0

local inputKeys = {
    ["Front"] = Enum.KeyCode.W,
    ["Back"] = Enum.KeyCode.S,
    ["Left"] = Enum.KeyCode.A,
    ["Right"] = Enum.KeyCode.D,
    ["Jump"] = Enum.KeyCode.Space,
    ["Dash"] = Enum.KeyCode.Q
}
local HeldKeys = {
    Front = false,
    Back = false,
    Left = false,
    Right = false
}
local DashAnimations = {
    Back = function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://7897560231"
        return hum:LoadAnimation(anim)
    end,
    Front = function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://7897562521"
        return hum:LoadAnimation(anim)
    end,
    Left = function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://7897564369"
        return hum:LoadAnimation(anim)
    end,
    Right = function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://7897565941"
        return hum:LoadAnimation(anim)
    end
}

for i,v in ipairs(DashAnimations) do
    v():Play()
end

--// Script Support
local front = v3(0,0,-1)
local right = v3(1,0,0)
local isTyping = false

--// Init
hum.WalkSpeed = WalkSpeed
hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)

--// Support Functions
local function CastRay(pos, dir, unit) end

local function GetDashDirection()
    if HeldKeys.Left then
        if HeldKeys.Front then
            --front
            return "Front"
        elseif HeldKeys.Back then
            --back
            return "Back"
        else
            --left    
            return "Left"
        end
    elseif HeldKeys.Right then
        if HeldKeys.Front then
            --front
            return "Front"
        elseif HeldKeys.Back then
            --back
            return "Back"
        else
            --right   
            return "Right"
        end
    elseif HeldKeys.Front then
        if not HeldKeys.Left and not HeldKeys.Right then
            --front
            return "Front"
        end
    elseif HeldKeys.Back then    
        if not HeldKeys.Left and not HeldKeys.Right then
            --back
            return "Back"
        end
    else
        return "none"    
    end
end

local function GetMass(model)
    local totalMass = 0
    for i,v in ipairs(model:GetChildren()) do
        if v:IsA("BasePart") then
            totalMass += v:GetMass()
        end
    end
    return totalMass
end

--// Events
uis.InputBegan:Connect(function(input, typing)
    if typing or isTyping or isClimbing then return end

    local key = input.KeyCode 
    if key == inputKeys.Front then
        HeldKeys.Front = true
        if tick() - WLastPressed < SprintTime then
            isSprinting = true
            hum.WalkSpeed = RunSpeed
        end
        SpeedTarget = SpeedTarget + front
        WLastPressed = tick()
    end
    if key == inputKeys.Back then
        HeldKeys.Back = true
        SpeedTarget = SpeedTarget - front 
     end
     if key == inputKeys.Left then
        HeldKeys.Left = true
         SpeedTarget = SpeedTarget - right
     end
     if key == inputKeys.Right then
        HeldKeys.Right = true
         SpeedTarget = SpeedTarget + right
     end
     if key == inputKeys.Dash then
        if isDashing or time() - lastDashed < DashCD then return end

        isDashing = true
        lastDashed = time()
        local boost = Instance.new("BodyVelocity")
        boost.MaxForce = v3(100000, 100000, 100000)
        boost.P = 100
        boost.Parent = root
        
        local DashDir = GetDashDirection()
        if DashDir == "Front" then
            boost.Velocity = root.CFrame.LookVector * DashSpeed   
        elseif DashDir == "Back" then
            boost.Velocity = -root.CFrame.LookVector * DashSpeed    
        elseif DashDir == "Left" then
            boost.Velocity = -root.CFrame.RightVector * DashSpeed
        elseif DashDir == "Right" then
            boost.Velocity = root.CFrame.RightVector * DashSpeed 
        elseif DashDir == "none" then
            boost.Velocity = root.CFrame.LookVector * DashSpeed    
        end

        local anim = Instance.new("Animation")
        
        DashAnimations[DashDir]():Play()

        wait(DashTime)

        boost.Velocity = v3()
        boost:Destroy()
        isDashing = false
     end
     if key == Enum.KeyCode.Slash then
         SpeedTarget = v3()
     end

     SpeedSpring.Target = SpeedTarget

end)
uis.InputEnded:Connect(function(input)
    if isTyping or isClimbing then return end

    local key = input.KeyCode
    if key == inputKeys.Front then
        HeldKeys.Front = false
        if isSprinting then
            isSprinting = false
            hum.WalkSpeed = WalkSpeed
        end
        SpeedTarget = SpeedTarget - front
    end
    if key == inputKeys.Back then
        HeldKeys.Back = false
       SpeedTarget = SpeedTarget + front 
    end
    if key == inputKeys.Left then
        HeldKeys.Left = false
        SpeedTarget = SpeedTarget + right
    end
    if key == inputKeys.Right then
        HeldKeys.Right = false
        SpeedTarget = SpeedTarget - right
    end

    SpeedSpring.Target = SpeedTarget
end)

uis.TextBoxFocused:Connect(function()
    isTyping = true
    SpeedTarget = v3()
end)
uis.TextBoxFocusReleased:Connect(function()
    isTyping = false
end)

local vel, dir
local angle = 0
local angle2 = 0
local tweenInfo = TweenInfo.new(
			.8,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)

MovementLoop = 
    RenderS:Connect(function()
        if not char then return end

        plr:Move(SpeedSpring.Position, true)

        vel = root.Velocity * Vector3.new(1,0,1)

        if vel.Magnitude > 2  then
            dir = vel.Unit
            if isSprinting then
                angle = root.CFrame.RightVector:Dot(dir)/5
                angle2 = root.CFrame.LookVector:Dot(dir)/5 
            else
                angle = root.CFrame.RightVector:Dot(dir)/8
                angle2 = root.CFrame.LookVector:Dot(dir)/8
            end
        else
            angle = 0
            angle2 = 0
        end

        if root:FindFirstChild("RootJoint") then
            local tween = ts:Create(root.RootJoint, tweenInfo, {C0 = original*CFrame.Angles(angle2, -angle, 0)})
            tween:Play()
        end
    end)


--// Main Functions
function MovementController:VoidInit()
    StatesController = Void.GetController("StatesController")

    StatesController.Signals.Climbing.started:Connect(function()
        isClimbing = true
    end)
    StatesController.Signals.Climbing.ended:Connect(function()
        isClimbing = false
    end)
end

return MovementController

