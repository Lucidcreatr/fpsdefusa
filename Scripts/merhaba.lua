if game.PlaceId == 79393329652220 then

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
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
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = ""
    },
    Discord = {
        Enabled = true,
        Invite = "https://discord.gg/3vvDZMG6bk",
        RememberJoins = true
    },
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
-- TABS & SECTIONS --------------------------------------------------
---------------------------------------------------------------------
local MainTab   = Window:CreateTab("ESP",   nil)
local AimBotTab = Window:CreateTab("AimBot", nil)
local PlayerTab = Window:CreateTab("Player", nil)
local RageTab   = Window:CreateTab("Rage",   nil)
local SkinsTab  = Window:CreateTab("Skins",  nil)

MainTab:CreateSection("Main")
AimBotTab:CreateSection("Main")
PlayerTab:CreateSection("Main")
RageTab:CreateSection("Main")
SkinsTab:CreateSection("Main")

---------------------------------------------------------------------
-- STATE VARIABLES --------------------------------------------------
---------------------------------------------------------------------
local boxESPEnabled   = false
local boxes           = {}
local aimbotEnabled   = false
local drawCircleEnabled = false
local circleScale     = 50
local circle          = Drawing.new("Circle")
local aimbotTarget    = nil
local spinBotEnabled  = false
local spinBotConnection = nil
local speedHackEnabled = false
local hackedSpeed     = 60
local normalSpeed     = 20
local tpToMeConnection = nil
local speedHackConnection = nil
local savedPosition   = nil
local flyEnabled      = false
local flyConnection   = nil
local bodyVelocity    = nil
local flySpeed        = 60
local colorChangeSpeed = 0.1
local bigHitboxEnabled = false
local originalHeadSizes = {}
local bunnyHopEnabled = false
local bunnyHopConnection = nil
local rainbowHandsConnection = nil

---------------------------------------------------------------------
-- SERVICES ---------------------------------------------------------
---------------------------------------------------------------------
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera        = workspace.CurrentCamera

---------------------------------------------------------------------
-- ESP UTILS --------------------------------------------------------
---------------------------------------------------------------------
local function createBox(character)
    local success, result = pcall(function()
        local box = Drawing.new("Square")
        box.Visible   = false
        box.Color     = Color3.new(1, 0, 0)
        box.Thickness = 2
        box.Filled    = false
        table.insert(boxes, {box = box, character = character})

        local function updateBox()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                if onScreen then
                    local size = 2000 / vector.Z
                    box.Size     = Vector2.new(size, size)
                    box.Position = Vector2.new(vector.X - size / 2, vector.Y - size / 2)
                    box.Visible  = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end

        RunService.RenderStepped:Connect(updateBox)
    end)
    if not success then
        warn("ESP kutusu oluşturulurken hata: " .. tostring(result))
    end
end

local function removeBox(character)
    for i, entry in ipairs(boxes) do
        if entry.character == character then
            pcall(function()
                entry.box:Remove()
                table.remove(boxes, i)
            end)
            break
        end
    end
end

local function onPlayerAdded(newPlayer)
    if newPlayer == Players.LocalPlayer then return end
    local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
    if boxESPEnabled then createBox(character) end
    if bigHitboxEnabled then
        local head = character:FindFirstChild("Head")
        if head then
            originalHeadSizes[character] = head.Size
            head.Size = Vector3.new(5, 5, 5)
        end
    end

    newPlayer.CharacterAdded:Connect(function(newCharacter)
        if boxESPEnabled then createBox(newCharacter) end
        if bigHitboxEnabled then
            local head = newCharacter:FindFirstChild("Head")
            if head then
                originalHeadSizes[newCharacter] = head.Size
                head.Size = Vector3.new(5, 5, 5)
            end
        end
    end)
end

local function onPlayerRemoving(player)
    if player.Character then
        removeBox(player.Character)
        if bigHitboxEnabled and originalHeadSizes[player.Character] then
            local head = player.Character:FindFirstChild("Head")
            if head then
                head.Size = originalHeadSizes[player.Character]
            end
            originalHeadSizes[player.Character] = nil
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then onPlayerAdded(player) end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Karakter yeniden doğduğunda bağlantıları temizle
Players.LocalPlayer.CharacterAdded:Connect(function()
    if spinBotConnection then pcall(function() spinBotConnection:Disconnect() end) spinBotConnection = nil end
    if speedHackConnection then pcall(function() speedHackConnection:Disconnect() end) speedHackConnection = nil end
    if flyConnection then pcall(function() flyConnection:Disconnect() end) flyConnection = nil end
    if tpToMeConnection then pcall(function() tpToMeConnection:Disconnect() end) tpToMeConnection = nil end
    if bunnyHopConnection then pcall(function() bunnyHopConnection:Disconnect() end) bunnyHopConnection = nil end
    if rainbowHandsConnection then pcall(function() rainbowHandsConnection:Disconnect() end) rainbowHandsConnection = nil end
end)

---------------------------------------------------------------------
-- UI CONTROLS ------------------------------------------------------
---------------------------------------------------------------------
MainTab:CreateButton({
    Name = "Esp",
    Callback = function()
        boxESPEnabled = not boxESPEnabled
        if boxESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    createBox(player.Character)
                end
            end
        else
            for _, entry in pairs(boxes) do pcall(function() entry.box:Remove() end) end
            boxes = {}
        end
    end,
})

AimBotTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Flag = "aim",
    Callback = function(Value) aimbotEnabled = Value end,
})

AimBotTab:CreateToggle({
    Name = "Draw Aimbot Circle",
    CurrentValue = false,
    Flag = "draw_circle",
    Callback = function(Value)
        drawCircleEnabled = Value
        circle.Visible    = Value
    end,
})

AimBotTab:CreateSlider({
    Name = "Aimbot Circle Size",
    Range = {5, 40},
    Increment = 1,
    Suffix = "Size",
    CurrentValue = 5,
    Flag = "circle_size",
    Callback = function(Value)
        circleScale   = Value * 10
        circle.Radius = circleScale
    end,
})

PlayerTab:CreateButton({
    Name = "Fly Up 5m",
    Callback = function()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0) end
    end,
