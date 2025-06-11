if game.PlaceId == 79393329652220  then -- GERÇEK PLACEID İLE DEĞİŞTİRİN (Örnek: Hedef oyunun PlaceId'sini buraya yazın)

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Rayfield kütüphanesi yüklenemedi: " .. tostring(Rayfield))
    return
end

local Window = Rayfield:CreateWindow({
    Name = "LCX TEAM | Defusal FPS",
    Icon = 0,
    LoadingTitle = "LCX Team Creator",
    LoadingSubtitle = "By Lucid",
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
        Invite = "Discord.gg/LCXteam",
        RememberJoins = true
    },
    KeySystem = true,
    KeySettings = {
        Title = "Defusal | Key",
        Subtitle = "Cracked By LcX9 TEAM",
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
local healthESPEnabled = false
local aimbotEnabled   = false
local drawCircleEnabled = false
local circleScale     = 50
local circle          = Drawing.new("Circle")
local aimbotTarget    = nil
local spinBotEnabled  = false
local spinBotConnection = nil
local speedHackEnabled = false
local hackedSpeed     = 60
local normalSpeed     = 16
local tpToMeConnection = nil
local speedHackConnection = nil
local savedPosition   = nil
local godModeEnabled  = false
local flyEnabled      = false
local flyConnection   = nil
local bodyVelocity    = nil
local flySpeed        = 60
local bigHitboxEnabled = false
local originalHeadSizes = {}
local bunnyHopEnabled = false
local bunnyHopConnection = nil
local rainbowHandsConnection = nil
local colorChangeSpeed = 0.1
local state = { speed = false, walk = 60, hitboxSize = 5, infiniteAmmo = false } -- State tablosu
local conns = {} -- Bağlantılar için tablo

---------------------------------------------------------------------
-- SERVICES ---------------------------------------------------------
---------------------------------------------------------------------
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera        = workspace.CurrentCamera
local LP            = Players.LocalPlayer
local Hum           = LP.Character and LP.Character:FindFirstChild("Humanoid")
local hrp           = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

---------------------------------------------------------------------
-- CHARACTER UPDATE HANDLING ----------------------------------------
---------------------------------------------------------------------
LP.CharacterAdded:Connect(function(character)
    Hum = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    if spinBotConnection then pcall(function() spinBotConnection:Disconnect() end) spinBotConnection = nil end
    if speedHackConnection then pcall(function() speedHackConnection:Disconnect() end) speedHackConnection = nil end
    if tpToMeConnection then pcall(function() tpToMeConnection:Disconnect() end) tpToMeConnection = nil end
    if flyConnection then pcall(function() flyConnection:Disconnect() end) flyConnection = nil end
    if bunnyHopConnection then pcall(function() bunnyHopConnection:Disconnect() end) bunnyHopConnection = nil end
    if rainbowHandsConnection then pcall(function() rainbowHandsConnection:Disconnect() end) rainbowHandsConnection = nil end
    if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
    if flyEnabled then
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.P = 1e4
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp
    end
end)

---------------------------------------------------------------------
-- ESP UTILS --------------------------------------------------------
---------------------------------------------------------------------
local function createBox(character)
    local success, result = pcall(function()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = Color3.new(1, 0, 0)
        box.Thickness = 2
        box.Filled = false
        box.Character = character

        local function updateBox()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local vector, onScreen = camera:WorldToViewportPoint(character.HumanoidRootPart.Position)
                if onScreen then
                    local size = 2000 / vector.Z
                    box.Size = Vector2.new(size, size)
                    box.Position = Vector2.new(vector.X - size / 2, vector.Y - size / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end

        RunService.RenderStepped:Connect(updateBox)
        table.insert(boxes, box)
    end)
    if not success then
        warn("ESP kutusu oluşturulurken hata: " .. tostring(result))
    end
end

local function removeBox(character)
    for i = #boxes, 1, -1 do
        if boxes[i].Character == character then
            boxes[i]:Remove()
            table.remove(boxes, i)
        end
    end
end

local function onPlayerAdded(newPlayer)
    if newPlayer == LP then return end
    local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
    if boxESPEnabled then createBox(character) end
    if bigHitboxEnabled then
        local head = character:FindFirstChild("Head")
        if head then
            originalHeadSizes[character] = head.Size
            head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
        end
    end

    newPlayer.CharacterAdded:Connect(function(newCharacter)
        if boxESPEnabled then createBox(newCharacter) end
        if bigHitboxEnabled then
            local head = newCharacter:FindFirstChild("Head")
            if head then
                originalHeadSizes[newCharacter] = head.Size
                head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
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
    if player ~= LP then onPlayerAdded(player) end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

---------------------------------------------------------------------
-- UI CONTROLS ------------------------------------------------------
---------------------------------------------------------------------
MainTab:CreateButton({
    Name = "Esp",
    Callback = function()
        boxESPEnabled = not boxESPEnabled
        if boxESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    createBox(player.Character)
                end
            end
        else
            for _, box in pairs(boxes) do pcall(function() box:Remove() end) end
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
        circle.Visible = Value
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
        circleScale = Value * 10
        circle.Radius = circleScale
    end,
})

PlayerTab:CreateButton({
    Name = "Fly Up 5m",
    Callback = function()
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0) end
    end,
})

PlayerTab:CreateToggle({
    Name = "SpinBot",
    CurrentValue = false,
    Flag = "spinbot",
    Callback = function(Value)
        spinBotEnabled = Value
        if not hrp then return end
        if spinBotEnabled then
            spinBotConnection = RunService.Stepped:Connect(function()
                if spinBotEnabled then hrp.RotVelocity = Vector3.new(0, 150, 0) end
            end)
        else
            if spinBotConnection then pcall(function() spinBotConnection:Disconnect() end) spinBotConnection = nil end
            hrp.RotVelocity = Vector3.zero
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(v)
        state.speed = v
        if Hum then
            Hum.WalkSpeed = v and state.walk or normalSpeed
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {20, 150},
    Increment = 2,
    CurrentValue = state.walk,
    Callback = function(s)
        state.walk = s
        if state.speed and Hum then
            Hum.WalkSpeed = s
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly_mode",
    Callback = function(Value)
        flyEnabled = Value
        if not hrp then return end
        if flyEnabled then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.P = 1e4
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.Parent = hrp

            flyConnection = RunService.Stepped:Connect(function()
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDir += camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDir -= camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDir -= camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDir += camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDir += Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDir -= Vector3.new(0, 1, 0)
                end
                if moveDir.Magnitude > 0 then
                    moveDir = moveDir.Unit * flySpeed
                end
                bodyVelocity.Velocity = moveDir
            end)
        else
            if flyConnection then pcall(function() flyConnection:Disconnect() end) flyConnection = nil end
            if bodyVelocity then pcall(function() bodyVelocity:Destroy() end) bodyVelocity = nil end
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Flag = "bunny_hop",
    Callback = function(Value)
        bunnyHopEnabled = Value
        if bunnyHopEnabled then
            bunnyHopConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.Space then
                    if Hum and Hum.FloorMaterial ~= Enum.Material.Air then
                        Hum.Jump = true
                    end
                end
            end)
        else
            if bunnyHopConnection then pcall(function() bunnyHopConnection:Disconnect() end) bunnyHopConnection = nil end
        end
    end,
})

PlayerTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        if hrp then savedPosition = hrp.Position end
    end,
})

PlayerTab:CreateButton({
    Name = "Teleport to Saved",
    Callback = function()
        if hrp and savedPosition then hrp.CFrame = CFrame.new(savedPosition) end
    end,
})

RageTab:CreateToggle({
    Name = "Tp To Me",
    CurrentValue = false,
    Flag = "tp_to_me",
    Callback = function(Value)
        if Value then
            local lastUpdate = tick()
            tpToMeConnection = RunService.Heartbeat:Connect(function()
                if tick() - lastUpdate < 0.1 then return end
                lastUpdate = tick()
                if not hrp then return end
                local localPos = hrp.Position
                for _, targetPlayer in pairs(Players:GetPlayers()) do
                    if targetPlayer ~= LP and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(localPos)
                    end
                end
            end)
        else
            if tpToMeConnection then pcall(function() tpToMeConnection:Disconnect() end) tpToMeConnection = nil end
        end
    end,
})

AimBotTab:CreateSlider({
    Name = "Hitbox Boyutu",
    Range = {1, 350},
    Increment = 1,
    CurrentValue = state.hitboxSize,
    Callback = function(v)
        state.hitboxSize = v
        if bigHitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(v, v, v)
                    end
                end
            end
        end
    end
})

AimBotTab:CreateToggle({
    Name = "Big Hitbox",
    CurrentValue = false,
    Flag = "big_hitbox",
    Callback = function(Value)
        bigHitboxEnabled = Value
        if bigHitboxEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        originalHeadSizes[player.Character] = head.Size
                        head.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                    end
                end
            end
        else
            for char, size in pairs(originalHeadSizes) do
                local head = char:FindFirstChild("Head")
                if head then
                    head.Size = size
                end
            end
            originalHeadSizes = {}
        end
    end,
})

SkinsTab:CreateToggle({
    Name = "Rainbow Hands",
    CurrentValue = false,
    Flag = "rainbow_hands",
    Callback = function(Value)
        local rainbowHandsEnabled = Value
        local colors = {
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(75, 0, 130),
            Color3.fromRGB(148, 0, 211)
        }
        local colorIndex = 1
        local nextTick = 0
        local function changeColor()
            local arms = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms")
            if not arms then return end
            local leftArm = arms:FindFirstChild("Left Arm")
            local rightArm = arms:FindFirstChild("Right Arm")
            if leftArm and rightArm then
                colorIndex = (colorIndex % #colors) + 1
                leftArm.Color = colors[colorIndex]
                rightArm.Color = colors[colorIndex]
            end
        end
        if rainbowHandsEnabled then
            nextTick = tick()
            rainbowHandsConnection = RunService.Heartbeat:Connect(function()
                if rainbowHandsEnabled and tick() >= nextTick then
                    changeColor()
                    nextTick = tick() + colorChangeSpeed
                end
            end)
        else
            if rainbowHandsConnection then pcall(function() rainbowHandsConnection:Disconnect() end) rainbowHandsConnection = nil end
            local arms = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms")
            if not arms then return end
            local leftArm = arms:FindFirstChild("Left Arm")
            local rightArm = arms:FindFirstChild("Right Arm")
            if leftArm and rightArm then
                leftArm.Color = Color3.new(1, 1, 1)
                rightArm.Color = Color3.new(1, 1, 1)
            end
        end
    end,
})

SkinsTab:CreateSlider({
    Name = "Color Change Speed",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "Seconds",
    CurrentValue = 0.1,
    Flag = "color_change_speed",
    Callback = function(Value) colorChangeSpeed = Value end,
})

RageTab:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Callback = function(v)
        state.infiniteAmmo = v
        if v then
            conns.ammo = RunService.Stepped:Connect(function()
                local wep = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
                if wep and wep:FindFirstChild("Ammo") then
                    wep.Ammo.Value = 999
                end
            end)
        else
            if conns.ammo then
                conns.ammo:Disconnect()
                conns.ammo = nil
            end
        end
    end
})

---------------------------------------------------------------------
-- AIMBOT LOGIC -----------------------------------------------------
---------------------------------------------------------------------
circle.Visible = false
circle.Color = Color3.fromRGB(255, 0, 230)
circle.Thickness = 2
circle.Radius = circleScale
circle.Filled = false

local function onTargetDied() aimbotTarget = nil end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        local closestPlayer = nil
        local shortestDistance = math.huge
        local mouseLocation = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLocation.X, mouseLocation.Y)).Magnitude
                    if distance < circle.Radius and distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        if closestPlayer then
            aimbotTarget = closestPlayer.Character:FindFirstChild("Head")
            if aimbotTarget then
                closestPlayer.Character.Humanoid.Died:Connect(onTargetDied)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimbotTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    if aimbotTarget and aimbotTarget.Parent and aimbotTarget.Parent:FindFirstChild("Humanoid") and aimbotTarget.Parent.Humanoid.Health > 0 then
        local screenPos, onScreen = camera:WorldToViewportPoint(aimbotTarget.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
            if distance < circle.Radius then
                camera.CFrame = CFrame.new(camera.CFrame.Position, aimbotTarget.Position)
            else
                aimbotTarget = nil
            end
        else
            aimbotTarget = nil
        end
    end
    if drawCircleEnabled then
        circle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    end
end)

end
