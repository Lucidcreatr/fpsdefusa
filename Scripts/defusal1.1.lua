--!strict
if game.PlaceId ~= 79393329652220 then return end          -- kendi placeId’inle değiş

-------------------------------------------------- LOAD RAYFIELD
local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if not ok then warn("Rayfield load error: "..tostring(Rayfield)) return end

-------------------------------------------------- WINDOW + TABS
local W = Rayfield:CreateWindow({
    Name="LCX TEAM | Defusal FPS",
    LoadingTitle="LCX TEAM",
    LoadingSubtitle="FPS Pro GUI Aktif Ediliyor...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "LCXFPS",
        FileName = "LCXDefusalGUI"
    },
    Discord = {
        Enabled = true,
        Invite = "yourdiscordinvite", -- değiştir
        RememberJoins = true
    },
    KeySystem = false,
    Theme = Rayfield.Themes["Serenity"],
    DisableBuilder = true
})

local T = {
    ESP = W:CreateTab("🧿 ESP"),
    Aim = W:CreateTab("🎯 Aim"),
    Player = W:CreateTab("🏃 Player"),
    Misc = W:CreateTab("🧪 Misc")
}
for _,tb in pairs(T) do tb:CreateSection("Ana Seçenekler") end

-------------------------------------------------- SERVICES
local Plrs,RS,UIS = game:GetService"Players",game:GetService"RunService",game:GetService"UserInputService"
local Cam=workspace.CurrentCamera; local LP=Plrs.LocalPlayer
local Char=LP.Character or LP.CharacterAdded:Wait(); local Hum=Char:WaitForChild"H"
local Root=Char:WaitForChild"HumanoidRootPart"

-------------------------------------------------- STATE
local state={
    esp=false, wall=false, bhop=false, bhopDelay=0.05,
    speed=false, walk=16, fly=false,
    aim=false, circle=false, hitbox=false, hitboxSize=5,
    espColor=Color3.new(1,0,0)
}
local conns,boxes,hlights,headOrig,healthTxt={}, {}, {}, {}, {}
local circle=Drawing.new("Circle"); circle.Thickness=2; circle.Filled=false; circle.Visible=false

-------------------------------------------------- HELPERS
local function enemy(p) return p~=LP and ((not LP.Team) or p.Team~=LP.Team) end
local function head(c) return c:FindFirstChild"Head" or c:FindFirstChild"HumanoidRootPart" end

-------------------------------------------------- ESP / HEALTH
local function setupChar(c)
    if not enemy(Plrs:GetPlayerFromCharacter(c)) then return end
    local box=Drawing.new("Square"); box.Thickness=2; box.Filled=false; boxes[c]=box
    local ht=Drawing.new("Text"); ht.Size=14; ht.Center=true; ht.Outline=true; healthTxt[c]=ht
    local hl=Instance.new("Highlight"); hl.Adornee=c; hl.FillTransparency=.7; hlights[c]=hl
    conns["esp"..c:GetDebugId()]=RS.RenderStepped:Connect(function()
        if c.Parent==nil then return end
        local hrp=c:FindFirstChild"H"
        if not hrp then box.Visible=false; ht.Visible=false return end
        local v,on=Cam:WorldToViewportPoint(hrp.Position)
        box.Visible=state.esp and on; ht.Visible=state.esp and on
        if on then
            local s=2000/v.Z; box.Size=Vector2.new(s,s); box.Position=Vector2.new(v.X-s/2,v.Y-s/2); box.Color=state.espColor
            local hum=c:FindFirstChildOfClass"Humanoid"; ht.Text=hum and math.floor(hum.Health) or "?"; ht.Position=Vector2.new(v.X,v.Y-s/2-15); ht.Color=Color3.new(1,1,1)
        end
        hl.Enabled=state.wall; hl.FillColor=state.espColor
    end)
end
local function clearChar(c)
    if boxes[c] then boxes[c]:Remove(); boxes[c]=nil end
    if healthTxt[c] then healthTxt[c]:Remove(); healthTxt[c]=nil end
    if hlights[c] then hlights[c]:Destroy(); hlights[c]=nil end
    if conns["esp"..c:GetDebugId()] then conns["esp"..c:GetDebugId()]:Disconnect(); conns["esp"..c:GetDebugId()]=nil end
    if headOrig[c] then head(c).Size=headOrig[c]; headOrig[c]=nil end
end

-------------------------------------------------- PLAYER JOIN / LEAVE
local function hook(p)
    if p==LP then return end
    if p.Character then setupChar(p.Character) end
    p.CharacterAdded:Connect(setupChar); p.CharacterRemoving:Connect(clearChar)
end
for _,p in ipairs(Plrs:GetPlayers()) do hook(p) end
Plrs.PlayerAdded:Connect(hook)

-------------------------------------------------- UI COMPONENTS
T.ESP:CreateToggle({Name="ESP",CurrentValue=false,Callback=function(v) state.esp=v end})
T.ESP:CreateColorPicker({Name="ESP Renk",Color=state.espColor,Callback=function(c) state.espColor=c end})
T.ESP:CreateToggle({Name="WallHack",CurrentValue=false,Callback=function(v) state.wall=v end})

T.Aim:CreateToggle({Name="Büyük Hitbox",CurrentValue=false,Callback=function(v)
    state.hitbox=v
    for _,p in ipairs(Plrs:GetPlayers()) do
        if enemy(p) and p.Character and head(p.Character) then
            local h=head(p.Character)
            if v then headOrig[p.Character]=h.Size; h.Size=Vector3.new(state.hitboxSize,state.hitboxSize,state.hitboxSize)
            elseif headOrig[p.Character] then h.Size=headOrig[p.Character]; headOrig[p.Character]=nil end
        end
    end
end})
T.Aim:CreateSlider({Name="Hitbox Boyutu",Range={1,250},Increment=1,CurrentValue=state.hitboxSize,
    Callback=function(sz) state.hitboxSize=sz
        for c,_ in pairs(headOrig) do if state.hitbox and head(c) then head(c).Size=Vector3.new(sz,sz,sz) end end
end})

T.Player:CreateToggle({Name="Hız Hilesi",CurrentValue=false,Callback=function(v)
    state.speed=v; Hum.WalkSpeed=v and state.walk or 16
end})
T.Player:CreateSlider({Name="Hız",Range={16,150},Increment=2,CurrentValue=state.walk,
    Callback=function(s) state.walk=s; if state.speed then Hum.WalkSpeed=s end end})

T.Player:CreateToggle({Name="Zıplama Hilesi (Bhop)",CurrentValue=false,Callback=function(v) state.bhop=v end})
T.Player:CreateSlider({Name="Bhop Gecikme",Range={0.02,0.3},Increment=0.01,CurrentValue=state.bhopDelay,
    Callback=function(v) state.bhopDelay=v end})

T.Player:CreateToggle({Name="Uçuş",CurrentValue=false,Callback=function(v)
    state.fly=v; Root.Anchored=false
    if v then
        if not conns.fly then
            conns.fly=RS.RenderStepped:Connect(function()
                local dir=Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=Cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=Cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=Cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=Cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.yAxis end
                Root.Velocity=dir*60
            end)
        end
    else if conns.fly then conns.fly:Disconnect(); conns.fly=nil; Root.Velocity=Vector3.zero end
end})

T.Aim:CreateToggle({Name="Aimbot (LMB)",CurrentValue=false,Callback=function(v) state.aim=v end})
T.Aim:CreateSlider({Name="Aimbot Görüş Açısı (FOV)",Range={50,300},Increment=10,CurrentValue=150,Callback=function(v) circle.Radius=v end})
T.Aim:CreateToggle({Name="FOV Çizgisi Göster",CurrentValue=false,Callback=function(v) state.circle=v; circle.Visible=v end})

-------------------------------------------------- MAIN LOOP
local lastHop=0
conns.main=RS.RenderStepped:Connect(function()
    if state.circle then circle.Position=UIS:GetMouseLocation() end

    if state.bhop and tick()-lastHop>=state.bhopDelay and Hum.FloorMaterial~=Enum.Material.Air then
        Hum.Jump=true; lastHop=tick() end

    if state.aim and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local mouse=UIS:GetMouseLocation(); local best,dist=nil,1e3
        for _,p in ipairs(Plrs:GetPlayers()) do
            if enemy(p) and p.Character and p.Character:FindFirstChild("Head") then
                local h=p.Character.Head
                local sp,vis=Cam:WorldToViewportPoint(h.Position)
                if vis then
                    local d=(Vector2.new(sp.X,sp.Y)-mouse).Magnitude
                    if d<dist and d<circle.Radius then best,dist=h,d end
                end
            end
        end
        if best then Cam.CFrame=CFrame.new(Cam.CFrame.Position,best.Position) end
    end
end)
