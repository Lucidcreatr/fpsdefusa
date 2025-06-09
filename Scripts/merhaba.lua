if game.PlaceId == 79393329652220 then

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "FemWare || ✂️Defusal FPS💣[TESTING]",
   Icon = 0,
   LoadingTitle = "FemWare Management",
   LoadingSubtitle = "by chinjungxx",
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
      Subtitle = "Cracked By FemWare",
      Note = "Key: 5262",
      FileName = "key_13121399",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"5262"}
   }
})

---------------------------------------------------------------------
--\tTABS & SECTIONS --------------------------------------------------
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
--\tSTATE VARIABLES --------------------------------------------------
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
local speedHackEnabled  = false
local hackedSpeed     = 60
local normalSpeed     = 20
local tpToMeConnection = nil
local speedHackConnection = nil
local savedPosition   = nil

-- Fly feature vars
local flyEnabled      = false
local flyConnection   = nil
local bodyVelocity    = nil
local flySpeed        = 60

---------------------------------------------------------------------
--\tSERVICES ---------------------------------------------------------
---------------------------------------------------------------------
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera        = workspace.CurrentCamera

---------------------------------------------------------------------
--\tESP UTILS --------------------------------------------------------
---------------------------------------------------------------------
local function createBox(character)
    local box = Drawing.new("Square")
    box.Visible   = false
    box.Color     = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled    = false
    box.Parent    = workspace.Camera
    box.Character = character

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
    table.insert(boxes, box)
end

local function removeBox(character)
    for i, box in ipairs(boxes) do
        if box.Character == character then
            box:Remove()
            table.remove(boxes, i)
            break
        end
    end
end

local function onPlayerAdded(newPlayer)
    local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
    if boxESPEnabled then createBox(character) end

    newPlayer.CharacterAdded:Connect(function(newCharacter)
        if boxESPEnabled then createBox(newCharacter) end
    end)
end

local function onPlayerRemoving(player)
    if player.Character then removeBox(player.Character) end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then onPlayerAdded(player) end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

---------------------------------------------------------------------
--\tUI CONTROLS ------------------------------------------------------
---------------------------------------------------------------------
-- ESP toggle
MainTab:CreateButton({
   Name = "Esp",
   Callback = function()
       boxESPEnabled = not boxESPEnabled
       if boxESPEnabled then
           for _, player in pairs(Players:GetPlayers()) do
               if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                   createBox(player.Character)
               end
           end
       else
           for _, box in pairs(boxes) do box:Remove() end
           boxes = {}
       end
   end,
})

-- Aimbot toggles & slider
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

-- Player utilities --------------------------------------------------
PlayerTab:CreateButton({
    Name = "Fly Up 5m",
    Callback = function()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0, 20, 0) end
    end,
})

-- SpinBot
PlayerTab:CreateToggle({
   Name = "SpinBot",
   CurrentValue = false,
   Flag = "spinbot",
   Callback = function(Value)
       spinBotEnabled = Value
       local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
       if not hrp then return end
       if spinBotEnabled then
           spinBotConnection = RunService.Stepped:Connect(function()
               if spinBotEnabled then hrp.RotVelocity = Vector3.new(0, 150, 0) end
           end)
       else
           if spinBotConnection then spinBotConnection:Disconnect() spinBotConnection = nil end
           hrp.RotVelocity = Vector3.zero
       end
   end,
})

-- Speed Hack
PlayerTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Flag = "speed_hack",
   Callback = function(Value)
       speedHackEnabled = Value
       local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Humanoid")
       if not humanoid then return end
       if speedHackEnabled then
           speedHackConnection = RunService.Stepped:Connect(function()
               if speedHackEnabled then humanoid.WalkSpeed = hackedSpeed end
           end)
       else
           if speedHackConnection then speedHackConnection:Disconnect() speedHackConnection = nil end
           humanoid.WalkSpeed = normalSpeed
       end
   end,
})

-- NEW: Fly toggle ---------------------------------------------------
PlayerTab:CreateToggle({
   Name = "Fly",
   CurrentValue = false,
   Flag = "fly_mode",
   Callback = function(Value)
       flyEnabled = Value
       local character  = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
       local hrp        = character:WaitForChild("HumanoidRootPart")

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
                   moveDir += Vector3.new(0,1,0)
               end
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                   moveDir -= Vector3.new(0,1,0)
               end
               if moveDir.Magnitude > 0 then
                   moveDir = moveDir.Unit * flySpeed
               end
               bodyVelocity.Velocity = moveDir
           end)
       else
           if flyConnection then flyConnection:Disconnect() flyConnection = nil end
           if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
       end
   end,
})

-- Save & Teleport ---------------------------------------------------
PlayerTab:CreateButton({
    Name = "Save Position",
    Callback = function()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then savedPosition = hrp.Position end
    end,
})

PlayerTab:CreateButton({
    Name = "Teleport to Saved",
    Callback = function()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and savedPosition then hrp.CFrame = CFrame.new(savedPosition) end
    end,
})

-- Rage: Tp To Me ----------------------------------------------------
RageTab:CreateToggle({
   Name = "Tp To Me",
   CurrentValue = false,
   Flag = "tp_to_me",
   Callback = function(Value)
       if Value then
           tpToMeConnection = RunService.Heartbeat:Connect(function()
               local localPos = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and Players.LocalPlayer.Character.HumanoidRootPart.Position
               if not localPos then return end
               for _, targetPlayer in pairs(Players:GetPlayers()) do
                   if targetPlayer ~= Players.LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                       targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(localPos)
                   end
               end
           end)
       else
           if tpToMeConnection then tpToMeConnection:Disconnect() tpToMeConnection = nil end
       end
   end,
})

-- Skins: Rainbow Hands ---------------------------------------------
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
        local nextTick   = 0
        local function changeColor()
            local leftArm = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms") and workspace.Camera.Arms.CSSArms:FindFirstChild("Left Arm")
            local rightArm = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms") and workspace.Camera.Arms.CSSArms:FindFirstChild("Right Arm")
            if leftArm and rightArm then
                colorIndex = (colorIndex % #colors) + 1
                leftArm.Color  = colors[colorIndex]
                rightArm.Color = colors[colorIndex]
            end
        end
        if rainbowHandsEnabled then
            nextTick = tick()
            RunService.Heartbeat:Connect(function()
                if rainbowHandsEnabled and tick() >= nextTick then
                    changeColor()
                    nextTick = tick() + (colorChangeSpeed or 0.1)
                end
            end)
        else
            local leftArm = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms") and workspace.Camera.Arms.CSSArms:FindFirstChild("Left Arm")
            local rightArm = workspace.Camera:FindFirstChild("Arms") and workspace.Camera.Arms:FindFirstChild("CSSArms") and workspace.Camera.Arms.CSSArms:FindFirstChild("Right Arm")
            if leftArm and rightArm then
                leftArm.Color  = Color3.new(1,1,1)
                rightArm.Color = Color3.new(1,1,1)
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

---------------------------------------------------------------------
--\tAIMBOT LOGIC -----------------------------------------------------
---------------------------------------------------------------------

circle.Visible   = false
circle.Color     = Color3.fromRGB(255, 0, 230)
circle.Thickness = 2
circle.Radius    = circleScale
circle.Filled    = false

local function onTargetDied() aimbotTarget = nil end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        local closest, shortest = nil, math.huge
        local mouseLoc = UserInputService:GetMouseLocation()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouseLoc.X, mouseLoc.Y)).Magnitude
                    if dist < circle.Radius and dist < shortest then
                        shortest, closest = dist, player
                    end
                end
            end
        end
        if closest then
            aimbotTarget = closest.Character.Head
            closest.Character.Humanoid.Died:Connect(onTargetDied)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then aimbotTarget = nil end
end)

RunService.RenderStepped:Connect(function()
    if aimbotTarget and aimbotTarget.Parent and aimbotTarget.Parent:FindFirstChild("Humanoid") and aimbotTarget.Parent.Humanoid.Health > 0 then
        local screenPos, onScreen = camera:WorldToViewportPoint(aimbotTarget.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)).Magnitude
            if dist < circle.Radius then
                camera.CFrame = CFrame.new(camera.CFrame.Position, aimbotTarget.Position)
            else
                aimbotTarget = nil
            end
        else
            aimbotTarget = nil
        end
    end

    if drawCircleEnabled then
        local m = UserInputService:GetMouseLocation()
        circle.Position = Vector2.new(m.X, m.Y)
    end
end)

end
