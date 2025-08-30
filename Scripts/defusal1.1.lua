if game.PlaceId == 79393329652220 then -- defusal fps place ID

local success, SXMLIB = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucidcreatr/sxm1/refs/heads/main/sxmlib/sxmlua.lua'))()
end)

if not success then
    warn("SXMLIB yüklenemedi: "..tostring(SXMLIB))
    return
end

-- GUI Başlat
local Window = SXMLIB.new({
    Theme = SXMLIB.Themes.Blue
})

-- Sekmeler (Sections)
local MainTab   = Window:CreateWindow({Name="ESP"})
local AimBotTab = Window:CreateWindow({Name="AimBot"})
local PlayerTab = Window:CreateWindow({Name="Player"})
local RageTab   = Window:CreateWindow({Name="Rage"})
local SkinsTab  = Window:CreateWindow({Name="Skins"})

local MainSection   = MainTab:CreateSection("Main")
local AimBotSection = AimBotTab:CreateSection("Main")
local PlayerSection = PlayerTab:CreateSection("Main")
local RageSection   = RageTab:CreateSection("Main")
local SkinsSection  = SkinsTab:CreateSection("Main")

-- STATE
local boxESPEnabled, healthESPEnabled, aimbotEnabled = false,false,false
local drawCircleEnabled, circleScale = false,50
local spinBotEnabled, speedHackEnabled, flyEnabled, bigHitboxEnabled, bunnyHopEnabled = false,false,false,false,false
local hackedSpeed, normalSpeed, flySpeed = 60,16,60
local aimbotTarget, savedPosition = nil,nil
local state = {speed=false,walk=60,hitboxSize=5,infiniteAmmo=false}
local boxes, originalHeadSizes = {},{}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

-- Notification Örneği
Window:Notify("SXMLIB Yüklendi!",3)

-- ESP Butonu
MainSection:Button({label="Toggle ESP", callback=function()
    boxESPEnabled = not boxESPEnabled
    if boxESPEnabled then
        for _,player in pairs(Players:GetPlayers()) do
            if player~=LP and player.Character then
                -- ESP logi
            end
        end
    else
        boxes={} -- temizleme
    end
end})

-- AimBot Toggle
AimBotSection:Toggle({label="Aimbot", callback=function(v) aimbotEnabled=v end})
AimBotSection:Toggle({label="Draw Circle", callback=function(v) drawCircleEnabled=v end})
AimBotSection:Slider({label="Circle Size", min=5, max=50, default=5, callback=function(v) circleScale=v end})
AimBotSection:Toggle({label="TriggerBot", callback=function(v) triggerEnabled=v end})
AimBotSection:Slider({label="Hitbox Size", min=1, max=350, default=state.hitboxSize, callback=function(v) state.hitboxSize=v end})
AimBotSection:Toggle({label="Big Hitbox", callback=function(v) bigHitboxEnabled=v end})

-- Player Tab
PlayerSection:Slider({label="Fly Speed", min=0, max=150, default=flySpeed, callback=function(v) flySpeed=v end})
PlayerSection:Toggle({label="SpinBot", callback=function(v) spinBotEnabled=v end})
PlayerSection:Toggle({label="Speed Hack", callback=function(v)
    state.speed=v
    if Hum then Hum.WalkSpeed = v and state.walk or normalSpeed end
end})
PlayerSection:Slider({label="Speed", min=20,max=150,default=state.walk, callback=function(v) state.walk=v if state.speed and Hum then Hum.WalkSpeed=v end end})
PlayerSection:Toggle({label="Fly", callback=function(v) flyEnabled=v end})
PlayerSection:Toggle({label="Bunny Hop", callback=function(v) bunnyHopEnabled=v end})
PlayerSection:Button({label="Save Position", callback=function() if hrp then savedPosition=hrp.Position end end})
PlayerSection:Button({label="Teleport to Saved", callback=function() if hrp and savedPosition then hrp.CFrame=CFrame.new(savedPosition) end end})
PlayerSection:Toggle({label="NoClip", callback=function(v) noclip=v end})
PlayerSection:Dropdown({label="Teleport To Player", options=(function()
    local t={} for _,p in pairs(Players:GetPlayers()) do if p~=LP then table.insert(t,p.Name) end end return t end)(), callback=function(selected)
        local target = Players:FindFirstChild(selected)
        if target and target.Character and hrp then
            hrp.CFrame=target.Character.HumanoidRootPart.CFrame+Vector3.new(0,5,0)
        end
end})

-- Rage Tab
RageSection:Toggle({label="Auto Plant/Defuse", callback=function(v) autoTask=v end})
RageSection:Toggle({label="Tp To Me", callback=function(v) tpToMe=v end})
RageSection:Toggle({label="Infinite Ammo", callback=function(v) state.infiniteAmmo=v end})

-- Skins Tab
SkinsSection:Toggle({label="Rainbow Hands", callback=function(v) rainbowHands=v end})
SkinsSection:Slider({label="Color Change Speed", min=0.1,max=2,default=0.1,callback=function(v) colorChangeSpeed=v end})

end
