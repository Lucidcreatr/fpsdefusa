-- SXMLIB Full GUI Loader & Tools (Yeni Kütüphane ile)
if game.PlaceId ~= 79393329652220 then return end -- sadece doğru oyun

-- Kütüphaneyi yükle (yukarıdaki sıfırdan oluşturduğumuz SXMLIB)
local success, SXMLIB = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua"))()
end)
if not success then
    warn("SXMLIB yüklenemedi: "..tostring(SXMLIB))
    return
end

-- Ana pencere
local Window = SXMLIB.new({Theme = SXMLIB.Themes.Black}):CreateWindow({
    Name = "SXMLIB Tools",
    Title = "SXMLIB Tools"
})

-- Bölümler
local ESPSec     = Window:Section("ESP")
local AimBotSec  = Window:Section("AimBot")
local PlayerSec  = Window:Section("Player")
local RageSec    = Window:Section("Rage")
local SkinsSec   = Window:Section("Skins")

-- Durum tablosu
local state = {
    boxESP=false, aimbot=false, drawCircle=false, circleSize=50,
    spin=false, speed=false, fly=false, bigHitbox=false, bunny=false,
    flySpeed=60, walk=60, normalSpeed=16, infiniteAmmo=false
}

local LP = game.Players.LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local savedPos

-- ESP Section
ESPSec:Toggle({label="Box ESP", default=false, callback=function(v) state.boxESP=v end})

-- AimBot Section
AimBotSec:Toggle({label="Aimbot", default=false, callback=function(v) state.aimbot=v end})
AimBotSec:Toggle({label="Draw Circle", default=false, callback=function(v) state.drawCircle=v end})
AimBotSec:Slider({label="Circle Size", default=state.circleSize, callback=function(v) state.circleSize=v end})

-- Player Section
PlayerSec:Slider({label="Fly Speed", default=state.flySpeed, callback=function(v) state.flySpeed=v end})
PlayerSec:Toggle({label="SpinBot", default=false, callback=function(v) state.spin=v end})
PlayerSec:Toggle({label="Speed Hack", default=false, callback=function(v)
    state.speed=v
    if Hum then Hum.WalkSpeed = v and state.walk or state.normalSpeed end
end})
PlayerSec:Slider({label="Speed", default=state.walk, callback=function(v)
    state.walk=v
    if state.speed and Hum then Hum.WalkSpeed=v end
end})
PlayerSec:Toggle({label="Fly", default=false, callback=function(v) state.fly=v end})
PlayerSec:Toggle({label="Bunny Hop", default=false, callback=function(v) state.bunny=v end})
PlayerSec:Button({label="Save Position", callback=function() if hrp then savedPos=hrp.Position end end})
PlayerSec:Button({label="Teleport to Saved", callback=function() if hrp and savedPos then hrp.CFrame=CFrame.new(savedPos) end end})
PlayerSec:Toggle({label="NoClip", default=false, callback=function(v) state.noclip=v end})

-- Teleport Dropdown
local playerNames = {}
for _,p in pairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerNames,p.Name) end
end
PlayerSec:Dropdown({label="Teleport To Player", options=playerNames, callback=function(selected)
    local target = Players:FindFirstChild(selected)
    if target and target.Character and hrp then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
    end
end})

-- Rage Section
RageSec:Toggle({label="Auto Plant/Defuse", default=false, callback=function(v) state.autoTask=v end})
RageSec:Toggle({label="Tp To Me", default=false, callback=function(v) state.tpToMe=v end})
RageSec:Toggle({label="Infinite Ammo", default=false, callback=function(v) state.infiniteAmmo=v end})

-- Skins Section
SkinsSec:Toggle({label="Rainbow Hands", default=false, callback=function(v) state.rainbow=v end})
SkinsSec:Slider({label="Color Change Speed", default=0.1, callback=function(v) state.colorSpeed=v end})

-- Notification
Window:Notify("SXMLIB Full GUI Loaded!",3)
