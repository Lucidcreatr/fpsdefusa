--[[
    Defusal FPS Utility Script
    + ESP / Aimbot / Player utilities
    + Big Hitbox & Bunny Hop requested by user
    (Rayfield URL updated 2025‑06‑10)
--]]

if game.PlaceId ~= 79393329652220 then return end

---------------------------------------------------------------------
-- RAYFIELD BOOTSTRAP -----------------------------------------------
---------------------------------------------------------------------
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/Rayfield-Development/Rayfield/main/source'))()
end)
if not success then
    warn("Rayfield kütüphanesi yüklenemedi: " .. tostring(Rayfield))
    return
end

local Window = Rayfield:CreateWindow({
    Name = "LCX TEAM || Defusal FPS",
    Icon = 0,
    LoadingTitle = "LCX Management",
    LoadingSubtitle = "by Lucidcreatr",
    Theme = "Serenity",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {Enabled = true, FolderName = nil, FileName = ""},
    Discord = {Enabled = true, Invite = "https://discord.gg/3vvDZMG6bk", RememberJoins = true},
    KeySystem = true,
    KeySettings = {
        Title = "Defusal | Key",
        Subtitle = "Cracked By LCX",
        Note = "Key: 5262",
        FileName = "key_13121399",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"5262"}
    }
})

---------------------------------------------------------------------
-- TABS / SECTIONS --------------------------------------------------
---------------------------------------------------------------------
local MainTab   = Window:CreateTab("ESP",   nil)
local AimBotTab = Window:CreateTab("AimBot", nil)
local PlayerTab = Window:CreateTab("Player", nil)
local RageTab   = Window:CreateTab("Rage",   nil)
local SkinsTab  = Window:CreateTab("Skins",  nil)

for _, t in ipairs({MainTab, AimBotTab, PlayerTab, RageTab, SkinsTab}) do
    t:CreateSection("Main")
end

---------------------------------------------------------------------
-- STATE ------------------------------------------------------------
---------------------------------------------------------------------
local boxESPEnabled, aimbotEnabled, drawCircleEnabled = false, false, false
local bigHitboxEnabled, bunnyHopEnabled = false, false
local speedHackEnabled, spinBotEnabled, flyEnabled   = false, false, false
local hackedSpeed, normalSpeed = 60, 20
local flySpeed, circleScale = 60, 50
local colorChangeSpeed = 0.1

local boxes, originalHeadSizes = {}, {}
local spinBotConnection, speedHackConnection, flyConnection = nil, nil, nil
local tpToMeConnection, bunnyHopConnection, rainbowHandsConnection = nil, nil, nil
local savedPosition, aimbotTarget = nil, nil

---------------------------------------------------------------------
-- SERVICES ---------------------------------------------------------
---------------------------------------------------------------------
local Players, RunService, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local camera = workspace.CurrentCamera

---------------------------------------------------------------------
-- ESP --------------------------------------------------------------
---------------------------------------------------------------------
local function createBox(character)
    local box = Drawing.new("Square")
    box.Visible, box.Color, box.Thickness, box.Filled = false, Color3.new(1,0,0), 2, false
    table.insert(boxes, {box = box, character = character})
    RunService.RenderStepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
            if onScreen then
                local size = 2000/pos.Z
                box.Size     = Vector2.new(size, size)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
                box.Visible  = true
            else box.Visible = false end
        else box.Visible = false end
    end)
end

local function removeBox(character)
    for i,v in ipairs(boxes) do
        if v.character == character then pcall(function() v.box:Remove() end) table.remove(boxes,i) break end
    end
end

local function applyBigHitbox(char)
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    if bigHitboxEnabled then
        originalHeadSizes[char] = originalHeadSizes[char] or head.Size
        head.Size = Vector3.new(5,5,5)
    elseif originalHeadSizes[char] then
        head.Size = originalHeadSizes[char]
        originalHeadSizes[char] = nil
    end
end

local function onPlayerAdded(plr)
    if plr == Players.LocalPlayer then return end
    if boxESPEnabled and plr.Character then createBox(plr.Character) end
    if plr.Character then applyBigHitbox(plr.Character) end
    plr.CharacterAdded:Connect(function(c)
        if boxESPEnabled then createBox(c) end
        applyBigHitbox(c)
    end)
end

for _,p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(plr) if plr.Character then removeBox(plr.Character) end end)

---------------------------------------------------------------------
-- UI : ESP ---------------------------------------------------------
---------------------------------------------------------------------
MainTab:CreateToggle({
    Name = "ESP Boxes",
    CurrentValue = false,
    Callback = function(val)
        boxESPEnabled = val
        if not val then for _,v in pairs(boxes) do pcall(function() v.box:Remove() end) end boxes = {} else
            for _,p in ipairs(Players:GetPlayers()) do if p~=Players.LocalPlayer and p.Character then createBox(p.Character) end end
        end
    end,
})

---------------------------------------------------------------------
-- UI : Hitbox & BunnyHop -------------------------------------------
---------------------------------------------------------------------
RageTab:CreateToggle({
    Name = "Big Hitbox (others)",
    CurrentValue = false,
    Callback = function(val)
        bigHitboxEnabled = val
        for _,p in ipairs(Players:GetPlayers()) do if p~=Players.LocalPlayer then applyBigHitbox(p.Character) end end
    end,
})

PlayerTab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Callback = function(val)
        bunnyHopEnabled = val
        if val then
            bunnyHopConnection = UIS.InputBegan:Connect(function(input, gp)
                if gp or input.KeyCode ~= Enum.KeyCode.Space then return end
                local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
            end)
        elseif bunnyHopConnection then bunnyHopConnection:Disconnect() bunnyHopConnection=nil end
    end,
})

---------------------------------------------------------------------
-- (rest of code unchanged: aimbot, speed/fly, etc.)
---------------------------------------------------------------------
--  You can keep existing aimbot, speed hack, fly, rainbow hands ...
--  For brevity not repeated here; merge with prior version if needed.
---------------------------------------------------------------------
