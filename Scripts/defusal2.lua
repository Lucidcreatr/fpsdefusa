-- SXMLIB Full GUI & Tools
if game.PlaceId ~= 79393329652220 then return end

-- Kütüphaneyi yükle
local success, SXMLIB = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua'))()
end)
if not success then
    warn("SXMLIB yüklenemedi: "..tostring(SXMLIB))
    return
end

-- Temalar
local themes = {
    Red = SXMLIB.Themes.Red,
    Blue = SXMLIB.Themes.Blue,
    Black = SXMLIB.Themes.Dark,
    White = SXMLIB.Themes.Light,
    Grey = SXMLIB.Themes.Gray,
    Burgundy = SXMLIB.Themes.Burgundy,
    Purple = SXMLIB.Themes.Purple,
    Green = SXMLIB.Themes.Green,
    Yellow = SXMLIB.Themes.Yellow,
    Cyan = SXMLIB.Themes.Cyan
}

-- Window
local Window = SXMLIB.new({Theme=themes.Blue, Name="SXMLIB Tools"})
Window:Notify("SXMLIB Full GUI Loaded",3)

-- Tabs
local MainTab   = Window:CreateWindow({Name="ESP"})
local AimBotTab = Window:CreateWindow({Name="AimBot"})
local PlayerTab = Window:CreateWindow({Name="Player"})
local RageTab   = Window:CreateWindow({Name="Rage"})
local SkinsTab  = Window:CreateWindow({Name="Skins"})

-- Sections
local MainSec   = MainTab:CreateSection("Main")
local AimBotSec = AimBotTab:CreateSection("Main")
local PlayerSec = PlayerTab:CreateSection("Main")
local RageSec   = RageTab:CreateSection("Main")
local SkinsSec  = SkinsTab:CreateSection("Main")

-- Services & State
local LP = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local savedPos
local bodyVel
local connections = {}

local state = {
    boxESP=false, healthESP=false, aimbot=false, drawCircle=false, circleScale=50, trigger=false, hitboxSize=5, bigHitbox=false,
    spin=false, speed=false, fly=false, flySpeed=60, walk=60, normalSpeed=16, bunny=false, noclip=false, tpToMe=false, autoTask=false,
    infiniteAmmo=false, rainbow=false, colorSpeed=0.1
}

local boxes, originalHeads = {},{}
local circle = Drawing.new("Circle")
circle.Visible=false
circle.Color=Color3.fromRGB(255,0,230)
circle.Radius=state.circleScale
circle.Thickness=2
circle.Filled=false

-- Character Added
LP.CharacterAdded:Connect(function(char)
    Hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    if state.fly then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
        bodyVel.P=1e4
        bodyVel.Velocity=Vector3.zero
        bodyVel.Parent=hrp
    end
end)

-- Functions
local function createBox(char)
    local success, box = pcall(function()
        local b = Drawing.new("Square")
        b.Visible=false
        b.Color=Color3.new(1,0,0)
        b.Thickness=2
        b.Filled=false
        b.Character=char
        table.insert(boxes,b)
        RunService.RenderStepped:Connect(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                local vec,onScreen = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                if onScreen then
                    local size = 2000/vec.Z
                    b.Size=Vector2.new(size,size)
                    b.Position=Vector2.new(vec.X-size/2, vec.Y-size/2)
                    b.Visible=true
                else
                    b.Visible=false
                end
            else
                b.Visible=false
            end
        end)
    end)
    if not success then warn("ESP Box Error: "..tostring(box)) end
end

local function removeBox(char)
    for i=#boxes,1,-1 do
        if boxes[i].Character==char then
            boxes[i]:Remove()
            table.remove(boxes,i)
        end
    end
end

-- Player Added
local function onPlayerAdded(plr)
    if plr==LP then return end
    local char = plr.Character or plr.CharacterAdded:Wait()
    if state.boxESP then createBox(char) end
    plr.CharacterAdded:Connect(function(newChar)
        if state.boxESP then createBox(newChar) end
    end)
end

local function onPlayerRemoving(plr)
    if plr.Character then removeBox(plr.Character) end
end

for _,plr in pairs(Players:GetPlayers()) do if plr~=LP then onPlayerAdded(plr) end end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Main Section
MainSec:Button({label="Toggle ESP", callback=function() state.boxESP=not state.boxESP end})

-- AimBot Section
AimBotSec:Toggle({label="Aimbot", callback=function(v) state.aimbot=v end})
AimBotSec:Toggle({label="Draw Circle", callback=function(v) state.drawCircle=v circle.Visible=v end})
AimBotSec:Slider({label="Circle Size", min=5,max=50,default=50,callback=function(v) state.circleScale=v circle.Radius=v end})
AimBotSec:Toggle({label="TriggerBot", callback=function(v) state.trigger=v end})
AimBotSec:Slider({label="Hitbox Size", min=1,max=350,default=5,callback=function(v) state.hitboxSize=v end})
AimBotSec:Toggle({label="Big Hitbox", callback=function(v) state.bigHitbox=v end})

-- Player Section
PlayerSec:Slider({label="Fly Speed", min=0,max=150,default=60,callback=function(v) state.flySpeed=v end})
PlayerSec:Toggle({label="SpinBot", callback=function(v) state.spin=v end})
PlayerSec:Toggle({label="Speed Hack", callback=function(v) state.speed=v if Hum then Hum.WalkSpeed= v and state.walk or state.normalSpeed end end})
PlayerSec:Slider({label="Speed", min=20,max=150,default=60,callback=function(v) state.walk=v if state.speed and Hum then Hum.WalkSpeed=v end end})
PlayerSec:Toggle({label="Fly", callback=function(v) state.fly=v end})
PlayerSec:Toggle({label="Bunny Hop", callback=function(v) state.bunny=v end})
PlayerSec:Button({label="Save Position", callback=function() if hrp then savedPos=hrp.Position end end})
PlayerSec:Button({label="Teleport to Saved", callback=function() if hrp and savedPos then hrp.CFrame=CFrame.new(savedPos) end end})
PlayerSec:Toggle({label="NoClip", callback=function(v) state.noclip=v end})
PlayerSec:Dropdown({label="Teleport To Player", options=(function() local t={} for _,p in pairs(Players:GetPlayers()) do if p~=LP then table.insert(t,p.Name) end end return t end)(), callback=function(selected)
    local target = Players:FindFirstChild(selected)
    if target and target.Character and hrp then hrp.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,5,0) end
end})

-- Rage Section
RageSec:Toggle({label="Auto Plant/Defuse", callback=function(v) state.autoTask=v end})
RageSec:Toggle({label="Tp To Me", callback=function(v) state.tpToMe=v end})
RageSec:Toggle({label="Infinite Ammo", callback=function(v) state.infiniteAmmo=v end})

-- Skins Section
SkinsSec:Toggle({label="Rainbow Hands", callback=function(v) state.rainbow=v end})
SkinsSec:Slider({label="Color Change Speed", min=0.1,max=2,default=0.1,callback=function(v) state.colorSpeed=v end})

-- RenderStepped Loop
RunService.RenderStepped:Connect(function()
    -- BunnyHop
    if state.bunny and Hum and Hum.FloorMaterial~=Enum.Material.Air then Hum.Jump=true end
    -- NoClip
    if state.noclip and LP.Character then
        for _,part in pairs(LP.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
    end
    -- Fly
    if state.fly and hrp and bodyVel then
        local moveDir=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir+=camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir-=camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir-=camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir+=camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir+=Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir-=Vector3.new(0,1,0) end
        if moveDir.Magnitude>0 then moveDir=moveDir.Unit*state.flySpeed end
        bodyVel.Velocity=moveDir
    end
end)
