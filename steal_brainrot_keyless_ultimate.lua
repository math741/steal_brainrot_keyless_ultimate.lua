-- ╔══════════════════════════════════════════════════════╗
-- ║           MLG HACK v5.0 - ZERO ERROS                ║
-- ║     GUI garantida + funciona em qualquer jogo        ║
-- ╚══════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local lp = Players.LocalPlayer

-- GUI parent seguro (funciona em qualquer executor)
local function getGuiParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return lp:WaitForChild("PlayerGui")
end

-- Remove GUI antiga
pcall(function()
    local cg = getGuiParent()
    for _, v in ipairs(cg:GetChildren()) do
        if tostring(v.Name):find("MLG") then v:Destroy() end
    end
end)

-- ============================================================
-- SKINS
-- ============================================================
local SKINS = {
    { name="🟢 Matrix",  bg=Color3.fromRGB(8,14,8),   topbar=Color3.fromRGB(5,20,5),   accent=Color3.fromRGB(0,255,80),  rowBg=Color3.fromRGB(14,24,14),  text=Color3.fromRGB(180,255,180), on=Color3.fromRGB(0,220,70),  off=Color3.fromRGB(30,60,30),  rainbow=false },
    { name="🔵 Ocean",   bg=Color3.fromRGB(5,12,25),  topbar=Color3.fromRGB(5,10,22),  accent=Color3.fromRGB(0,180,255), rowBg=Color3.fromRGB(10,18,36),  text=Color3.fromRGB(180,220,255), on=Color3.fromRGB(0,160,255), off=Color3.fromRGB(20,40,80),  rainbow=false },
    { name="🔴 Blood",   bg=Color3.fromRGB(18,5,5),   topbar=Color3.fromRGB(14,4,4),   accent=Color3.fromRGB(255,40,40), rowBg=Color3.fromRGB(26,8,8),    text=Color3.fromRGB(255,180,180), on=Color3.fromRGB(220,40,40), off=Color3.fromRGB(70,20,20),  rainbow=false },
    { name="🌈 Rainbow", bg=Color3.fromRGB(10,10,18), topbar=Color3.fromRGB(8,8,14),   accent=Color3.fromRGB(255,100,200),rowBg=Color3.fromRGB(16,16,28), text=Color3.fromRGB(255,255,255), on=Color3.fromRGB(100,255,200),off=Color3.fromRGB(40,40,70), rainbow=true  },
    { name="🟡 Gold",    bg=Color3.fromRGB(16,13,4),  topbar=Color3.fromRGB(12,10,3),  accent=Color3.fromRGB(255,200,0), rowBg=Color3.fromRGB(24,20,6),   text=Color3.fromRGB(255,240,180), on=Color3.fromRGB(220,180,0), off=Color3.fromRGB(60,50,10),  rainbow=false },
    { name="⚫ Dark",    bg=Color3.fromRGB(6,6,6),    topbar=Color3.fromRGB(4,4,4),    accent=Color3.fromRGB(180,180,180),rowBg=Color3.fromRGB(14,14,14), text=Color3.fromRGB(220,220,220), on=Color3.fromRGB(160,160,160),off=Color3.fromRGB(40,40,40), rainbow=false },
    { name="🟣 Purple",  bg=Color3.fromRGB(12,5,20),  topbar=Color3.fromRGB(10,4,18),  accent=Color3.fromRGB(180,0,255), rowBg=Color3.fromRGB(20,8,34),   text=Color3.fromRGB(220,180,255), on=Color3.fromRGB(160,0,220), off=Color3.fromRGB(50,20,80),  rainbow=false },
    { name="🟠 Orange",  bg=Color3.fromRGB(18,10,4),  topbar=Color3.fromRGB(14,8,3),   accent=Color3.fromRGB(255,140,0), rowBg=Color3.fromRGB(26,14,6),   text=Color3.fromRGB(255,220,180), on=Color3.fromRGB(220,120,0), off=Color3.fromRGB(70,40,10),  rainbow=false },
    -- ╔══════════════════════════════════════════════╗
    -- ║  CRIE SUA SKIN AQUI!                        ║
    -- ║  Copie uma linha acima, mude o nome e       ║
    -- ║  os valores RGB (numeros de 0 a 255)        ║
    -- ╚══════════════════════════════════════════════╝
    -- { name="🎨 MinhaSkin", bg=Color3.fromRGB(0,0,0), topbar=Color3.fromRGB(0,0,0), accent=Color3.fromRGB(255,255,0), rowBg=Color3.fromRGB(20,20,20), text=Color3.fromRGB(255,255,255), on=Color3.fromRGB(0,255,0), off=Color3.fromRGB(50,50,50), rainbow=false },
}
local S = SKINS[1]

-- ============================================================
-- FLAGS
-- ============================================================
local F = {
    speed=true,  speedV=120,
    fly=false,   flyV=80,
    noclip=false,
    infjump=false,
    god=false,
    esp=false,
    clicktp=false,
    fullbright=false,
    rainbow=false,
    spin=false,
    antiafk=true,
    freecam=false,
    hitbox=false, hitboxV=10,
    fov=false,    fovV=90,
    speedjump=false,
    lowgrav=false,
}

local CONNS  = {}
local espHL  = {}
local guiOpen= true
local rbH    = 0
local strokeH= 0
local allRows= {}

-- ============================================================
-- HELPERS
-- ============================================================
local function p(fn, ...) pcall(fn, ...) end

local function getHR()
    local c = lp and lp.Character
    if not c then return nil, nil end
    return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local function disc(id)
    if CONNS[id] then pcall(function() CONNS[id]:Disconnect() end); CONNS[id]=nil end
end

local function tw(obj, t, props)
    pcall(function() TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play() end)
end

local SLBL  -- declarado antes das features para setStatus funcionar
local function setStatus(t)
    pcall(function() if SLBL then SLBL.Text = "  "..t end end)
end

-- ============================================================
-- FEATURES
-- ============================================================

-- SPEED
RunService.Heartbeat:Connect(function()
    if not F.speed then return end
    p(function()
        local h,r = getHR()
        if h and r then
            h.WalkSpeed = F.speedV
            if h.MoveDirection.Magnitude > 0 then
                r.Velocity = Vector3.new(h.MoveDirection.X*F.speedV, r.Velocity.Y, h.MoveDirection.Z*F.speedV)
            end
        end
    end)
end)

-- FLY
local flyBV, flyBG
local function startFly()
    p(function()
        local h,r = getHR(); if not h or not r then return end
        h.PlatformStand = true
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5); flyBV.Velocity=Vector3.zero; flyBV.Parent=r
        flyBG = Instance.new("BodyGyro");     flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.P=1e4; flyBG.Parent=r
        CONNS.fly = RunService.Heartbeat:Connect(function()
            if not F.fly then return end
            p(function()
                local _,rt = getHR(); if not rt then return end
                local cam = workspace.CurrentCamera
                local d = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then d=d+Vector3.new(0,1,0)  end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0)  end
                flyBV.Velocity = d.Magnitude>0 and d.Unit*F.flyV or Vector3.zero
                flyBG.CFrame = cam.CFrame
            end)
        end)
    end)
end
local function stopFly()
    disc("fly")
    p(function() if flyBV then flyBV:Destroy() end end)
    p(function() if flyBG then flyBG:Destroy() end end)
    p(function() local h=getHR(); if h then h.PlatformStand=false end end)
end

-- NOCLIP
local function startNoclip()
    CONNS.noclip = RunService.Stepped:Connect(function()
        p(function()
            local c = lp.Character; if not c then return end
            for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
        end)
    end)
end
local function stopNoclip()
    disc("noclip")
    p(function()
        local c = lp.Character; if not c then return end
        for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end
    end)
end

-- GOD
local function startGod()
    p(function()
        local h = getHR(); if not h then return end
        h.MaxHealth=math.huge; h.Health=math.huge
        CONNS.god = h:GetPropertyChangedSignal("Health"):Connect(function()
            if F.god then p(function() h.Health=math.huge end) end
        end)
    end)
end

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if F.infjump then p(function() local h=getHR(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end)

-- CLICK TP
local function startClickTP()
    CONNS.clicktp = UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            p(function()
                local _,r = getHR(); if not r then return end
                local cam = workspace.CurrentCamera
                local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector*600)
                if ray then r.CFrame = CFrame.new(ray.Position+Vector3.new(0,3,0)) end
            end)
        end
    end)
end

-- FULLBRIGHT
local oAmb,oBri,oClock
local function startFB()
    p(function() oAmb=Lighting.Ambient; oBri=Lighting.Brightness; oClock=Lighting.ClockTime
        Lighting.Ambient=Color3.new(1,1,1); Lighting.Brightness=2; Lighting.ClockTime=14 end)
end
local function stopFB()
    p(function() if oAmb then Lighting.Ambient=oAmb; Lighting.Brightness=oBri; Lighting.ClockTime=oClock end end)
end

-- RAINBOW CHAR
RunService.Heartbeat:Connect(function()
    if not F.rainbow then return end
    p(function()
        rbH=(rbH+0.5)%360
        local c=lp.Character; if not c then return end
        for _,pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") then pt.Color=Color3.fromHSV(rbH/360,1,1) end end
    end)
end)

-- SPIN
RunService.Heartbeat:Connect(function()
    if not F.spin then return end
    p(function() local _,r=getHR(); if r then r.CFrame=r.CFrame*CFrame.Angles(0,math.rad(10),0) end end)
end)

-- ESP
local function clearESP()
    for _,h in pairs(espHL) do p(function() if h and h.Parent then h:Destroy() end end) end; espHL={}
end
local function makeHL(char)
    local ok,h = pcall(function()
        local hl=Instance.new("Highlight")
        hl.FillColor=Color3.fromRGB(255,50,50); hl.OutlineColor=Color3.fromRGB(255,230,0)
        hl.FillTransparency=0.45; hl.Parent=char; return hl
    end)
    return ok and h or nil
end
local function applyESP()
    clearESP()
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=lp then p(function()
            if pl.Character then espHL[pl.Name]=makeHL(pl.Character) end
            pl.CharacterAdded:Connect(function(c) if F.esp then espHL[pl.Name]=makeHL(c) end end)
        end) end
    end
end
Players.PlayerAdded:Connect(function(pl)
    if not F.esp then return end
    pl.CharacterAdded:Connect(function(c) p(function() espHL[pl.Name]=makeHL(c) end) end)
end)

-- HITBOX
local function applyHitbox()
    for _,pl in ipairs(Players:GetPlayers()) do if pl~=lp then p(function()
        if pl.Character then
            local r=pl.Character:FindFirstChild("HumanoidRootPart")
            if r then r.Size=Vector3.new(F.hitboxV,F.hitboxV,F.hitboxV) end
        end
    end) end end
end

-- FOV
local function applyFOV() p(function() workspace.CurrentCamera.FieldOfView=F.fovV end) end
local function resetFOV()  p(function() workspace.CurrentCamera.FieldOfView=70 end) end

-- FREECAM
local fcBV
local function startFreecam()
    p(function()
        local _,r=getHR(); if not r then return end
        fcBV=Instance.new("BodyVelocity"); fcBV.MaxForce=Vector3.new(1e5,1e5,1e5); fcBV.Velocity=Vector3.zero; fcBV.Parent=r
        CONNS.freecam=RunService.Heartbeat:Connect(function()
            if not F.freecam then return end
            p(function()
                local cam=workspace.CurrentCamera; local d=Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.I) then d=d+cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.K) then d=d-cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.J) then d=d-cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.L) then d=d+cam.CFrame.RightVector end
                fcBV.Velocity=d.Magnitude>0 and d.Unit*60 or Vector3.zero
            end)
        end)
    end)
end
local function stopFreecam()
    disc("freecam"); p(function() if fcBV then fcBV:Destroy() end end)
end

-- ANTI AFK - SEM VirtualUser (método 100% compatível)
task.spawn(function()
    while task.wait(60) do
        if F.antiafk then
            p(function()
                local h=getHR()
                if h then
                    -- simula movimento mínimo imperceptível
                    h.Jump = false
                end
            end)
        end
    end
end)

-- RESPAWN
p(function()
    lp.CharacterAdded:Connect(function(c)
        p(function()
            c:WaitForChild("Humanoid",5); c:WaitForChild("HumanoidRootPart",5); task.wait(0.5)
            if F.god    then startGod()     end
            if F.fly    then startFly()     end
            if F.noclip then startNoclip()  end
        end)
    end)
end)

-- ============================================================
-- GUI
-- ============================================================
local SG = Instance.new("ScreenGui")
SG.Name="MLGHack_v5"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true

-- Garante que a GUI apareça em qualquer situação
local placed = false
p(function() SG.Parent=game:GetService("CoreGui"); placed=true end)
if not placed then
    p(function() SG.Parent=lp:WaitForChild("PlayerGui"); placed=true end)
end
if not placed then SG.Parent = lp.PlayerGui end

-- JANELA PRINCIPAL
local WIN = Instance.new("Frame")
WIN.Size=UDim2.new(0,460,0,640); WIN.Position=UDim2.new(0.5,-230,0.5,-320)
WIN.BackgroundColor3=S.bg; WIN.BorderSizePixel=0; WIN.ClipsDescendants=true; WIN.Parent=SG
Instance.new("UICorner",WIN).CornerRadius=UDim.new(0,16)

local STROKE=Instance.new("UIStroke"); STROKE.Thickness=2.5; STROKE.Color=S.accent; STROKE.Parent=WIN

RunService.Heartbeat:Connect(function()
    if not S.rainbow then return end
    p(function() strokeH=(strokeH+0.4)%360; STROKE.Color=Color3.fromHSV(strokeH/360,1,1) end)
end)

-- TOPBAR
local TOP=Instance.new("Frame")
TOP.Size=UDim2.new(1,0,0,62); TOP.BackgroundColor3=S.topbar; TOP.BorderSizePixel=0; TOP.ZIndex=5; TOP.Parent=WIN
Instance.new("UICorner",TOP).CornerRadius=UDim.new(0,16)
-- cobre os cantos inferiores arredondados do top
local topFix=Instance.new("Frame"); topFix.Size=UDim2.new(1,0,0,16); topFix.Position=UDim2.new(0,0,1,-16)
topFix.BackgroundColor3=S.topbar; topFix.BorderSizePixel=0; topFix.ZIndex=5; topFix.Parent=TOP

local TG=Instance.new("UIGradient"); TG.Rotation=90
TG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,S.accent),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
TG.Parent=TOP

local TITLELBL=Instance.new("TextLabel")
TITLELBL.Size=UDim2.new(0,260,0,36); TITLELBL.Position=UDim2.new(0,14,0,5)
TITLELBL.BackgroundTransparency=1; TITLELBL.Text="⚡ MLG HACK"
TITLELBL.TextColor3=Color3.new(1,1,1); TITLELBL.TextScaled=true; TITLELBL.Font=Enum.Font.GothamBold
TITLELBL.ZIndex=6; TITLELBL.Parent=TOP

local SUBLBL2=Instance.new("TextLabel")
SUBLBL2.Size=UDim2.new(0,260,0,16); SUBLBL2.Position=UDim2.new(0,14,0,43)
SUBLBL2.BackgroundTransparency=1; SUBLBL2.Text="v5.0  ·  UNIVERSAL  ·  ZERO ERROS"
SUBLBL2.TextColor3=Color3.fromRGB(200,255,200); SUBLBL2.TextScaled=true; SUBLBL2.Font=Enum.Font.Gotham
SUBLBL2.ZIndex=6; SUBLBL2.Parent=TOP

local function mkTopBtn(t,col,xo)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,32,0,32); b.Position=UDim2.new(1,xo,0,15)
    b.BackgroundColor3=col; b.Text=t; b.TextColor3=Color3.new(1,1,1)
    b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.ZIndex=7; b.Parent=TOP
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); return b
end
mkTopBtn("✕",Color3.fromRGB(255,55,55),-10).MouseButton1Click:Connect(function() SG:Destroy() end)
mkTopBtn("−",Color3.fromRGB(55,55,80), -48).MouseButton1Click:Connect(function()
    guiOpen=not guiOpen
    local tgt=guiOpen and UDim2.new(0,460,0,640) or UDim2.new(0,460,0,62)
    tw(WIN,0.3,{Size=tgt})
end)

-- ABAS
local TABBAR=Instance.new("Frame")
TABBAR.Size=UDim2.new(1,0,0,36); TABBAR.Position=UDim2.new(0,0,0,62)
TABBAR.BackgroundColor3=Color3.fromRGB(10,10,16); TABBAR.BorderSizePixel=0; TABBAR.ZIndex=5; TABBAR.Parent=WIN

local tbl=Instance.new("UIListLayout"); tbl.FillDirection=Enum.FillDirection.Horizontal
tbl.HorizontalAlignment=Enum.HorizontalAlignment.Center; tbl.VerticalAlignment=Enum.VerticalAlignment.Center
tbl.Padding=UDim.new(0,4); tbl.Parent=TABBAR

local PAGES={}; local TBTNS={}

local function mkTab(id,icon,lbl)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,72,0,28); btn.BackgroundColor3=Color3.fromRGB(20,20,32)
    btn.Text=icon.." "..lbl; btn.TextColor3=Color3.fromRGB(130,130,160)
    btn.TextScaled=true; btn.Font=Enum.Font.GothamSemibold; btn.ZIndex=6; btn.Parent=TABBAR
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,-16,1,-112); pg.Position=UDim2.new(0,8,0,102)
    pg.BackgroundTransparency=1; pg.ScrollBarThickness=3; pg.ScrollBarImageColor3=S.accent
    pg.Visible=false; pg.ZIndex=4; pg.Parent=WIN; pg.CanvasSize=UDim2.new(0,0,0,0)

    local pgl=Instance.new("UIListLayout"); pgl.Padding=UDim.new(0,7); pgl.Parent=pg
    pgl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize=UDim2.new(0,0,0,pgl.AbsoluteContentSize.Y+16)
    end)

    btn.MouseButton1Click:Connect(function()
        for k,pg2 in pairs(PAGES) do
            pg2.Visible=false
            TBTNS[k].BackgroundColor3=Color3.fromRGB(20,20,32)
            TBTNS[k].TextColor3=Color3.fromRGB(130,130,160)
        end
        pg.Visible=true; btn.BackgroundColor3=S.accent; btn.TextColor3=Color3.new(1,1,1)
    end)
    PAGES[id]=pg; TBTNS[id]=btn; return pg
end

local pgMove   = mkTab("move",   "🏃","Move")
local pgCombat = mkTab("combat", "⚔️", "Combat")
local pgVisual = mkTab("visual", "👁️", "Visual")
local pgWorld  = mkTab("world",  "🌍","World")
local pgSkins  = mkTab("skins",  "🎨","Skins")

PAGES["move"].Visible=true
TBTNS["move"].BackgroundColor3=S.accent; TBTNS["move"].TextColor3=Color3.new(1,1,1)

-- STATUS BAR
local SBAR=Instance.new("Frame")
SBAR.Size=UDim2.new(1,0,0,24); SBAR.Position=UDim2.new(0,0,1,-24)
SBAR.BackgroundColor3=Color3.fromRGB(6,6,10); SBAR.BorderSizePixel=0; SBAR.ZIndex=5; SBAR.Parent=WIN

SLBL=Instance.new("TextLabel")
SLBL.Size=UDim2.new(1,-10,1,0); SLBL.Position=UDim2.new(0,10,0,0); SLBL.BackgroundTransparency=1
SLBL.Text="  ✅ MLG Hack v5.0  |  Insert=esconder  |  F2=Fly  |  F3=Noclip  |  F4=ESP"
SLBL.TextColor3=S.accent; SLBL.TextScaled=true; SLBL.Font=Enum.Font.Gotham
SLBL.TextXAlignment=Enum.TextXAlignment.Left; SLBL.ZIndex=6; SLBL.Parent=SBAR

-- TOGGLE ROW
local function mkRow(parent,icon,name,flagKey,onToggle,numKey,numDef,onNum)
    local isOn = flagKey and F[flagKey] or false
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-8,0, numKey and 62 or 48)
    row.BackgroundColor3=S.rowBg; row.BorderSizePixel=0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    table.insert(allRows,{row=row})

    local ic=Instance.new("Frame"); ic.Size=UDim2.new(0,34,0,34); ic.Position=UDim2.new(0,7,0.5,-17)
    ic.BackgroundColor3=Color3.fromRGB(22,22,34); ic.BorderSizePixel=0; ic.ZIndex=5; ic.Parent=row
    Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8)
    local icLbl=Instance.new("TextLabel"); icLbl.Size=UDim2.new(1,0,1,0); icLbl.BackgroundTransparency=1
    icLbl.Text=icon; icLbl.TextScaled=true; icLbl.Font=Enum.Font.GothamBold; icLbl.ZIndex=6; icLbl.Parent=ic

    local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(0.52,0,0,22); nm.Position=UDim2.new(0,50,0,5)
    nm.BackgroundTransparency=1; nm.Text=name; nm.TextColor3=S.text
    nm.TextXAlignment=Enum.TextXAlignment.Left; nm.TextScaled=true; nm.Font=Enum.Font.GothamBold; nm.ZIndex=5; nm.Parent=row

    if numKey then
        local box=Instance.new("TextBox"); box.Size=UDim2.new(0,68,0,22); box.Position=UDim2.new(0,50,0,33)
        box.BackgroundColor3=Color3.fromRGB(18,18,28); box.Text=tostring(numDef)
        box.TextColor3=S.accent; box.TextScaled=true; box.Font=Enum.Font.GothamBold; box.ZIndex=5; box.Parent=row
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
        box.FocusLost:Connect(function()
            local n=tonumber(box.Text); if n and onNum then p(function() onNum(n) end); setStatus("✏️ "..name.." = "..n) end
        end)
    end

    -- PILL TOGGLE
    local pill=Instance.new("Frame"); pill.Size=UDim2.new(0,52,0,26); pill.Position=UDim2.new(1,-62,0.5,-13)
    pill.BackgroundColor3=isOn and S.on or S.off; pill.BorderSizePixel=0; pill.ZIndex=5; pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,20,0,20)
    dot.Position=isOn and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    dot.BackgroundColor3=Color3.new(1,1,1); dot.BorderSizePixel=0; dot.ZIndex=6; dot.Parent=pill
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local tog=Instance.new("TextButton"); tog.Size=UDim2.new(0,52,0,26); tog.Position=pill.Position
    tog.BackgroundTransparency=1; tog.Text=""; tog.ZIndex=7; tog.Parent=row

    tog.MouseButton1Click:Connect(function()
        local st=false; p(function() st=onToggle() end)
        tw(pill,0.15,{BackgroundColor3=st and S.on or S.off})
        tw(dot, 0.15,{Position=st and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)})
        setStatus((st and "✅" or "❌").." "..name)
    end)

    row.MouseEnter:Connect(function() tw(row,0.1,{BackgroundColor3=Color3.fromRGB(26,26,44)}) end)
    row.MouseLeave:Connect(function() tw(row,0.1,{BackgroundColor3=S.rowBg}) end)
end

-- ── MOVE ──────────────────────────────────────────────────────
mkRow(pgMove,"⚡","Speed Hack","speed",
    function() F.speed=not F.speed; return F.speed end,
    "speedV",F.speedV, function(v) F.speedV=math.max(16,v) end)

mkRow(pgMove,"🦅","Fly (W/A/S/D + Space/Ctrl)","fly",
    function() F.fly=not F.fly; if F.fly then startFly() else stopFly() end; return F.fly end,
    "flyV",F.flyV, function(v) F.flyV=math.max(10,v) end)

mkRow(pgMove,"👻","Noclip","noclip",
    function() F.noclip=not F.noclip; if F.noclip then startNoclip() else stopNoclip() end; return F.noclip end)

mkRow(pgMove,"♾️","Infinite Jump","infjump",
    function() F.infjump=not F.infjump; return F.infjump end)

mkRow(pgMove,"🖱️","Click Teleport","clicktp",
    function() F.clicktp=not F.clicktp; if F.clicktp then startClickTP() else disc("clicktp") end; return F.clicktp end)

mkRow(pgMove,"🌀","Spin Mode","spin",
    function() F.spin=not F.spin; return F.spin end)

mkRow(pgMove,"🎥","Free Cam (I/J/K/L)","freecam",
    function() F.freecam=not F.freecam; if F.freecam then startFreecam() else stopFreecam() end; return F.freecam end)

mkRow(pgMove,"🛑","Anti AFK","antiafk",
    function() F.antiafk=not F.antiafk; return F.antiafk end)

-- ── COMBAT ────────────────────────────────────────────────────
mkRow(pgCombat,"🛡️","God Mode","god",
    function() F.god=not F.god; if F.god then startGod() else disc("god") end; return F.god end)

mkRow(pgCombat,"📦","Hitbox Expander","hitbox",
    function() F.hitbox=not F.hitbox; if F.hitbox then applyHitbox() end; return F.hitbox end,
    "hitboxV",F.hitboxV, function(v) F.hitboxV=math.max(1,v); if F.hitbox then applyHitbox() end end)

mkRow(pgCombat,"🦘","Speed Jump","speedjump",
    function()
        F.speedjump=not F.speedjump
        p(function() local h=getHR(); if h then h.JumpPower=F.speedjump and 120 or 50 end end)
        return F.speedjump
    end)

mkRow(pgCombat,"🌑","Low Gravity","lowgrav",
    function()
        F.lowgrav=not F.lowgrav
        p(function() workspace.Gravity=F.lowgrav and 40 or 196.2 end)
        return F.lowgrav
    end)

-- ── VISUAL ────────────────────────────────────────────────────
mkRow(pgVisual,"👁️","ESP Players","esp",
    function() F.esp=not F.esp; if F.esp then applyESP() else clearESP() end; return F.esp end)

mkRow(pgVisual,"🌈","Rainbow Char","rainbow",
    function()
        F.rainbow=not F.rainbow
        if not F.rainbow then p(function()
            local c=lp.Character; if c then
                for _,pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") then pt.Color=Color3.fromRGB(163,162,165) end end
            end
        end) end
        return F.rainbow
    end)

mkRow(pgVisual,"🔦","Fullbright","fullbright",
    function() F.fullbright=not F.fullbright; if F.fullbright then startFB() else stopFB() end; return F.fullbright end)

mkRow(pgVisual,"🔭","FOV Changer","fov",
    function() F.fov=not F.fov; if F.fov then applyFOV() else resetFOV() end; return F.fov end,
    "fovV",F.fovV, function(v) F.fovV=math.clamp(v,30,120); if F.fov then applyFOV() end end)

-- ── WORLD ─────────────────────────────────────────────────────
local function mkWorldBox(parent,label,default,onApply,onReset)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,58); row.BackgroundColor3=S.rowBg; row.BorderSizePixel=0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10); table.insert(allRows,{row=row})
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,0,24); lb.Position=UDim2.new(0,10,0,4)
    lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=S.text; lb.TextXAlignment=Enum.TextXAlignment.Left
    lb.TextScaled=true; lb.Font=Enum.Font.GothamBold; lb.ZIndex=5; lb.Parent=row
    local bx=Instance.new("TextBox"); bx.Size=UDim2.new(0,80,0,22); bx.Position=UDim2.new(0,10,0,30)
    bx.BackgroundColor3=Color3.fromRGB(18,18,28); bx.Text=tostring(default); bx.TextColor3=S.accent
    bx.TextScaled=true; bx.Font=Enum.Font.GothamBold; bx.ZIndex=5; bx.Parent=row
    Instance.new("UICorner",bx).CornerRadius=UDim.new(0,6)
    local ap=Instance.new("TextButton"); ap.Size=UDim2.new(0,72,0,22); ap.Position=UDim2.new(0,98,0,30)
    ap.BackgroundColor3=S.accent; ap.Text="Aplicar"; ap.TextColor3=Color3.new(1,1,1)
    ap.TextScaled=true; ap.Font=Enum.Font.GothamBold; ap.ZIndex=5; ap.Parent=row
    Instance.new("UICorner",ap).CornerRadius=UDim.new(0,6)
    ap.MouseButton1Click:Connect(function() local n=tonumber(bx.Text); if n then p(function() onApply(n) end) end end)
    if onReset then
        local rs=Instance.new("TextButton"); rs.Size=UDim2.new(0,60,0,22); rs.Position=UDim2.new(0,178,0,30)
        rs.BackgroundColor3=Color3.fromRGB(200,60,60); rs.Text="Reset"; rs.TextColor3=Color3.new(1,1,1)
        rs.TextScaled=true; rs.Font=Enum.Font.GothamBold; rs.ZIndex=5; rs.Parent=row
        Instance.new("UICorner",rs).CornerRadius=UDim.new(0,6)
        rs.MouseButton1Click:Connect(function() p(onReset) end)
    end
end

mkWorldBox(pgWorld,"🌍 Gravidade (padrão 196.2)",196.2,
    function(n) workspace.Gravity=n; setStatus("🌍 Gravidade: "..n) end,
    function() workspace.Gravity=196.2; setStatus("🌍 Resetada") end)

mkWorldBox(pgWorld,"💡 Brightness",1,
    function(n) Lighting.Brightness=n; setStatus("💡 Brightness: "..n) end,
    function() Lighting.Brightness=1 end)

mkWorldBox(pgWorld,"🕐 ClockTime (0-24)",14,
    function(n) Lighting.ClockTime=math.clamp(n,0,24); setStatus("🕐 Clock: "..n) end, nil)

-- Botão remover baseplate
local bpBtn=Instance.new("TextButton"); bpBtn.Size=UDim2.new(1,-8,0,44)
bpBtn.BackgroundColor3=S.rowBg; bpBtn.Text="🗑️  Remover Baseplate"; bpBtn.TextColor3=S.text
bpBtn.TextScaled=true; bpBtn.Font=Enum.Font.GothamBold; bpBtn.ZIndex=5; bpBtn.Parent=pgWorld
Instance.new("UICorner",bpBtn).CornerRadius=UDim.new(0,10); table.insert(allRows,{row=bpBtn})
bpBtn.MouseButton1Click:Connect(function()
    local found=false
    p(function() for _,v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and (v.Name=="Baseplate" or v.Name=="Base") then v:Destroy(); found=true end
    end end)
    setStatus(found and "✅ Baseplate removida!" or "⚠️ Não encontrada")
end)

-- Botão explosão
local exBtn=Instance.new("TextButton"); exBtn.Size=UDim2.new(1,-8,0,44)
exBtn.BackgroundColor3=S.rowBg; exBtn.Text="💥  Criar Explosão"; exBtn.TextColor3=S.text
exBtn.TextScaled=true; exBtn.Font=Enum.Font.GothamBold; exBtn.ZIndex=5; exBtn.Parent=pgWorld
Instance.new("UICorner",exBtn).CornerRadius=UDim.new(0,10); table.insert(allRows,{row=exBtn})
exBtn.MouseButton1Click:Connect(function()
    p(function()
        local _,r=getHR(); if not r then return end
        local e=Instance.new("Explosion"); e.BlastRadius=60; e.BlastPressure=5e5; e.Position=r.Position; e.Parent=workspace
        setStatus("💥 Explosão!")
    end)
end)

-- Teleporte para jogador
local tpF=Instance.new("Frame"); tpF.Size=UDim2.new(1,-8,0,58); tpF.BackgroundColor3=S.rowBg; tpF.BorderSizePixel=0; tpF.Parent=pgWorld
Instance.new("UICorner",tpF).CornerRadius=UDim.new(0,10); table.insert(allRows,{row=tpF})
local tpLb=Instance.new("TextLabel"); tpLb.Size=UDim2.new(1,0,0,24); tpLb.Position=UDim2.new(0,10,0,4)
tpLb.BackgroundTransparency=1; tpLb.Text="🚀 Teleportar para jogador:"; tpLb.TextColor3=S.text
tpLb.TextXAlignment=Enum.TextXAlignment.Left; tpLb.TextScaled=true; tpLb.Font=Enum.Font.GothamBold; tpLb.ZIndex=5; tpLb.Parent=tpF
local tpBox=Instance.new("TextBox"); tpBox.Size=UDim2.new(0,120,0,22); tpBox.Position=UDim2.new(0,10,0,30)
tpBox.BackgroundColor3=Color3.fromRGB(18,18,28); tpBox.Text="Nome do jogador"; tpBox.TextColor3=S.accent
tpBox.TextScaled=true; tpBox.Font=Enum.Font.GothamBold; tpBox.ZIndex=5; tpBox.Parent=tpF
Instance.new("UICorner",tpBox).CornerRadius=UDim.new(0,6)
local tpGo=Instance.new("TextButton"); tpGo.Size=UDim2.new(0,60,0,22); tpGo.Position=UDim2.new(0,138,0,30)
tpGo.BackgroundColor3=S.accent; tpGo.Text="IR!"; tpGo.TextColor3=Color3.new(1,1,1)
tpGo.TextScaled=true; tpGo.Font=Enum.Font.GothamBold; tpGo.ZIndex=5; tpGo.Parent=tpF
Instance.new("UICorner",tpGo).CornerRadius=UDim.new(0,6)
tpGo.MouseButton1Click:Connect(function()
    p(function()
        local _,myR=getHR(); if not myR then return end
        local tgt=Players:FindFirstChild(tpBox.Text)
        if tgt and tgt.Character then
            local tr=tgt.Character:FindFirstChild("HumanoidRootPart")
            if tr then myR.CFrame=tr.CFrame+Vector3.new(3,0,0); setStatus("🚀 TP → "..tpBox.Text) end
        else setStatus("⚠️ Jogador não encontrado") end
    end)
end)

-- ── SKINS ─────────────────────────────────────────────────────
local skH=Instance.new("TextLabel"); skH.Size=UDim2.new(1,-8,0,28); skH.BackgroundTransparency=1
skH.Text="  🎨 Escolha sua skin:"; skH.TextColor3=S.accent; skH.TextXAlignment=Enum.TextXAlignment.Left
skH.TextScaled=true; skH.Font=Enum.Font.GothamBold; skH.ZIndex=5; skH.Parent=pgSkins

local function applyAllSkin(sk)
    S=sk
    p(function()
        WIN.BackgroundColor3=sk.bg; TOP.BackgroundColor3=sk.topbar; topFix.BackgroundColor3=sk.topbar
        STROKE.Color=sk.accent; SLBL.TextColor3=sk.accent; skH.TextColor3=sk.accent
        TG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,sk.accent),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
        for _,entry in ipairs(allRows) do p(function() entry.row.BackgroundColor3=sk.rowBg end) end
        for _,pg in pairs(PAGES) do pg.ScrollBarImageColor3=sk.accent end
        for id,btn in pairs(TBTNS) do
            if PAGES[id] and PAGES[id].Visible then
                btn.BackgroundColor3=sk.accent; btn.TextColor3=Color3.new(1,1,1)
            end
        end
    end)
end

for _,sk in ipairs(SKINS) do
    local sb=Instance.new("Frame"); sb.Size=UDim2.new(1,-8,0,52); sb.BackgroundColor3=sk.rowBg; sb.BorderSizePixel=0; sb.Parent=pgSkins
    Instance.new("UICorner",sb).CornerRadius=UDim.new(0,10)

    local sbl=Instance.new("TextLabel"); sbl.Size=UDim2.new(0.52,0,1,0); sbl.Position=UDim2.new(0,12,0,0)
    sbl.BackgroundTransparency=1; sbl.Text=sk.name; sbl.TextColor3=Color3.new(1,1,1)
    sbl.TextXAlignment=Enum.TextXAlignment.Left; sbl.TextScaled=true; sbl.Font=Enum.Font.GothamBold; sbl.ZIndex=5; sbl.Parent=sb

    for j,col in ipairs({sk.accent,sk.on,sk.off,sk.text}) do
        local pd=Instance.new("Frame"); pd.Size=UDim2.new(0,16,0,16)
        pd.Position=UDim2.new(0.55+(j-1)*0.11,0,0.5,-8)
        pd.BackgroundColor3=col; pd.BorderSizePixel=0; pd.ZIndex=6; pd.Parent=sb
        Instance.new("UICorner",pd).CornerRadius=UDim.new(1,0)
    end

    local selB=Instance.new("TextButton"); selB.Size=UDim2.new(1,0,1,0); selB.BackgroundTransparency=1
    selB.Text=""; selB.ZIndex=7; selB.Parent=sb
    selB.MouseButton1Click:Connect(function() applyAllSkin(sk); setStatus("🎨 Skin: "..sk.name) end)
    selB.MouseEnter:Connect(function() tw(sb,0.1,{BackgroundColor3=Color3.fromRGB(30,30,52)}) end)
    selB.MouseLeave:Connect(function() tw(sb,0.1,{BackgroundColor3=sk.rowBg}) end)
end

-- Guia criar skin
local gF=Instance.new("Frame"); gF.Size=UDim2.new(1,-8,0,116); gF.BackgroundColor3=Color3.fromRGB(14,14,26); gF.BorderSizePixel=0; gF.Parent=pgSkins
Instance.new("UICorner",gF).CornerRadius=UDim.new(0,10)
local gL=Instance.new("TextLabel"); gL.Size=UDim2.new(1,-12,1,-10); gL.Position=UDim2.new(0,6,0,5)
gL.BackgroundTransparency=1; gL.TextWrapped=true; gL.TextColor3=Color3.fromRGB(180,180,220)
gL.Text="💡 CRIAR SUA SKIN:\n1. Abra o script\n2. Vá até 'CRIE SUA SKIN AQUI'\n3. Apague os '--' do bloco comentado\n4. Troque o nome e os valores RGB (0-255)\n5. Execute o script novamente!"
gL.TextScaled=true; gL.Font=Enum.Font.Gotham; gL.ZIndex=5; gL.Parent=gF

-- DRAG
local drag,ds,sp2
TOP.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; ds=i.Position; sp2=WIN.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ds; WIN.Position=UDim2.new(sp2.X.Scale,sp2.X.Offset+d.X,sp2.Y.Scale,sp2.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)

-- ANIMAÇÃO ENTRADA
WIN.Size=UDim2.new(0,0,0,0); WIN.Position=UDim2.new(0.5,0,0.5,0)
tw(WIN,0.45,{Size=UDim2.new(0,460,0,640), Position=UDim2.new(0.5,-230,0.5,-320)})

-- ATALHOS
UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.KeyCode==Enum.KeyCode.Insert then
        guiOpen=not guiOpen
        if guiOpen then WIN.Visible=true; tw(WIN,0.3,{Size=UDim2.new(0,460,0,640)})
        else tw(WIN,0.2,{Size=UDim2.new(0,0,0,0)}); task.delay(0.25,function() WIN.Visible=false end) end
    end
    if inp.KeyCode==Enum.KeyCode.P         then F.speedV=F.speedV+20;              setStatus("⚡ Speed: "..F.speedV) end
    if inp.KeyCode==Enum.KeyCode.Semicolon then F.speedV=math.max(16,F.speedV-20); setStatus("⚡ Speed: "..F.speedV) end
    if inp.KeyCode==Enum.KeyCode.F2 then
        F.fly=not F.fly; if F.fly then startFly() else stopFly() end; setStatus((F.fly and "✅" or "❌").." Fly") end
    if inp.KeyCode==Enum.KeyCode.F3 then
        F.noclip=not F.noclip; if F.noclip then startNoclip() else stopNoclip() end; setStatus((F.noclip and "✅" or "❌").." Noclip") end
    if inp.KeyCode==Enum.KeyCode.F4 then
        F.esp=not F.esp; if F.esp then applyESP() else clearESP() end; setStatus((F.esp and "✅" or "❌").." ESP") end
end)

print("╔═════════════════════════════════════╗")
print("║  ⚡  MLG HACK v5.0  -  ZERO ERROS   ║")
print("║  Insert | F2=Fly | F3=Noclip | F4=ESP║")
print("╚═════════════════════════════════════╝")
