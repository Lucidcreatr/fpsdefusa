--!strict
if game.PlaceId ~= 79393329652220 then return end

----------------------------------------------------------------
-- RAYFIELD
----------------------------------------------------------------
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok then
    warn("Rayfield load error: " .. tostring(Rayfield))
    return
end

----------------------------------------------------------------
-- WINDOW & TABS
----------------------------------------------------------------
local W = Rayfield:CreateWindow({
    Name               = "LCX TEAM | Defusal FPS",
    LoadingTitle       = "LCX TEAM",
    LoadingSubtitle    = "FPS Pro GUI Aktif Ediliyor...",
    Theme              = Rayfield.Themes.Serenity,
    DisableBuildWarnings = true
})

local T = {
    ESP    = W:CreateTab("🧿 ESP"),
    Aim    = W:CreateTab("🎯 Aim"),
    Player = W:CreateTab("🏃 Player"),
    Misc   = W:CreateTab("🧪 Misc")
}

for _, tab in pairs(T) do
    tab:CreateSection("Ana Seçenekler")
end

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Plrs, RS, UIS = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService")
local Cam = workspace.CurrentCamera
local LP  = Plrs.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum  = Char:WaitForChild("Humanoid")
local Root = Char:WaitForChild("HumanoidRootPart")

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local state = {
    -- görsel
    esp=false, wall=false, espColor=Color3.fromRGB(255,0,0),

    -- oyuncu
    bhop=false, bhopDelay=0.05,
    speed=false, walk=16,
    fly=false,   flySpeed=60,

    -- aim
    aim=false,   aimLock=nil,   -- aimLock: kilitli parça
    aimPart="Head",             -- seçilebilir hedef
    circle=false,               -- FOV çemberi
    hitbox=false, hitboxSize=5
}

----------------------------------------------------------------
-- CONTAINERS
----------------------------------------------------------------
local conns      : {[string]: RBXScriptConnection} = {}
local boxes      : {[Model] : Drawing}             = {}
local healthTxt  : {[Model] : Drawing}             = {}
local hlights    : {[Model] : Highlight}           = {}
local headOrig   : {[Model] : Vector3}             = {}

----------------------------------------------------------------
-- DRAWING OBJ (FOV)
----------------------------------------------------------------
local circle = Drawing.new("Circle")
circle.Thickness = 2
circle.Filled    = false
circle.Visible   = false
circle.Radius    = 150

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function isEnemy(p: Player): boolean
    return p ~= LP and ((not LP.Team) or p.Team ~= LP.Team)
end

local function Head(model: Model): BasePart?
    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
end

----------------------------------------------------------------
-- ESP / HEALTHBAR
----------------------------------------------------------------
local function attachESP(char: Model)
    if not isEnemy(Plrs:GetPlayerFromCharacter(char)) then return end

    local box = Drawing.new("Square"); box.Thickness = 2; box.Filled = false
    local txt = Drawing.new("Text")  ; txt.Size = 14; txt.Center = true; txt.Outline = true
    local hl  = Instance.new("Highlight"); hl.Adornee = char; hl.FillTransparency = 0.7

    boxes[char], healthTxt[char], hlights[char] = box, txt, hl

    conns["esp_" .. char:GetDebugId()] = RS.RenderStepped:Connect(function()
        if not char.Parent then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then box.Visible = false; txt.Visible = false; return end

        local vec, onScr = Cam:WorldToViewportPoint(hrp.Position)
        box.Visible, txt.Visible = state.esp and onScr, state.esp and onScr
        if onScr then
            local size = 2000 / vec.Z
            box.Size = Vector2.new(size, size)
            box.Position = Vector2.new(vec.X - size/2, vec.Y - size/2)
            box.Color = state.espColor

            local hum = char:FindFirstChildOfClass("Humanoid")
            txt.Text      = hum and math.floor(hum.Health) or "?"
            txt.Position  = Vector2.new(vec.X, vec.Y - size/2 - 14)
            txt.Color     = Color3.new(1,1,1)
        end
        hl.FillColor, hl.Enabled = state.espColor, state.wall
    end)
end

local function detachESP(char: Model)
    if boxes[char] then boxes[char]:Remove(); boxes[char]=nil end
    if healthTxt[char] then healthTxt[char]:Remove(); healthTxt[char]=nil end
    if hlights[char] then hlights[char]:Destroy(); hlights[char]=nil end
    local id = "esp_"..char:GetDebugId()
    if conns[id] then conns[id]:Disconnect(); conns[id]=nil end
    if headOrig[char] then Head(char).Size = headOrig[char]; headOrig[char]=nil end
end

----------------------------------------------------------------
-- PLAYER TRACKING
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
-- GUI WIDGETS
----------------------------------------------------------------
-- ► ESP
T.ESP:CreateToggle({Name="ESP",        CurrentValue=false, Callback=function(v) state.esp  = v end})
T.ESP:CreateToggle({Name="WallHack",   CurrentValue=false, Callback=function(v) state.wall = v end})
T.ESP:CreateColorPicker({
    Name="ESP Renk", CurrentValue=state.espColor,
    Callback=function(col) state.espColor = col end
})

-- ► Aimbot hedef parça seçimi
T.Aim:CreateDropdown({
    Name="Aimbot Hedef", Options={"Head","HumanoidRootPart"},
    CurrentOption="Head", Callback=function(opt) state.aimPart = opt end
})

-- ► Hitbox
T.Aim:CreateToggle({
    Name="Büyük Hitbox", CurrentValue=false,
    Callback=function(v)
        state.hitbox = v
        for _,pl in ipairs(Plrs:GetPlayers()) do
            if isEnemy(pl) and pl.Character then
                local h = Head(pl.Character)
                if h then
                    if v then
                        headOrig[pl.Character] = headOrig[pl.Character] or h.Size
                        h.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                    elseif headOrig[pl.Character] then
                        h.Size = headOrig[pl.Character]; headOrig[pl.Character]=nil
                    end
                end
            end
        end
    end
})
T.Aim:CreateSlider({
    Name="Hitbox Boyutu", Range={1,250}, Increment=1,
    CurrentValue=state.hitboxSize,
    Callback=function(sz)
        state.hitboxSize = sz
        if state.hitbox then
            for char,_ in pairs(headOrig) do
                local h = Head(char)
                if h then h.Size = Vector3.new(sz,sz,sz) end
            end
        end
    end
})

-- ► Speed
T.Player:CreateToggle({
    Name="Hız Hilesi", CurrentValue=false,
    Callback=function(v) state.speed=v; Hum.WalkSpeed = v and state.walk or 16 end
})
T.Player:CreateSlider({
    Name="Hız", Range={16,150}, Increment=2,
    CurrentValue=state.walk,
    Callback=function(s) state.walk=s; if state.speed then Hum.WalkSpeed=s end end
})

-- ► BunnyHop
T.Player:CreateToggle({Name="BunnyHop", CurrentValue=false, Callback=function(v) state.bhop=v end})
T.Player:CreateSlider({
    Name="Bhop Delay", Range={0.02,0.3}, Increment=0.01,
    CurrentValue=state.bhopDelay, Callback=function(v) state.bhopDelay=v end
})

-- ► Fly + hız
T.Player:CreateToggle({
    Name="Fly", CurrentValue=false,
    Callback=function(v)
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
                bv.Velocity = dir.Magnitude>0 and dir.Unit*state.flySpeed or Vector3.zero
                bg.CFrame   = Cam.CFrame
            end)
        else
            if conns.fly then conns.fly:Disconnect(); conns.fly=nil end
            for _,i in ipairs(Root:GetChildren()) do if i:IsA("BodyVelocity") or i:IsA("BodyGyro") then i:Destroy() end end
        end
    end
})
T.Player:CreateSlider({
    Name="Fly Hızı", Range={10,150}, Increment=5,
    CurrentValue=state.flySpeed, Callback=function(v) state.flySpeed=v end
})

-- ► Aimbot
T.Aim:CreateToggle({Name="Aimbot (LMB)", CurrentValue=false, Callback=function(v) state.aim=v; if not v then state.aimLock=nil end end})
T.Aim:CreateSlider({Name="FOV", Range={50,300}, Increment=10, CurrentValue=circle.Radius, Callback=function(v) circle.Radius=v end})
T.Aim:CreateToggle({Name="FOV Çizgisi", CurrentValue=false, Callback=function(v) state.circle=v; circle.Visible=v end})

----------------------------------------------------------------
-- MAIN LOOP
----------------------------------------------------------------
local hopTimer = 0
conns.main = RS.RenderStepped:Connect(function()
    -- FOV çemberi pozisyonu
    if state.circle then circle.Position = UIS:GetMouseLocation() end

    -- BunnyHop
    if state.bhop and tick()-hopTimer >= state.bhopDelay and Hum.FloorMaterial ~= Enum.Material.Air then
        Hum.Jump=true; hopTimer=tick()
    end

    -- Aimbot (sol tıklama)
    if state.aim then
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            if not state.aimLock or not state.aimLock.Parent then
                -- hedef kilitle
                local mouse = UIS:GetMouseLocation()
                local best,dist=nil,circle.Radius
                for _,pl in ipairs(Plrs:GetPlayers()) do
                    if isEnemy(pl) and pl.Character then
                        local part = pl.Character:FindFirstChild(state.aimPart)
                        if part then
                            local sp,vis = Cam:WorldToViewportPoint(part.Position)
                            if vis then
                                local d = (Vector2.new(sp.X,sp.Y) - mouse).Magnitude
                                if d < dist then best,dist = part,d end
                            end
                        end
                    end
                end
                state.aimLock = best
            end
            if state.aimLock then
                Cam.CFrame = CFrame.new(Cam.CFrame.Position, state.aimLock.Position)
            end
        else
            -- sol tuş bırakıldı => kilit sıfırlansın
            state.aimLock = nil
        end
    end
end)

----------------------------------------------------------------
-- CHAR REFRESH (ölünce / respawn)
----------------------------------------------------------------
LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum  = c:WaitForChild("Humanoid")
    Root = c:WaitForChild("HumanoidRootPart")
end)
