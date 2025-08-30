-- SXMLIB Full GUI Loader & Tools
if game.PlaceId ~= 79393329652220 then return end -- sadece doğru oyun

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
local Window = SXMLIB:CreateWindow({
    Name = "SXMLIB Tools",
    Theme = themes.Blue
})

-- Tabs
local MainTab   = Window:CreateTab("ESP")
local AimBotTab = Window:CreateTab("AimBot")
local PlayerTab = Window:CreateTab("Player")
local RageTab   = Window:CreateTab("Rage")
local SkinsTab  = Window:CreateTab("Skins")

-- Sections
local MainSec   = MainTab:CreateSection("Main")
local AimBotSec = AimBotTab:CreateSection("Main")
local PlayerSec = PlayerTab:CreateSection("Main")
local RageSec   = RageTab:CreateSection("Main")
local SkinsSec  = SkinsTab:CreateSection("Main")

-- STATE
local LP = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

local state = {
    boxESP=false, aimbot=false, drawCircle=false, circleScale=50,
    spin=false, speed=false, fly=false, flySpeed=60, walk=16,
    bigHitbox=false, bunny=false, savedPos=nil, infiniteAmmo=false
}
local boxes, originalHeads = {},{}

-- Notifikasyon
Window:Notify("SXMLIB Full GUI Loaded", 3)

-- Helper: Create ESP Box
local function createBox(char)
    local box = Drawing.new("Square")
    box.Visible = true
    box.Color = Color3.new(1,0,0)
    box.Thickness = 2
    box.Filled = false
    table.insert(boxes, box)

    RunService.RenderStepped:Connect(function()
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
            if onScreen then
                local size = 2000 / pos.Z
                box.Size = Vector2.new(size,size)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)
end

-- Main Tab
MainSec:CreateButton({
    Name = "Toggle ESP",
    Callback = function()
        state.boxESP = not state.boxESP
        if state.boxESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then createBox(plr.Character) end
            end
        else
            for _, b in pairs(boxes) do pcall(function() b:Remove() end) end
            boxes = {}
        end
    end
})

-- AimBot Tab
AimBotSec:CreateToggle({Name="Aimbot", CurrentValue=false, Callback=function(v) state.aimbot=v end})
AimBotSec:CreateToggle({Name="Draw Circle", CurrentValue=false, Callback=function(v) state.drawCircle=v end})
AimBotSec:CreateSlider({Name="Circle Size", Min=5,Max=50,Default=50,Callback=function(v) state.circleScale=v end})
AimBotSec:CreateToggle({Name="TriggerBot", CurrentValue=false, Callback=function(v) state.trigger=v end})
AimBotSec:CreateSlider({Name="Hitbox Size", Min=1,Max=350,Default=5,Callback=function(v) state.hitboxSize=v end})
AimBotSec:CreateToggle({Name="Big Hitbox", CurrentValue=false, Callback=function(v) state.bigHitbox=v end})

-- Player Tab
PlayerSec:CreateSlider({Name="Fly Speed", Min=0,Max=150,Default=60,Callback=function(v) state.flySpeed=v end})
PlayerSec:CreateToggle({Name="SpinBot", CurrentValue=false, Callback=function(v) state.spin=v end})
PlayerSec:CreateToggle({Name="Speed Hack", CurrentValue=false, Callback=function(v) 
    state.speed=v
    if Hum then Hum.WalkSpeed=v and state.walk or 16 end
end})
PlayerSec:CreateSlider({Name="Speed", Min=20,Max=150,Default=60,Callback=function(v) state.walk=v if state.speed and Hum then Hum.WalkSpeed=v end end})
PlayerSec:CreateToggle({Name="Fly", CurrentValue=false, Callback=function(v) state.fly=v end})
PlayerSec:CreateToggle({Name="Bunny Hop", CurrentValue=false, Callback=function(v) state.bunny=v end})
PlayerSec:CreateButton({Name="Save Position", Callback=function() if hrp then state.savedPos=hrp.Position end end})
PlayerSec:CreateButton({Name="Teleport to Saved", Callback=function() if hrp and state.savedPos then hrp.CFrame=CFrame.new(state.savedPos) end end})
PlayerSec:CreateToggle({Name="NoClip", CurrentValue=false, Callback=function(v) state.noclip=v end})
PlayerSec:CreateDropdown({
    Name="Teleport To Player",
    Options=(function() local t={} for _,p in pairs(Players:GetPlayers()) do if p~=LP then table.insert(t,p.Name) end end return t end)(),
    Callback=function(sel)
        local target=Players:FindFirstChild(sel)
        if target and target.Character and hrp then
            hrp.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,5,0)
        end
    end
})

-- Rage Tab
RageSec:CreateToggle({Name="Auto Plant/Defuse", CurrentValue=false, Callback=function(v) state.autoTask=v end})
RageSec:CreateToggle({Name="Tp To Me", CurrentValue=false, Callback=function(v) state.tpToMe=v end})
RageSec:CreateToggle({Name="Infinite Ammo", CurrentValue=false, Callback=function(v) state.infiniteAmmo=v end})

-- Skins Tab
SkinsSec:CreateToggle({Name="Rainbow Hands", CurrentValue=false, Callback=function(v) state.rainbow=v end})
SkinsSec:CreateSlider({Name="Color Change Speed", Min=0.1,Max=2,Default=0.1,Callback=function(v) state.colorSpeed=v end})

-- RenderStepped loop
RunService.RenderStepped:Connect(function()
    -- Buraya ESP, Aimbot, Circle vs callbackleri eklenebilir
end)
