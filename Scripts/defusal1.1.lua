--!strict
if game.PlaceId ~= 79393329652220 then return end

----------------------------------------------------------------
--  RAYFIELD
----------------------------------------------------------------
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok then warn("Rayfield load error: "..tostring(Rayfield)) return end

----------------------------------------------------------------
--  WINDOW & TABS
----------------------------------------------------------------
local W = Rayfield:CreateWindow({
    Name            = "LCX TEAM | Defusal FPS",
    LoadingTitle    = "LCX TEAM",
    LoadingSubtitle = "FPS Pro GUI Aktif Ediliyor...",
    Theme           = Rayfield.Themes.Serenity,
    DisableBuildWarnings = true
})

local T = {
    ESP    = W:CreateTab("🧿 ESP"),
    Aim    = W:CreateTab("🎯 Aim"),
    Player = W:CreateTab("🏃 Player"),
    Misc   = W:CreateTab("🧪 Misc")
}

--  ✅  pair‑iterate (eski hatalı satır düzeltildi)
for _,tab in pairs(T) do
    tab:CreateSection("Ana Seçenekler")
end

----------------------------------------------------------------
--  SERVICES
----------------------------------------------------------------
local Plrs, RS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local Cam   = workspace.CurrentCamera
local LP    = Plrs.LocalPlayer
local Char  = LP.Character or LP.CharacterAdded:Wait()
local Hum   = Char:WaitForChild("Humanoid")
local Root  = Char:WaitForChild("HumanoidRootPart")

----------------------------------------------------------------
--  STATE
----------------------------------------------------------------
local state = {
    esp=false, wall=false,
    bhop=false, bhopDelay=0.05,
    speed=false, walk=16,
    fly=false,
    aim=false, circle=false,
    hitbox=false, hitboxSize=5,
    espColor = Color3.fromRGB(255,0,0)
}

local conns, boxes, hlights, headOrig, healthTxt = {},{},{},{},{}
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.Filled    = false
circle.Visible   = false
circle.Radius    = 150   --  varsayılan

----------------------------------------------------------------
--  HELPERS
----------------------------------------------------------------
local function isEnemy(p: Player)
    return p ~= LP and ((not LP.Team) or p.Team ~= LP.Team)
end

local function Head(model: Model)
    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
--  ESP / HEALTH BAR
----------------------------------------------------------------
local function attachESP(char: Model)
    if not isEnemy(Plrs:GetPlayerFromCharacter(char)) then return end

    local box   = Drawing.new("Square"); box.Thickness = 2; box.Filled = false
    local txt   = Drawing.new("Text");   txt.Size = 14; txt.Center = true; txt.Outline = true
    local hl    = Instance.new("Highlight"); hl.Adornee = char; hl.FillTransparency = 0.7

    boxes[char], healthTxt[char], hlights[char] = box, txt, hl

    conns["esp"..char:GetDebugId()] = RS.RenderStepped:Connect(function()
        if not char.Parent then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then box.Visible = false; txt.Visible=false; return end

        local vec, onScreen = Cam:WorldToViewportPoint(hrp.Position)
        box.Visible = state.esp  and onScreen
        txt.Visible = state.esp  and onScreen
        if onScreen then
            local size = 2000 / vec.Z
            box.Size      = Vector2.new(size, size)
            box.Position  = Vector2.new(vec.X - size/2, vec.Y - size/2)
            box.Color     = state.espColor

            local hum = char:FindFirstChildOfClass("Humanoid")
            txt.Text      = hum and math.floor(hum.Health) or "?"
            txt.Position  = Vector2.new(vec.X, vec.Y - size/2 - 15)
            txt.Color     = Color3.new(1,1,1)
        end

        hl.FillColor = state.espColor
        hl.Enabled   = state.wall
    end)
end

local function detachESP(char: Model)
    if boxes[char]      then boxes[char]:Remove();  boxes[char] = nil end
    if healthTxt[char]  then healthTxt[char]:Remove(); healthTxt[char] = nil end
    if hlights[char]    then hlights[char]:Destroy(); hlights[char] = nil end
    if conns["esp"..char:GetDebugId()] then conns["esp"..char:GetDebugId()]:Disconnect(); conns["esp"..char:GetDebugId()] = nil end
    if headOrig[char]   then Head(char).Size = headOrig[char]; headOrig[char] = nil end
end

----------------------------------------------------------------
--  PLAYER TRACKING
----------------------------------------------------------------
local function trackPlayer(pl: Player)
    if pl == LP then return end
    if pl.Character then attachESP(pl.Character) end
    pl.CharacterAdded:Connect(attachESP)
    pl.CharacterRemoving:Connect(detachESP)
end

for _,p in ipairs(Plrs:GetPlayers()) do trackPlayer(p) end
Plrs.PlayerAdded:Connect(trackPlayer)

----------------------------------------------------------------
--  UI WIDGETS
----------------------------------------------------------------
--  ESP
T.ESP:CreateToggle({Name="ESP", CurrentValue=false, Callback=function(v) state.esp = v end})
T.ESP:CreateToggle({Name="WallHack", CurrentValue=false, Callback=function(v) state.wall = v end})
T.ESP:CreateColorPicker({Name="ESP Renk", CurrentValue=state.espColor, Callback=function(col) state.espColor = col end})

--  HITBOX
T.Aim:CreateToggle({
    Name="Büyük Hitbox", CurrentValue=false,
    Callback=function(v)
        state.hitbox = v
        for _,pl in ipairs(Plrs:GetPlayers()) do
            if isEnemy(pl) and pl.Character and Head(pl.Character) then
                local h = Head(pl.Character)
                if v then
                    headOrig[pl.Character] = headOrig[pl.Character] or h.Size
                    h.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                elseif headOrig[pl.Character] then
                    h.Size = headOrig[pl.Character]
                    headOrig[pl.Character] = nil
                end
            end
        end
    end
})

T.Aim:CreateSlider({
    Name="Hitbox Boyutu", Range={1,250}, Increment=1, CurrentValue=state.hitboxSize,
    Callback=function(sz)
        state.hitboxSize = sz
        if state.hitbox then
            for char,_ in pairs(headOrig) do
                if Head(char) then Head(char).Size = Vector3.new(sz,sz,sz) end
            end
        end
    end
})

--  SPEED
T.Player:CreateToggle({Name="Hız Hilesi", CurrentValue=false, Callback=function(v) state.speed = v; Hum.WalkSpeed = v and state.walk or 16 end})
T.Player:CreateSlider({Name="Hız", Range={16,150}, Increment=2, CurrentValue=state.walk, Callback=function(s) state.walk=s; if state.speed then Hum.WalkSpeed=s end end})

--  BUNNY HOP
T.Player:CreateToggle({Name="BunnyHop", CurrentValue=false, Callback=function(v) state.bhop = v end})
T.Player:CreateSlider({Name="Bhop Delay", Range={0.02,0.3}, Increment=0.01, CurrentValue=state.bhopDelay, Callback=function(v) state.bhopDelay = v end})

--  FLY
T.Player:CreateToggle({Name="Fly", CurrentValue=false, Callback=function(v)
    state.fly = v
    if v then
        if conns.fly then return end
        local bv = Instance.new("BodyVelocity", Root)
        local bg = Instance.new("BodyGyro", Root)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque = bv.MaxForce; bg.P = 9e4
        conns.fly = RS.RenderStepped:Connect(function()
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * 60 or Vector3.zero
            bg.CFrame   = Cam.CFrame
        end)
    else
        if conns.fly then conns.fly:Disconnect(); conns.fly=nil end
        for _,inst in ipairs(Root:GetChildren()) do if inst:IsA("BodyVelocity") or inst:IsA("BodyGyro") then inst:Destroy() end end
    end
end})

--  AIMBOT
T.Aim:CreateToggle({Name="Aimbot (LMB)", CurrentValue=false, Callback=function(v) state.aim = v end})
T.Aim:CreateSlider({Name="FOV", Range={50,300}, Increment=10, CurrentValue=circle.Radius, Callback=function(v) circle.Radius = v end})
T.Aim:CreateToggle({Name="FOV Çizgisi", CurrentValue=false, Callback=function(v) state.circle = v; circle.Visible = v end})

----------------------------------------------------------------
--  MAIN LOOP
----------------------------------------------------------------
local hopTimer = 0
conns.main = RS.RenderStepped:Connect(function()
    if state.circle then circle.Position = UIS:GetMouseLocation() end

    --  BunnyHop
    if state.bhop and tick() - hopTimer >= state.bhopDelay and Hum.FloorMaterial ~= Enum.Material.Air then
        Hum.Jump = true
        hopTimer = tick()
    end

    --  Aimbot (sol click)
    if state.aim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mouse = UIS:GetMouseLocation()
        local best, dist = nil, circle.Radius
        for _,pl in ipairs(Plrs:GetPlayers()) do
            if isEnemy(pl) and pl.Character and pl.Character:FindFirstChild("Head") then
                local h = pl.Character.Head
                local sp, vis = Cam:WorldToViewportPoint(h.Position)
                if vis then
                    local d = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
                    if d < dist then best, dist = h, d end
                end
            end
        end
        if best then Cam.CFrame = CFrame.new(Cam.CFrame.Position, best.Position) end
    end
end)
