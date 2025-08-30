-- SXMLIB Full GUI Loader & Tools (Gri Tema)
if game.PlaceId ~= 79393329652220 then return end -- sadece doğru oyun

-- Kütüphaneyi yükle
local success, SXMLIB = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua"))()
end)
if not success then
    warn("SXMLIB yüklenemedi: "..tostring(SXMLIB))
    return
end

-- Gri tema
local theme = SXMLIB.Themes.Gray

-- Ana pencere
local Window = SXMLIB:Window({
    Name = "SXMLIB Tools",
    Theme = theme
})

-- Tablolar
local MainTab   = Window:Tab("ESP")
local AimBotTab = Window:Tab("AimBot")
local PlayerTab = Window:Tab("Player")
local RageTab   = Window:Tab("Rage")
local SkinsTab  = Window:Tab("Skins")

-- Bölümler
local MainSec   = MainTab:Section("Main")
local AimBotSec = AimBotTab:Section("Main")
local PlayerSec = PlayerTab:Section("Main")
local RageSec   = RageTab:Section("Main")
local SkinsSec  = SkinsTab:Section("Main")

-- Durum tablosu
local state = {
    boxESP=false, aimbot=false, drawCircle=false, circleSize=50,
    spin=false, speed=false, fly=false, bigHitbox=false, bunny=false,
    flySpeed=60, normalSpeed=16, walk=60, infiniteAmmo=false
}

local LP = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local savedPos

-- ESP Button
MainSec:Button("Toggle ESP", function()
    state.boxESP = not state.boxESP
    print("ESP:", state.boxESP)
end)

-- AimBot Toggles / Slider
AimBotSec:Toggle("Aimbot", function(v)
    state.aimbot = v
    print("Aimbot:", v)
end)

AimBotSec:Toggle("Draw Circle", function(v)
    state.drawCircle = v
    print("Draw Circle:", v)
end)

AimBotSec:Slider("Circle Size", 5, 50, 50, function(v)
    state.circleSize = v
    print("Circle Size:", v)
end)

AimBotSec:Toggle("TriggerBot", function(v)
    state.trigger = v
    print("TriggerBot:", v)
end)

AimBotSec:Slider("Hitbox Size", 1, 350, 5, function(v)
    state.hitboxSize = v
    print("Hitbox Size:", v)
end)

AimBotSec:Toggle("Big Hitbox", function(v)
    state.bigHitbox = v
    print("Big Hitbox:", v)
end)

-- Player Section
PlayerSec:Slider("Fly Speed", 0, 150, 60, function(v) state.flySpeed=v end)
PlayerSec:Toggle("SpinBot", function(v) state.spin=v end)
PlayerSec:Toggle("Speed Hack", function(v)
    state.speed = v
    if Hum then Hum.WalkSpeed = v and state.walk or state.normalSpeed end
end)
PlayerSec:Slider("Speed", 20, 150, 60, function(v)
    state.walk=v
    if state.speed and Hum then Hum.WalkSpeed=v end
end)
PlayerSec:Toggle("Fly", function(v) state.fly=v end)
PlayerSec:Toggle("Bunny Hop", function(v) state.bunny=v end)
PlayerSec:Button("Save Position", function() if hrp then savedPos=hrp.Position end end)
PlayerSec:Button("Teleport to Saved", function() if hrp and savedPos then hrp.CFrame=CFrame.new(savedPos) end end)
PlayerSec:Toggle("NoClip", function(v) state.noclip=v end)

PlayerSec:Dropdown("Teleport To Player", (function()
    local t={}
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP then table.insert(t,p.Name) end
    end
    return t
end)(), function(selected)
    local target = Players:FindFirstChild(selected)
    if target and target.Character and hrp then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
    end
end)

-- Rage Section
RageSec:Toggle("Auto Plant/Defuse", function(v) state.autoTask=v end)
RageSec:Toggle("Tp To Me", function(v) state.tpToMe=v end)
RageSec:Toggle("Infinite Ammo", function(v) state.infiniteAmmo=v end)

-- Skins Section
SkinsSec:Toggle("Rainbow Hands", function(v) state.rainbow=v end)
SkinsSec:Slider("Color Change Speed", 0.1, 2, 0.1, function(v) state.colorSpeed=v end)

-- Notification
Window:Notify("SXMLIB Full GUI Loaded!", 3)
