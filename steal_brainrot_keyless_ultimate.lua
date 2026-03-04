-- ╔══════════════════════════════════════════════════════════╗
-- ║         MLG HACK v6.0 - SKIN EDITOR + BUG FIX           ║
-- ║   Editor de cor visual • Char skin • Zero erros          ║
-- ╚══════════════════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local lp               = Players.LocalPlayer

-- Remove GUI antiga
pcall(function()
    for _,v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if tostring(v.Name):find("MLG") then v:Destroy() end
    end
end)
pcall(function()
    for _,v in ipairs(lp.PlayerGui:GetChildren()) do
        if tostring(v.Name):find("MLG") then v:Destroy() end
    end
end)

-- ============================================================
-- SKINS PRÉ-DEFINIDAS
-- ============================================================
local SKINS = {
    { name="🟢 Matrix",  bg=Color3.fromRGB(8,14,8),   top=Color3.fromRGB(5,20,5),   acc=Color3.fromRGB(0,255,80),  row=Color3.fromRGB(14,24,14),  txt=Color3.fromRGB(180,255,180), on=Color3.fromRGB(0,220,70),  off=Color3.fromRGB(30,60,30),  rb=false },
    { name="🔵 Ocean",   bg=Color3.fromRGB(5,12,25),  top=Color3.fromRGB(5,10,22),  acc=Color3.fromRGB(0,180,255), row=Color3.fromRGB(10,18,36),  txt=Color3.fromRGB(180,220,255), on=Color3.fromRGB(0,160,255), off=Color3.fromRGB(20,40,80),  rb=false },
    { name="🔴 Blood",   bg=Color3.fromRGB(18,5,5),   top=Color3.fromRGB(14,4,4),   acc=Color3.fromRGB(255,40,40), row=Color3.fromRGB(26,8,8),    txt=Color3.fromRGB(255,180,180), on=Color3.fromRGB(220,40,40), off=Color3.fromRGB(70,20,20),  rb=false },
    { name="🟡 Gold",    bg=Color3.fromRGB(16,13,4),  top=Color3.fromRGB(12,10,3),  acc=Color3.fromRGB(255,200,0), row=Color3.fromRGB(24,20,6),   txt=Color3.fromRGB(255,240,180), on=Color3.fromRGB(220,180,0), off=Color3.fromRGB(60,50,10),  rb=false },
    { name="🟣 Purple",  bg=Color3.fromRGB(12,5,20),  top=Color3.fromRGB(10,4,18),  acc=Color3.fromRGB(180,0,255), row=Color3.fromRGB(20,8,34),   txt=Color3.fromRGB(220,180,255), on=Color3.fromRGB(160,0,220), off=Color3.fromRGB(50,20,80),  rb=false },
    { name="🟠 Orange",  bg=Color3.fromRGB(18,10,4),  top=Color3.fromRGB(14,8,3),   acc=Color3.fromRGB(255,140,0), row=Color3.fromRGB(26,14,6),   txt=Color3.fromRGB(255,220,180), on=Color3.fromRGB(220,120,0), off=Color3.fromRGB(70,40,10),  rb=false },
    { name="⚫ Dark",    bg=Color3.fromRGB(6,6,6),    top=Color3.fromRGB(4,4,4),    acc=Color3.fromRGB(180,180,180),row=Color3.fromRGB(14,14,14), txt=Color3.fromRGB(220,220,220), on=Color3.fromRGB(160,160,160),off=Color3.fromRGB(40,40,40), rb=false },
    { name="🌈 Rainbow", bg=Color3.fromRGB(10,10,18), top=Color3.fromRGB(8,8,14),   acc=Color3.fromRGB(255,100,200),row=Color3.fromRGB(16,16,28), txt=Color3.fromRGB(255,255,255), on=Color3.fromRGB(100,255,200),off=Color3.fromRGB(40,40,70), rb=true  },
}

-- Skin atual (começa com Matrix)
local S = {
    name="🟢 Matrix",
    bg=Color3.fromRGB(8,14,8), top=Color3.fromRGB(5,20,5),
    acc=Color3.fromRGB(0,255,80), row=Color3.fromRGB(14,24,14),
    txt=Color3.fromRGB(180,255,180), on=Color3.fromRGB(0,220,70),
    off=Color3.fromRGB(30,60,30), rb=false
}

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
    rainbowChar=false,
    spin=false,
    antiafk=true,
    freecam=false,
    hitbox=false, hitboxV=10,
    fov=false, fovV=90,
    speedjump=false,
    lowgrav=false,
    -- SKIN DO PERSONAGEM
    charSkin=false,
    charR=255, charG=100, charB=50,
    charTransp=0,
}

local CONNS   = {}
local espHL   = {}
local guiOpen = true
local rbH     = 0
local strokeH = 0
local allSkinEls = {} -- elementos da GUI para reskinar
local charSkinConn -- conexão da skin do personagem

-- ============================================================
-- HELPERS
-- ============================================================
local function p(fn, ...) pcall(fn, ...) end
local function tw(obj, t, props) p(function() TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play() end) end

local function getH()  local c=lp and lp.Character; if not c then return nil end return c:FindFirstChildOfClass("Humanoid") end
local function getHR() local c=lp and lp.Character; if not c then return nil,nil end return c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart") end

local function disc(id) if CONNS[id] then p(function() CONNS[id]:Disconnect() end); CONNS[id]=nil end end

local SLBL -- status bar label
local function setStatus(t) p(function() if SLBL then SLBL.Text="  "..t end end) end

-- ============================================================
-- SKIN DO PERSONAGEM (visto por todos)
-- ============================================================
local function applyCharSkin()
    local c = lp and lp.Character; if not c then return end
    local col = Color3.fromRGB(F.charR, F.charG, F.charB)
    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            p(function()
                part.Color = col
                part.Transparency = F.charTransp
            end)
        end
    end
    -- Shirt/Pants removidos para a cor aparecer
    p(function()
        local shirt = c:FindFirstChildOfClass("Shirt")
        local pants = c:FindFirstChildOfClass("Pants")
        if shirt then shirt:Destroy() end
        if pants then pants:Destroy() end
    end)
end

local function startCharSkin()
    applyCharSkin()
    charSkinConn = RunService.Heartbeat:Connect(function()
        if not F.charSkin then return end
        p(applyCharSkin)
    end)
end

local function stopCharSkin()
    if charSkinConn then p(function() charSkinConn:Disconnect() end); charSkinConn=nil end
    -- Restaura cor padrão
    p(function()
        local c=lp.Character; if not c then return end
        for _,part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.fromRGB(163,162,165)
                part.Transparency = 0
            end
        end
    end)
end

-- Reaplicar ao respawn
lp.CharacterAdded:Connect(function(c)
    c:WaitForChild("Humanoid",5); c:WaitForChild("HumanoidRootPart",5); task.wait(0.5)
    p(function()
        if F.charSkin  then applyCharSkin()  end
        if F.god       then startGod()       end
        if F.fly       then startFly()       end
        if F.noclip    then startNoclip()    end
    end)
end)

-- ============================================================
-- FEATURES
-- ============================================================

-- SPEED (corrigido: só aplica quando movendo)
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
function startFly()
    p(function()
        local h,r = getHR(); if not h or not r then return end
        h.PlatformStand = true
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5); flyBV.Velocity=Vector3.zero; flyBV.Parent=r
        flyBG = Instance.new("BodyGyro");     flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.P=1e4; flyBG.Parent=r
        CONNS.fly = RunService.Heartbeat:Connect(function()
            if not F.fly then return end
            p(function()
                local cam=workspace.CurrentCamera; local d=Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector  end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then d=d+Vector3.new(0,1,0)  end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d=d-Vector3.new(0,1,0)  end
                flyBV.Velocity=d.Magnitude>0 and d.Unit*F.flyV or Vector3.zero
                flyBG.CFrame=cam.CFrame
            end)
        end)
    end)
end
function stopFly()
    disc("fly")
    p(function() if flyBV then flyBV:Destroy(); flyBV=nil end end)
    p(function() if flyBG then flyBG:Destroy(); flyBG=nil end end)
    p(function() local h=getH(); if h then h.PlatformStand=false end end)
end

-- NOCLIP
function startNoclip()
    CONNS.noclip = RunService.Stepped:Connect(function()
        p(function()
            local c=lp.Character; if not c then return end
            for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
        end)
    end)
end
function stopNoclip()
    disc("noclip")
    p(function()
        local c=lp.Character; if not c then return end
        for _,v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=true end end
    end)
end

-- GOD
function startGod()
    p(function()
        local h=getH(); if not h then return end
        h.MaxHealth=math.huge; h.Health=math.huge
        disc("god")
        CONNS.god = h:GetPropertyChangedSignal("Health"):Connect(function()
            if F.god then p(function() h.Health=math.huge end) end
        end)
    end)
end

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if F.infjump then p(function() local h=getH(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
end)

-- CLICK TP
local function startClickTP()
    disc("clicktp")
    CONNS.clicktp = UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            p(function()
                local _,r=getHR(); if not r then return end
                local cam=workspace.CurrentCamera
                local ray=workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector*600)
                if ray then r.CFrame=CFrame.new(ray.Position+Vector3.new(0,3,0)) end
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

-- RAINBOW CHAR (cor ciclada, diferente da skin estática)
RunService.Heartbeat:Connect(function()
    if not F.rainbowChar then return end
    p(function()
        rbH=(rbH+0.8)%360
        local c=lp.Character; if not c then return end
        local col=Color3.fromHSV(rbH/360,1,1)
        for _,pt in ipairs(c:GetDescendants()) do
            if pt:IsA("BasePart") and pt.Name~="HumanoidRootPart" then pt.Color=col end
        end
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
    local ok,h=pcall(function()
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
    disc("freecam"); p(function() if fcBV then fcBV:Destroy(); fcBV=nil end end)
end

-- ANTI AFK (sem VirtualUser)
task.spawn(function()
    while task.wait(55) do
        if F.antiafk then p(function()
            local h=getH(); if h then h.Jump=false end
        end) end
    end
end)

-- ============================================================
-- GUI
-- ============================================================
local SG=Instance.new("ScreenGui")
SG.Name="MLGHack_v6"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.IgnoreGuiInset=true
local placed=false
p(function() SG.Parent=game:GetService("CoreGui"); placed=true end)
if not placed then p(function() SG.Parent=lp.PlayerGui; placed=true end) end

-- Aplica toda a skin nos elementos registrados
local function applyFullSkin(sk)
    S=sk
    p(function()
        for _,e in ipairs(allSkinEls) do p(function()
            if e.type=="bg"    then e.obj.BackgroundColor3=sk.bg  end
            if e.type=="top"   then e.obj.BackgroundColor3=sk.top end
            if e.type=="acc"   then e.obj.BackgroundColor3=sk.acc end
            if e.type=="row"   then e.obj.BackgroundColor3=sk.row end
            if e.type=="txt"   then e.obj.TextColor3=sk.txt       end
            if e.type=="stroke"then e.obj.Color=sk.acc            end
            if e.type=="grad"  then e.obj.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,sk.acc),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))} end
            if e.type=="scroll"then e.obj.ScrollBarImageColor3=sk.acc end
            if e.type=="tabactive" then if PAGES and PAGES[e.id] and PAGES[e.id].Visible then e.obj.BackgroundColor3=sk.acc; e.obj.TextColor3=Color3.new(1,1,1) end end
        end) end
        if SLBL then SLBL.TextColor3=sk.acc end
    end)
end

local function regSkin(t, obj, extra)
    table.insert(allSkinEls, {type=t, obj=obj, id=extra})
end

-- JANELA
local WIN=Instance.new("Frame")
WIN.Name="WIN"; WIN.Size=UDim2.new(0,460,0,640); WIN.Position=UDim2.new(0.5,-230,0.5,-320)
WIN.BackgroundColor3=S.bg; WIN.BorderSizePixel=0; WIN.ClipsDescendants=true; WIN.Parent=SG
Instance.new("UICorner",WIN).CornerRadius=UDim.new(0,16)
regSkin("bg", WIN)

local STROKE=Instance.new("UIStroke"); STROKE.Thickness=2.5; STROKE.Color=S.acc; STROKE.Parent=WIN
regSkin("stroke", STROKE)

RunService.Heartbeat:Connect(function()
    if not S.rb then return end
    p(function() strokeH=(strokeH+0.5)%360; STROKE.Color=Color3.fromHSV(strokeH/360,1,1) end)
end)

-- TOPBAR
local TOP=Instance.new("Frame")
TOP.Size=UDim2.new(1,0,0,62); TOP.BackgroundColor3=S.top; TOP.BorderSizePixel=0; TOP.ZIndex=5; TOP.Parent=WIN
Instance.new("UICorner",TOP).CornerRadius=UDim.new(0,16)
regSkin("top", TOP)
local topFix=Instance.new("Frame"); topFix.Size=UDim2.new(1,0,0,16); topFix.Position=UDim2.new(0,0,1,-16)
topFix.BackgroundColor3=S.top; topFix.BorderSizePixel=0; topFix.ZIndex=5; topFix.Parent=TOP
regSkin("top", topFix)

local TG=Instance.new("UIGradient"); TG.Rotation=90
TG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,S.acc),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
TG.Parent=TOP
regSkin("grad", TG)

local TITLELBL=Instance.new("TextLabel")
TITLELBL.Size=UDim2.new(0,240,0,36); TITLELBL.Position=UDim2.new(0,14,0,5)
TITLELBL.BackgroundTransparency=1; TITLELBL.Text="⚡ MLG HACK"
TITLELBL.TextColor3=Color3.new(1,1,1); TITLELBL.TextScaled=true; TITLELBL.Font=Enum.Font.GothamBold
TITLELBL.ZIndex=6; TITLELBL.Parent=TOP

local SUBLBL3=Instance.new("TextLabel")
SUBLBL3.Size=UDim2.new(0,260,0,16); SUBLBL3.Position=UDim2.new(0,14,0,43)
SUBLBL3.BackgroundTransparency=1; SUBLBL3.Text="v6.0  ·  SKIN EDITOR  ·  ZERO ERROS"
SUBLBL3.TextColor3=Color3.fromRGB(200,255,200); SUBLBL3.TextScaled=true; SUBLBL3.Font=Enum.Font.Gotham
SUBLBL3.ZIndex=6; SUBLBL3.Parent=TOP

local function mkTopBtn(t,col,xo)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,32,0,32); b.Position=UDim2.new(1,xo,0,15)
    b.BackgroundColor3=col; b.Text=t; b.TextColor3=Color3.new(1,1,1)
    b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.ZIndex=7; b.Parent=TOP
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); return b
end
mkTopBtn("✕",Color3.fromRGB(255,55,55),-10).MouseButton1Click:Connect(function() SG:Destroy() end)
mkTopBtn("−",Color3.fromRGB(55,55,80),-48).MouseButton1Click:Connect(function()
    guiOpen=not guiOpen
    tw(WIN,0.3,{Size=guiOpen and UDim2.new(0,460,0,640) or UDim2.new(0,460,0,62)})
end)

-- TABS
local TABBAR=Instance.new("Frame")
TABBAR.Size=UDim2.new(1,0,0,36); TABBAR.Position=UDim2.new(0,0,0,62)
TABBAR.BackgroundColor3=Color3.fromRGB(10,10,16); TABBAR.BorderSizePixel=0; TABBAR.ZIndex=5; TABBAR.Parent=WIN
local tbl=Instance.new("UIListLayout"); tbl.FillDirection=Enum.FillDirection.Horizontal
tbl.HorizontalAlignment=Enum.HorizontalAlignment.Center; tbl.VerticalAlignment=Enum.VerticalAlignment.Center
tbl.Padding=UDim.new(0,3); tbl.Parent=TABBAR

local PAGES={}; local TBTNS={}
local function mkTab(id,icon,lbl)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,68,0,28); btn.BackgroundColor3=Color3.fromRGB(20,20,32)
    btn.Text=icon.." "..lbl; btn.TextColor3=Color3.fromRGB(130,130,160)
    btn.TextScaled=true; btn.Font=Enum.Font.GothamSemibold; btn.ZIndex=6; btn.Parent=TABBAR
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

    local pg=Instance.new("ScrollingFrame")
    pg.Size=UDim2.new(1,-16,1,-112); pg.Position=UDim2.new(0,8,0,102)
    pg.BackgroundTransparency=1; pg.ScrollBarThickness=3; pg.ScrollBarImageColor3=S.acc
    pg.Visible=false; pg.ZIndex=4; pg.Parent=WIN; pg.CanvasSize=UDim2.new(0,0,0,0)
    regSkin("scroll", pg)

    local pgl=Instance.new("UIListLayout"); pgl.Padding=UDim.new(0,7); pgl.Parent=pg
    pgl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pg.CanvasSize=UDim2.new(0,0,0,pgl.AbsoluteContentSize.Y+16)
    end)
    btn.MouseButton1Click:Connect(function()
        for k,pg2 in pairs(PAGES) do
            pg2.Visible=false; TBTNS[k].BackgroundColor3=Color3.fromRGB(20,20,32); TBTNS[k].TextColor3=Color3.fromRGB(130,130,160)
        end
        pg.Visible=true; btn.BackgroundColor3=S.acc; btn.TextColor3=Color3.new(1,1,1)
    end)
    PAGES[id]=pg; TBTNS[id]=btn; return pg
end

local pgMove   = mkTab("move",   "🏃","Move")
local pgCombat = mkTab("combat", "⚔️", "Combat")
local pgVisual = mkTab("visual", "👁️", "Visual")
local pgWorld  = mkTab("world",  "🌍","World")
local pgSkins  = mkTab("skins",  "🎨","Skins")

PAGES["move"].Visible=true; TBTNS["move"].BackgroundColor3=S.acc; TBTNS["move"].TextColor3=Color3.new(1,1,1)

-- STATUS BAR
local SBAR=Instance.new("Frame")
SBAR.Size=UDim2.new(1,0,0,24); SBAR.Position=UDim2.new(0,0,1,-24)
SBAR.BackgroundColor3=Color3.fromRGB(6,6,10); SBAR.BorderSizePixel=0; SBAR.ZIndex=5; SBAR.Parent=WIN
SLBL=Instance.new("TextLabel")
SLBL.Size=UDim2.new(1,-10,1,0); SLBL.Position=UDim2.new(0,10,0,0); SLBL.BackgroundTransparency=1
SLBL.Text="  ✅ MLG Hack v6 | Insert=esconder | F2=Fly | F3=Noclip | F4=ESP"
SLBL.TextColor3=S.acc; SLBL.TextScaled=true; SLBL.Font=Enum.Font.Gotham
SLBL.TextXAlignment=Enum.TextXAlignment.Left; SLBL.ZIndex=6; SLBL.Parent=SBAR

-- ============================================================
-- COMPONENTE: TOGGLE ROW
-- ============================================================
local function mkRow(parent,icon,name,flagKey,onToggle,numKey,numDef,onNum)
    local isOn=flagKey and F[flagKey] or false
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-8,0,numKey and 62 or 48)
    row.BackgroundColor3=S.row; row.BorderSizePixel=0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    regSkin("row", row)

    local icF=Instance.new("Frame"); icF.Size=UDim2.new(0,34,0,34); icF.Position=UDim2.new(0,7,0.5,-17)
    icF.BackgroundColor3=Color3.fromRGB(22,22,34); icF.BorderSizePixel=0; icF.ZIndex=5; icF.Parent=row
    Instance.new("UICorner",icF).CornerRadius=UDim.new(0,8)
    local icL=Instance.new("TextLabel"); icL.Size=UDim2.new(1,0,1,0); icL.BackgroundTransparency=1
    icL.Text=icon; icL.TextScaled=true; icL.Font=Enum.Font.GothamBold; icL.TextColor3=Color3.new(1,1,1); icL.ZIndex=6; icL.Parent=icF

    local nm=Instance.new("TextLabel"); nm.Size=UDim2.new(0.52,0,0,22); nm.Position=UDim2.new(0,50,0,5)
    nm.BackgroundTransparency=1; nm.Text=name; nm.TextColor3=S.txt
    nm.TextXAlignment=Enum.TextXAlignment.Left; nm.TextScaled=true; nm.Font=Enum.Font.GothamBold; nm.ZIndex=5; nm.Parent=row
    regSkin("txt", nm)

    if numKey then
        local box=Instance.new("TextBox"); box.Size=UDim2.new(0,68,0,22); box.Position=UDim2.new(0,50,0,34)
        box.BackgroundColor3=Color3.fromRGB(18,18,28); box.Text=tostring(numDef)
        box.TextColor3=S.acc; box.TextScaled=true; box.Font=Enum.Font.GothamBold; box.ZIndex=5; box.Parent=row
        Instance.new("UICorner",box).CornerRadius=UDim.new(0,6)
        regSkin("acc", box) -- cor do texto do box
        box.FocusLost:Connect(function()
            local n=tonumber(box.Text); if n and onNum then p(function() onNum(n) end); setStatus("✏️ "..name.." = "..n) end
        end)
    end

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
    row.MouseEnter:Connect(function() tw(row,0.08,{BackgroundColor3=Color3.fromRGB(28,28,46)}) end)
    row.MouseLeave:Connect(function() tw(row,0.08,{BackgroundColor3=S.row}) end)
end

-- ── MOVE ──────────────────────────────────────────────────────
mkRow(pgMove,"⚡","Speed Hack","speed",function() F.speed=not F.speed; return F.speed end,"speedV",F.speedV,function(v) F.speedV=math.max(16,v) end)
mkRow(pgMove,"🦅","Fly (WASD+Space/Ctrl)","fly",function() F.fly=not F.fly; if F.fly then startFly() else stopFly() end; return F.fly end,"flyV",F.flyV,function(v) F.flyV=math.max(10,v) end)
mkRow(pgMove,"👻","Noclip","noclip",function() F.noclip=not F.noclip; if F.noclip then startNoclip() else stopNoclip() end; return F.noclip end)
mkRow(pgMove,"♾️","Infinite Jump","infjump",function() F.infjump=not F.infjump; return F.infjump end)
mkRow(pgMove,"🖱️","Click Teleport","clicktp",function() F.clicktp=not F.clicktp; if F.clicktp then startClickTP() else disc("clicktp") end; return F.clicktp end)
mkRow(pgMove,"🌀","Spin Mode","spin",function() F.spin=not F.spin; return F.spin end)
mkRow(pgMove,"🎥","Free Cam (I/J/K/L)","freecam",function() F.freecam=not F.freecam; if F.freecam then startFreecam() else stopFreecam() end; return F.freecam end)
mkRow(pgMove,"🛑","Anti AFK","antiafk",function() F.antiafk=not F.antiafk; return F.antiafk end)

-- ── COMBAT ────────────────────────────────────────────────────
mkRow(pgCombat,"🛡️","God Mode","god",function() F.god=not F.god; if F.god then startGod() else disc("god") end; return F.god end)
mkRow(pgCombat,"📦","Hitbox Expander","hitbox",function() F.hitbox=not F.hitbox; if F.hitbox then applyHitbox() end; return F.hitbox end,"hitboxV",F.hitboxV,function(v) F.hitboxV=math.max(1,v); if F.hitbox then applyHitbox() end end)
mkRow(pgCombat,"🦘","Speed Jump","speedjump",function()
    F.speedjump=not F.speedjump; p(function() local h=getH(); if h then h.JumpPower=F.speedjump and 120 or 50 end end); return F.speedjump end)
mkRow(pgCombat,"🌑","Low Gravity","lowgrav",function()
    F.lowgrav=not F.lowgrav; p(function() workspace.Gravity=F.lowgrav and 40 or 196.2 end); return F.lowgrav end)

-- ── VISUAL ────────────────────────────────────────────────────
mkRow(pgVisual,"👁️","ESP Players","esp",function() F.esp=not F.esp; if F.esp then applyESP() else clearESP() end; return F.esp end)
mkRow(pgVisual,"🌈","Rainbow Char","rainbowChar",function()
    F.rainbowChar=not F.rainbowChar
    if not F.rainbowChar then p(function()
        local c=lp.Character; if not c then return end
        for _,pt in ipairs(c:GetDescendants()) do if pt:IsA("BasePart") and pt.Name~="HumanoidRootPart" then pt.Color=Color3.fromRGB(163,162,165); pt.Transparency=0 end end
    end) end; return F.rainbowChar end)
mkRow(pgVisual,"🔦","Fullbright","fullbright",function() F.fullbright=not F.fullbright; if F.fullbright then startFB() else stopFB() end; return F.fullbright end)
mkRow(pgVisual,"🔭","FOV Changer","fov",function() F.fov=not F.fov; if F.fov then applyFOV() else resetFOV() end; return F.fov end,"fovV",F.fovV,function(v) F.fovV=math.clamp(v,30,120); if F.fov then applyFOV() end end)

-- ── WORLD ─────────────────────────────────────────────────────
local function mkWorldBox(parent,label,default,onApply,onReset)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,-8,0,58); row.BackgroundColor3=S.row; row.BorderSizePixel=0; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10); regSkin("row",row)
    local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,0,0,24); lb.Position=UDim2.new(0,10,0,4)
    lb.BackgroundTransparency=1; lb.Text=label; lb.TextColor3=S.txt; lb.TextXAlignment=Enum.TextXAlignment.Left
    lb.TextScaled=true; lb.Font=Enum.Font.GothamBold; lb.ZIndex=5; lb.Parent=row; regSkin("txt",lb)
    local bx=Instance.new("TextBox"); bx.Size=UDim2.new(0,80,0,22); bx.Position=UDim2.new(0,10,0,30)
    bx.BackgroundColor3=Color3.fromRGB(18,18,28); bx.Text=tostring(default); bx.TextColor3=S.acc
    bx.TextScaled=true; bx.Font=Enum.Font.GothamBold; bx.ZIndex=5; bx.Parent=row
    Instance.new("UICorner",bx).CornerRadius=UDim.new(0,6)
    local ap=Instance.new("TextButton"); ap.Size=UDim2.new(0,72,0,22); ap.Position=UDim2.new(0,98,0,30)
    ap.BackgroundColor3=S.acc; ap.Text="Aplicar"; ap.TextColor3=Color3.new(1,1,1)
    ap.TextScaled=true; ap.Font=Enum.Font.GothamBold; ap.ZIndex=5; ap.Parent=row
    Instance.new("UICorner",ap).CornerRadius=UDim.new(0,6); regSkin("acc",ap)
    ap.MouseButton1Click:Connect(function() local n=tonumber(bx.Text); if n then p(function() onApply(n) end) end end)
    if onReset then
        local rs=Instance.new("TextButton"); rs.Size=UDim2.new(0,60,0,22); rs.Position=UDim2.new(0,178,0,30)
        rs.BackgroundColor3=Color3.fromRGB(200,60,60); rs.Text="Reset"; rs.TextColor3=Color3.new(1,1,1)
        rs.TextScaled=true; rs.Font=Enum.Font.GothamBold; rs.ZIndex=5; rs.Parent=row
        Instance.new("UICorner",rs).CornerRadius=UDim.new(0,6)
        rs.MouseButton1Click:Connect(function() p(onReset) end)
    end
end
mkWorldBox(pgWorld,"🌍 Gravidade (padrão 196.2)",196.2,function(n) workspace.Gravity=n; setStatus("🌍 "..n) end,function() workspace.Gravity=196.2 end)
mkWorldBox(pgWorld,"💡 Brightness",1,function(n) Lighting.Brightness=n end,function() Lighting.Brightness=1 end)
mkWorldBox(pgWorld,"🕐 ClockTime (0-24)",14,function(n) Lighting.ClockTime=math.clamp(n,0,24) end,nil)

local bpBtn=Instance.new("TextButton"); bpBtn.Size=UDim2.new(1,-8,0,44); bpBtn.BackgroundColor3=S.row
bpBtn.Text="🗑️  Remover Baseplate"; bpBtn.TextColor3=S.txt; bpBtn.TextScaled=true; bpBtn.Font=Enum.Font.GothamBold; bpBtn.ZIndex=5; bpBtn.Parent=pgWorld
Instance.new("UICorner",bpBtn).CornerRadius=UDim.new(0,10); regSkin("row",bpBtn)
bpBtn.MouseButton1Click:Connect(function()
    local f=false; p(function() for _,v in ipairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and (v.Name=="Baseplate" or v.Name=="Base") then v:Destroy(); f=true end
    end end); setStatus(f and "✅ Removida!" or "⚠️ Não encontrada")
end)

local exBtn=Instance.new("TextButton"); exBtn.Size=UDim2.new(1,-8,0,44); exBtn.BackgroundColor3=S.row
exBtn.Text="💥  Criar Explosão"; exBtn.TextColor3=S.txt; exBtn.TextScaled=true; exBtn.Font=Enum.Font.GothamBold; exBtn.ZIndex=5; exBtn.Parent=pgWorld
Instance.new("UICorner",exBtn).CornerRadius=UDim.new(0,10); regSkin("row",exBtn)
exBtn.MouseButton1Click:Connect(function() p(function()
    local _,r=getHR(); if not r then return end
    local e=Instance.new("Explosion"); e.BlastRadius=60; e.BlastPressure=5e5; e.Position=r.Position; e.Parent=workspace
    setStatus("💥 Boom!")
end) end)

-- TP para jogador
local tpF=Instance.new("Frame"); tpF.Size=UDim2.new(1,-8,0,58); tpF.BackgroundColor3=S.row; tpF.BorderSizePixel=0; tpF.Parent=pgWorld
Instance.new("UICorner",tpF).CornerRadius=UDim.new(0,10); regSkin("row",tpF)
local tpLb=Instance.new("TextLabel"); tpLb.Size=UDim2.new(1,0,0,24); tpLb.Position=UDim2.new(0,10,0,4)
tpLb.BackgroundTransparency=1; tpLb.Text="🚀 TP para jogador:"; tpLb.TextColor3=S.txt
tpLb.TextXAlignment=Enum.TextXAlignment.Left; tpLb.TextScaled=true; tpLb.Font=Enum.Font.GothamBold; tpLb.ZIndex=5; tpLb.Parent=tpF; regSkin("txt",tpLb)
local tpBox=Instance.new("TextBox"); tpBox.Size=UDim2.new(0,120,0,22); tpBox.Position=UDim2.new(0,10,0,30)
tpBox.BackgroundColor3=Color3.fromRGB(18,18,28); tpBox.Text="Nome"; tpBox.TextColor3=S.acc
tpBox.TextScaled=true; tpBox.Font=Enum.Font.GothamBold; tpBox.ZIndex=5; tpBox.Parent=tpF
Instance.new("UICorner",tpBox).CornerRadius=UDim.new(0,6)
local tpGo=Instance.new("TextButton"); tpGo.Size=UDim2.new(0,60,0,22); tpGo.Position=UDim2.new(0,138,0,30)
tpGo.BackgroundColor3=S.acc; tpGo.Text="IR!"; tpGo.TextColor3=Color3.new(1,1,1)
tpGo.TextScaled=true; tpGo.Font=Enum.Font.GothamBold; tpGo.ZIndex=5; tpGo.Parent=tpF
Instance.new("UICorner",tpGo).CornerRadius=UDim.new(0,6); regSkin("acc",tpGo)
tpGo.MouseButton1Click:Connect(function() p(function()
    local _,myR=getHR(); if not myR then return end
    local tgt=Players:FindFirstChild(tpBox.Text)
    if tgt and tgt.Character then
        local tr=tgt.Character:FindFirstChild("HumanoidRootPart")
        if tr then myR.CFrame=tr.CFrame+Vector3.new(3,0,0); setStatus("🚀 TP → "..tpBox.Text) end
    else setStatus("⚠️ Jogador não encontrado") end
end) end)

-- ============================================================
-- ABA SKINS - COM EDITOR VISUAL
-- ============================================================
local skH=Instance.new("TextLabel"); skH.Size=UDim2.new(1,-8,0,26); skH.BackgroundTransparency=1
skH.Text="  🎨 Skins prontas:"; skH.TextColor3=S.acc; skH.TextXAlignment=Enum.TextXAlignment.Left
skH.TextScaled=true; skH.Font=Enum.Font.GothamBold; skH.ZIndex=5; skH.Parent=pgSkins
regSkin("txt",skH)

-- Botões de skin pronta
for _,sk in ipairs(SKINS) do
    local sb=Instance.new("Frame"); sb.Size=UDim2.new(1,-8,0,50); sb.BackgroundColor3=sk.row; sb.BorderSizePixel=0; sb.Parent=pgSkins
    Instance.new("UICorner",sb).CornerRadius=UDim.new(0,10)
    local sbl=Instance.new("TextLabel"); sbl.Size=UDim2.new(0.5,0,1,0); sbl.Position=UDim2.new(0,12,0,0)
    sbl.BackgroundTransparency=1; sbl.Text=sk.name; sbl.TextColor3=Color3.new(1,1,1)
    sbl.TextXAlignment=Enum.TextXAlignment.Left; sbl.TextScaled=true; sbl.Font=Enum.Font.GothamBold; sbl.ZIndex=5; sbl.Parent=sb
    for j,col in ipairs({sk.acc,sk.on,sk.off,sk.bg}) do
        local pd=Instance.new("Frame"); pd.Size=UDim2.new(0,16,0,16)
        pd.Position=UDim2.new(0.53+(j-1)*0.11,0,0.5,-8); pd.BackgroundColor3=col; pd.BorderSizePixel=0; pd.ZIndex=6; pd.Parent=sb
        Instance.new("UICorner",pd).CornerRadius=UDim.new(1,0)
    end
    local selB=Instance.new("TextButton"); selB.Size=UDim2.new(1,0,1,0); selB.BackgroundTransparency=1; selB.Text=""; selB.ZIndex=7; selB.Parent=sb
    selB.MouseButton1Click:Connect(function() applyFullSkin(sk); setStatus("🎨 "..sk.name) end)
    selB.MouseEnter:Connect(function() tw(sb,0.08,{BackgroundColor3=Color3.fromRGB(30,30,52)}) end)
    selB.MouseLeave:Connect(function() tw(sb,0.08,{BackgroundColor3=sk.row}) end)
end

-- ── EDITOR DE COR DA GUI ──────────────────────────────────────
local edH=Instance.new("TextLabel"); edH.Size=UDim2.new(1,-8,0,26); edH.BackgroundTransparency=1
edH.Text="  ✏️ Editor: crie sua skin visual:"; edH.TextColor3=S.acc
edH.TextXAlignment=Enum.TextXAlignment.Left; edH.TextScaled=true; edH.Font=Enum.Font.GothamBold; edH.ZIndex=5; edH.Parent=pgSkins
regSkin("txt",edH)

-- Preview ao vivo
local prevBox=Instance.new("Frame"); prevBox.Size=UDim2.new(1,-8,0,44); prevBox.BackgroundColor3=Color3.fromRGB(14,14,24); prevBox.BorderSizePixel=0; prevBox.Parent=pgSkins
Instance.new("UICorner",prevBox).CornerRadius=UDim.new(0,10)
local prevLbl=Instance.new("TextLabel"); prevLbl.Size=UDim2.new(0.5,0,1,0); prevLbl.Position=UDim2.new(0,12,0,0)
prevLbl.BackgroundTransparency=1; prevLbl.Text="⚡ Preview da skin"; prevLbl.TextColor3=S.acc
prevLbl.TextXAlignment=Enum.TextXAlignment.Left; prevLbl.TextScaled=true; prevLbl.Font=Enum.Font.GothamBold; prevLbl.ZIndex=5; prevLbl.Parent=prevBox
-- Bolinha de preview de cor atual
local prevDot=Instance.new("Frame"); prevDot.Size=UDim2.new(0,30,0,30); prevDot.Position=UDim2.new(1,-40,0.5,-15)
prevDot.BackgroundColor3=S.acc; prevDot.BorderSizePixel=0; prevDot.ZIndex=6; prevDot.Parent=prevBox
Instance.new("UICorner",prevDot).CornerRadius=UDim.new(1,0)

-- Função para criar uma linha de slider RGB
local customSkin = {bg=Color3.fromRGB(8,14,8), top=Color3.fromRGB(5,20,5), acc=Color3.fromRGB(0,255,80), row=Color3.fromRGB(14,24,14), txt=Color3.fromRGB(180,255,180), on=Color3.fromRGB(0,220,70), off=Color3.fromRGB(30,60,30), rb=false}

local colorTargets = {
    {label="🖼️ Fundo",    key="bg"},
    {label="🔝 Topbar",   key="top"},
    {label="⚡ Destaque",  key="acc"},
    {label="🟫 Linhas",   key="row"},
    {label="🔤 Texto",    key="txt"},
    {label="✅ Toggle ON", key="on"},
    {label="❌ Toggle OFF",key="off"},
}

local function mkColorRow(parent, label, colorKey)
    local f=Instance.new("Frame"); f.Size=UDim2.new(1,-8,0,74); f.BackgroundColor3=Color3.fromRGB(16,16,28); f.BorderSizePixel=0; f.Parent=parent
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)

    local lbl2=Instance.new("TextLabel"); lbl2.Size=UDim2.new(0.5,0,0,22); lbl2.Position=UDim2.new(0,8,0,4)
    lbl2.BackgroundTransparency=1; lbl2.Text=label; lbl2.TextColor3=Color3.fromRGB(200,200,220)
    lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.TextScaled=true; lbl2.Font=Enum.Font.GothamBold; lbl2.ZIndex=5; lbl2.Parent=f

    -- Preview da cor atual
    local cPrev=Instance.new("Frame"); cPrev.Size=UDim2.new(0,22,0,22); cPrev.Position=UDim2.new(1,-30,0,4)
    cPrev.BackgroundColor3=customSkin[colorKey]; cPrev.BorderSizePixel=0; cPrev.ZIndex=6; cPrev.Parent=f
    Instance.new("UICorner",cPrev).CornerRadius=UDim.new(1,0)

    local curCol=customSkin[colorKey]
    local r0=math.floor(curCol.R*255); local g0=math.floor(curCol.G*255); local b0=math.floor(curCol.B*255)

    -- Campos R G B
    local function mkField(placeholder, xo, startVal)
        local bx=Instance.new("TextBox"); bx.Size=UDim2.new(0,50,0,22); bx.Position=UDim2.new(0,xo,0,46)
        bx.BackgroundColor3=Color3.fromRGB(22,22,38); bx.Text=tostring(startVal)
        bx.TextColor3=Color3.fromRGB(220,220,255); bx.TextScaled=true; bx.Font=Enum.Font.GothamBold; bx.ZIndex=5; bx.Parent=f
        Instance.new("UICorner",bx).CornerRadius=UDim.new(0,6)
        -- label R/G/B
        local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(0,14,0,22); tl.Position=UDim2.new(0,xo-16,0,46)
        tl.BackgroundTransparency=1; tl.Text=placeholder; tl.TextColor3=Color3.fromRGB(180,180,200)
        tl.TextScaled=true; tl.Font=Enum.Font.GothamBold; tl.ZIndex=5; tl.Parent=f
        return bx
    end

    local rBox = mkField("R",18,r0)
    local gBox = mkField("G",78,g0)
    local bBox = mkField("B",138,b0)

    -- Botão aplicar
    local apBtn=Instance.new("TextButton"); apBtn.Size=UDim2.new(0,80,0,22); apBtn.Position=UDim2.new(0,198,0,46)
    apBtn.BackgroundColor3=Color3.fromRGB(0,200,100); apBtn.Text="✅ Aplicar"; apBtn.TextColor3=Color3.new(1,1,1)
    apBtn.TextScaled=true; apBtn.Font=Enum.Font.GothamBold; apBtn.ZIndex=5; apBtn.Parent=f
    Instance.new("UICorner",apBtn).CornerRadius=UDim.new(0,6)

    apBtn.MouseButton1Click:Connect(function()
        local rv=math.clamp(tonumber(rBox.Text) or 0,0,255)
        local gv=math.clamp(tonumber(gBox.Text) or 0,0,255)
        local bv=math.clamp(tonumber(bBox.Text) or 0,0,255)
        local newCol=Color3.fromRGB(rv,gv,bv)
        customSkin[colorKey]=newCol
        cPrev.BackgroundColor3=newCol
        prevDot.BackgroundColor3=customSkin.acc
        -- aplica ao vivo na GUI
        applyFullSkin(customSkin)
        setStatus("🎨 "..label.." = RGB("..rv..","..gv..","..bv..")")
    end)
end

for _,ct in ipairs(colorTargets) do
    mkColorRow(pgSkins, ct.label, ct.key)
end

-- Toggle Rainbow da skin customizada
local rbRow=Instance.new("Frame"); rbRow.Size=UDim2.new(1,-8,0,44); rbRow.BackgroundColor3=Color3.fromRGB(16,16,28); rbRow.BorderSizePixel=0; rbRow.Parent=pgSkins
Instance.new("UICorner",rbRow).CornerRadius=UDim.new(0,10)
local rbLbl=Instance.new("TextLabel"); rbLbl.Size=UDim2.new(0.7,0,1,0); rbLbl.Position=UDim2.new(0,12,0,0)
rbLbl.BackgroundTransparency=1; rbLbl.Text="🌈 Borda arco-íris"; rbLbl.TextColor3=Color3.fromRGB(200,200,220)
rbLbl.TextXAlignment=Enum.TextXAlignment.Left; rbLbl.TextScaled=true; rbLbl.Font=Enum.Font.GothamBold; rbLbl.ZIndex=5; rbLbl.Parent=rbRow
local rbPill=Instance.new("Frame"); rbPill.Size=UDim2.new(0,52,0,26); rbPill.Position=UDim2.new(1,-62,0.5,-13)
rbPill.BackgroundColor3=S.off; rbPill.BorderSizePixel=0; rbPill.ZIndex=5; rbPill.Parent=rbRow
Instance.new("UICorner",rbPill).CornerRadius=UDim.new(1,0)
local rbDot=Instance.new("Frame"); rbDot.Size=UDim2.new(0,20,0,20); rbDot.Position=UDim2.new(0,3,0.5,-10)
rbDot.BackgroundColor3=Color3.new(1,1,1); rbDot.BorderSizePixel=0; rbDot.ZIndex=6; rbDot.Parent=rbPill
Instance.new("UICorner",rbDot).CornerRadius=UDim.new(1,0)
local rbTog=Instance.new("TextButton"); rbTog.Size=rbPill.Size; rbTog.Position=rbPill.Position; rbTog.BackgroundTransparency=1; rbTog.Text=""; rbTog.ZIndex=7; rbTog.Parent=rbRow
rbTog.MouseButton1Click:Connect(function()
    customSkin.rb=not customSkin.rb; applyFullSkin(customSkin)
    tw(rbPill,0.15,{BackgroundColor3=customSkin.rb and S.on or S.off})
    tw(rbDot, 0.15,{Position=customSkin.rb and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)})
    setStatus(customSkin.rb and "🌈 Rainbow ON" or "🌈 Rainbow OFF")
end)

-- ── SKIN DO PERSONAGEM (visto por todos) ──────────────────────
local charH=Instance.new("TextLabel"); charH.Size=UDim2.new(1,-8,0,26); charH.BackgroundTransparency=1
charH.Text="  👤 Skin do personagem (todos veem):"; charH.TextColor3=S.acc
charH.TextXAlignment=Enum.TextXAlignment.Left; charH.TextScaled=true; charH.Font=Enum.Font.GothamBold; charH.ZIndex=5; charH.Parent=pgSkins
regSkin("txt",charH)

-- Toggle pra ligar skin do personagem
mkRow(pgSkins,"👤","Ligar Skin do Personagem","charSkin",function()
    F.charSkin=not F.charSkin
    if F.charSkin then startCharSkin() else stopCharSkin() end; return F.charSkin
end)

-- Editor RGB do personagem
local charEdF=Instance.new("Frame"); charEdF.Size=UDim2.new(1,-8,0,76); charEdF.BackgroundColor3=Color3.fromRGB(16,16,28); charEdF.BorderSizePixel=0; charEdF.Parent=pgSkins
Instance.new("UICorner",charEdF).CornerRadius=UDim.new(0,10)
local charPrev=Instance.new("Frame"); charPrev.Size=UDim2.new(0,30,0,30); charPrev.Position=UDim2.new(1,-40,0,8)
charPrev.BackgroundColor3=Color3.fromRGB(F.charR,F.charG,F.charB); charPrev.BorderSizePixel=0; charPrev.ZIndex=6; charPrev.Parent=charEdF
Instance.new("UICorner",charPrev).CornerRadius=UDim.new(1,0)
local charTitle=Instance.new("TextLabel"); charTitle.Size=UDim2.new(0.7,0,0,22); charTitle.Position=UDim2.new(0,10,0,6)
charTitle.BackgroundTransparency=1; charTitle.Text="🎨 Cor do personagem (RGB):"; charTitle.TextColor3=Color3.fromRGB(200,200,220)
charTitle.TextXAlignment=Enum.TextXAlignment.Left; charTitle.TextScaled=true; charTitle.Font=Enum.Font.GothamBold; charTitle.ZIndex=5; charTitle.Parent=charEdF

local function mkCharField(placeholder, xo, startVal)
    local bx=Instance.new("TextBox"); bx.Size=UDim2.new(0,50,0,22); bx.Position=UDim2.new(0,xo,0,48)
    bx.BackgroundColor3=Color3.fromRGB(22,22,38); bx.Text=tostring(startVal)
    bx.TextColor3=Color3.fromRGB(220,220,255); bx.TextScaled=true; bx.Font=Enum.Font.GothamBold; bx.ZIndex=5; bx.Parent=charEdF
    Instance.new("UICorner",bx).CornerRadius=UDim.new(0,6)
    local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(0,14,0,22); tl.Position=UDim2.new(0,xo-16,0,48)
    tl.BackgroundTransparency=1; tl.Text=placeholder; tl.TextColor3=Color3.fromRGB(180,180,200)
    tl.TextScaled=true; tl.Font=Enum.Font.GothamBold; tl.ZIndex=5; tl.Parent=charEdF
    return bx
end
local crBox=mkCharField("R",18,F.charR)
local cgBox=mkCharField("G",78,F.charG)
local cbBox=mkCharField("B",138,F.charB)
local capply=Instance.new("TextButton"); capply.Size=UDim2.new(0,80,0,22); capply.Position=UDim2.new(0,198,0,48)
capply.BackgroundColor3=Color3.fromRGB(0,200,100); capply.Text="✅ Aplicar"; capply.TextColor3=Color3.new(1,1,1)
capply.TextScaled=true; capply.Font=Enum.Font.GothamBold; capply.ZIndex=5; capply.Parent=charEdF
Instance.new("UICorner",capply).CornerRadius=UDim.new(0,6)
capply.MouseButton1Click:Connect(function()
    F.charR=math.clamp(tonumber(crBox.Text) or 255,0,255)
    F.charG=math.clamp(tonumber(cgBox.Text) or 100,0,255)
    F.charB=math.clamp(tonumber(cbBox.Text) or 50, 0,255)
    charPrev.BackgroundColor3=Color3.fromRGB(F.charR,F.charG,F.charB)
    if F.charSkin then p(applyCharSkin) end
    setStatus("👤 Cor aplicada! RGB("..F.charR..","..F.charG..","..F.charB..")")
end)

-- Transparência do personagem
local transpF=Instance.new("Frame"); transpF.Size=UDim2.new(1,-8,0,56); transpF.BackgroundColor3=Color3.fromRGB(16,16,28); transpF.BorderSizePixel=0; transpF.Parent=pgSkins
Instance.new("UICorner",transpF).CornerRadius=UDim.new(0,10)
local transpL=Instance.new("TextLabel"); transpL.Size=UDim2.new(0.6,0,0,24); transpL.Position=UDim2.new(0,10,0,4)
transpL.BackgroundTransparency=1; transpL.Text="👻 Transparência (0=sólido, 1=invisível):"; transpL.TextColor3=Color3.fromRGB(200,200,220)
transpL.TextXAlignment=Enum.TextXAlignment.Left; transpL.TextScaled=true; transpL.Font=Enum.Font.GothamBold; transpL.ZIndex=5; transpL.Parent=transpF
local transpBox=Instance.new("TextBox"); transpBox.Size=UDim2.new(0,60,0,22); transpBox.Position=UDim2.new(0,10,0,30)
transpBox.BackgroundColor3=Color3.fromRGB(22,22,38); transpBox.Text="0"; transpBox.TextColor3=Color3.fromRGB(220,220,255)
transpBox.TextScaled=true; transpBox.Font=Enum.Font.GothamBold; transpBox.ZIndex=5; transpBox.Parent=transpF
Instance.new("UICorner",transpBox).CornerRadius=UDim.new(0,6)
local transpApply=Instance.new("TextButton"); transpApply.Size=UDim2.new(0,80,0,22); transpApply.Position=UDim2.new(0,78,0,30)
transpApply.BackgroundColor3=Color3.fromRGB(0,200,100); transpApply.Text="✅ Aplicar"; transpApply.TextColor3=Color3.new(1,1,1)
transpApply.TextScaled=true; transpApply.Font=Enum.Font.GothamBold; transpApply.ZIndex=5; transpApply.Parent=transpF
Instance.new("UICorner",transpApply).CornerRadius=UDim.new(0,6)
transpApply.MouseButton1Click:Connect(function()
    F.charTransp=math.clamp(tonumber(transpBox.Text) or 0, 0, 0.99)
    if F.charSkin then p(applyCharSkin) end
    setStatus("👻 Transparência: "..F.charTransp)
end)

-- ── DRAG ──────────────────────────────────────────────────────
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
    if inp.KeyCode==Enum.KeyCode.F2 then F.fly=not F.fly;     if F.fly then startFly() else stopFly() end;       setStatus((F.fly and "✅" or "❌").." Fly") end
    if inp.KeyCode==Enum.KeyCode.F3 then F.noclip=not F.noclip; if F.noclip then startNoclip() else stopNoclip() end; setStatus((F.noclip and "✅" or "❌").." Noclip") end
    if inp.KeyCode==Enum.KeyCode.F4 then F.esp=not F.esp;     if F.esp then applyESP() else clearESP() end;      setStatus((F.esp and "✅" or "❌").." ESP") end
end)

print("✅ MLG HACK v6.0 - SKIN EDITOR + ZERO ERROS")
