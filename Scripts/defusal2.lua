if game.PlaceId ~= 79393329652220 then return end

-- Kütüphaneyi yükle
local success, SXMLIB = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua"))()
end)
if not success then
    warn("SXMLIB yüklenemedi: "..tostring(SXMLIB))
    return
end

-- Tema
local theme = {
    Background = Color3.fromRGB(20,20,20),
    Primary = Color3.fromRGB(100,100,100),
    Text = Color3.fromRGB(255,255,255)
}

-- Ana pencere
local Window = SXMLIB:CreateWindow({Name="SXMLIB Tools", Title="SXMLIB Tools", Theme=theme})

-- Bölümler
local MainSec   = Window:CreateSection("ESP")
local AimBotSec = Window:CreateSection("AimBot")
local PlayerSec = Window:CreateSection("Player")
local RageSec   = Window:CreateSection("Rage")
local SkinsSec  = Window:CreateSection("Skins")

-- Durum tablosu
local state = {}

-- ESP
MainSec:Button({label="Toggle ESP", callback=function() state.boxESP = not state.boxESP print("ESP:",state.boxESP) end})

-- AimBot
AimBotSec:Toggle({label="Aimbot", callback=function(v) state.aimbot=v print("Aimbot:",v) end})
AimBotSec:Toggle({label="Draw Circle", callback=function(v) state.drawCircle=v print("Draw Circle:",v) end})
AimBotSec:Slider({label="Circle Size", min=5, max=50, default=50, callback=function(v) state.circleSize=v print("Circle Size:",v) end})
AimBotSec:Toggle({label="TriggerBot", callback=function(v) state.trigger=v print("TriggerBot:",v) end})
AimBotSec:Slider({label="Hitbox Size", min=1, max=350, default=5, callback=function(v) state.hitboxSize=v print("Hitbox Size:",v) end})
AimBotSec:Toggle({label="Big Hitbox", callback=function(v) state.bigHitbox=v print("Big Hitbox:",v) end})

-- Player
PlayerSec:Slider({label="Fly Speed", min=0, max=150, default=60, callback=function(v) state.flySpeed=v end})
PlayerSec:Toggle({label="SpinBot", callback=function(v) state.spin=v end})
PlayerSec:Toggle({label="Speed Hack", callback=function(v) state.speed=v end})
PlayerSec:Slider({label="Speed", min=20, max=150, default=60, callback=function(v) state.walk=v end})
PlayerSec:Toggle({label="Fly", callback=function(v) state.fly=v end})
PlayerSec:Toggle({label="Bunny Hop", callback=function(v) state.bunny=v end})
PlayerSec:Button({label="Save Position", callback=function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then state.savedPos=LP.Character.HumanoidRootPart.Position end end})
PlayerSec:Button({label="Teleport to Saved", callback=function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and state.savedPos then LP.Character.HumanoidRootPart.CFrame=CFrame.new(state.savedPos) end end})

-- Dropdown örnek
PlayerSec:Dropdown({
    label="Teleport To Player",
    options=(function()
        local t={}
        for _,p in pairs(game.Players:GetPlayers()) do if p~=game.Players.LocalPlayer then table.insert(t,p.Name) end
        return t
    end)(),
    callback=function(selected)
        local target = game.Players:FindFirstChild(selected)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
        end
    end
})

-- Rage
RageSec:Toggle({label="Auto Plant/Defuse", callback=function(v) state.autoTask=v end})
RageSec:Toggle({label="Tp To Me", callback=function(v) state.tpToMe=v end})
RageSec:Toggle({label="Infinite Ammo", callback=function(v) state.infiniteAmmo=v end})

-- Skins
SkinsSec:Toggle({label="Rainbow Hands", callback=function(v) state.rainbow=v end})
SkinsSec:Slider({label="Color Change Speed", min=0.1, max=2, default=0.1, callback=function(v) state.colorSpeed=v end})

-- Bildirim
Window:Notify("SXMLIB Full GUI Loaded!", 3)
