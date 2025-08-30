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

-- Gri tema (yoksa Black kullan)
local theme = SXMLIB.Themes.Black

-- Ana pencere
local Window = SXMLIB:CreateWindow({
    Name = "SXMLIB Tools",
    Theme = theme
})

-- Bölümler
local MainSec   = Window:CreateSection("ESP")
local AimBotSec = Window:CreateSection("AimBot")
local PlayerSec = Window:CreateSection("Player")
local RageSec   = Window:CreateSection("Rage")
local SkinsSec  = Window:CreateSection("Skins")

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

-- Main Section
MainSec:Button({
    label="Toggle ESP",
    callback=function()
        state.boxESP = not state.boxESP
        print("ESP:", state.boxESP)
    end
})

-- AimBot Section
AimBotSec:Toggle({
    label="Aimbot",
    callback=function(v)
        state.aimbot = v
        print("Aimbot:", v)
    end
})

AimBotSec:Toggle({
    label="Draw Circle",
    callback=function(v)
        state.drawCircle = v
        print("Draw Circle:", v)
    end
})

AimBotSec:Slider({
    label="Circle Size",
    min=5, max=50, default=50,
    callback=function(v)
        state.circleSize = v
        print("Circle Size:", v)
    end
})

AimBotSec:Toggle({
    label="TriggerBot",
    callback=function(v)
        state.trigger = v
        print("TriggerBot:", v)
    end
})

AimBotSec:Slider({
    label="Hitbox Size",
    min=1, max=350, default=5,
    callback=function(v)
        state.hitboxSize = v
        print("Hitbox Size:", v)
    end
})

AimBotSec:Toggle({
    label="Big Hitbox",
    callback=function(v)
        state.bigHitbox = v
        print("Big Hitbox:", v)
    end
})

-- Player Section
PlayerSec:Slider({
    label="Fly Speed",
    min=0, max=150, default=60,
    callback=function(v) state.flySpeed=v end
})

PlayerSec:Toggle({
    label="SpinBot",
    callback=function(v) state.spin=v end
})

PlayerSec:Toggle({
    label="Speed Hack",
    callback=function(v)
        state.speed = v
        if Hum then Hum.WalkSpeed = v and state.walk or state.normalSpeed end
    end
})

PlayerSec:Slider({
    label="Speed",
    min=20, max=150, default=60,
    callback=function(v)
        state.walk=v
        if state.speed and Hum then Hum.WalkSpeed=v end
    end
})

PlayerSec:Toggle({
    label="Fly",
    callback=function(v) state.fly=v end
})

PlayerSec:Toggle({
    label="Bunny Hop",
    callback=function(v) state.bunny=v end
})

PlayerSec:Button({
    label="Save Position",
    callback=function() if hrp then savedPos=hrp.Position end end
})

PlayerSec:Button({
    label="Teleport to Saved",
    callback=function() if hrp and savedPos then hrp.CFrame=CFrame.new(savedPos) end end
})

PlayerSec:Toggle({
    label="NoClip",
    callback=function(v) state.noclip=v end
})

PlayerSec:Dropdown({
    label="Teleport To Player",
    options=(function()
        local t={}
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LP then table.insert(t,p.Name) end
        end
        return t
    end)(),
    callback=function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
        end
    end
})

-- Rage Section
RageSec:Toggle({
    label="Auto Plant/Defuse",
    callback=function(v) state.autoTask=v end
})

RageSec:Toggle({
    label="Tp To Me",
    callback=function(v) state.tpToMe=v end
})

RageSec:Toggle({
    label="Infinite Ammo",
    callback=function(v) state.infiniteAmmo=v end
})

-- Skins Section
SkinsSec:Toggle({
    label="Rainbow Hands",
    callback=function(v) state.rainbow=v end
})

SkinsSec:Slider({
    label="Color Change Speed",
    min=0.1, max=2, default=0.1,
    callback=function(v) state.colorSpeed=v end
})

-- Notification
Window:Notify("SXMLIB Full GUI Loaded!", 3)
