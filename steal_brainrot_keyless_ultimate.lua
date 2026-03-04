-- ╔══════════════════════════════════════════╗
-- ║         MLG HACK - UNIVERSAL v2.0        ║
-- ║      GUI Ultra Premium | Delta Ready     ║
-- ╚══════════════════════════════════════════╝

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local player         = Players.LocalPlayer

-- ============================================================
-- ESTADO
-- ============================================================
local speedEnabled   = true
local speedValue     = 120
local flyEnabled     = false
local flySpeed       = 80
local noclipEnabled  = false
local infJumpEnabled = false
local godEnabled     = false
local espEnabled     = false
local clickTPEnabled = false
local guiVisible     = true
local currentTab     = "movement"

local flyConn, noclipConn, flyBody, flyGyro
local espHighlights  = {}

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function getChar()
    local char = player.Character
    if not char then return nil, nil end
    return char:FindFirstChildOfClass("Humanoid"),
           char:FindFirstChild("HumanoidRootPart")
end

local function lerp(a, b, t) return a + (b - a) * t end

local function onCharAdded(char)
    char:WaitForChild("Humanoid")
    char:WaitForChild("HumanoidRootPart")
    if godEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end
    end
end
player.CharacterAdded:Connect(onCharAdded)
if player.Character then onCharAdded(player.Character) end

-- ============================================================
-- FEATURES
-- ============================================================

-- SPEED
RunService.Heartbeat:Connect(function()
    if not speedEnabled then return end
    local hum, root = getChar()
    if hum and root then
        hum.WalkSpeed = speedValue
        if hum.MoveDirection.Magnitude > 0 then
            root.Velocity = Vector3.new(
                hum.MoveDirection.X * speedValue,
                root.Velocity.Y,
                hum.MoveDirection.Z * speedValue
            )
        end
    end
end)

-- FLY
local function enableFly()
    local hum, root = getChar()
    if not hum or not root then return end
    hum.PlatformStand = true
    flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity  = Vector3.zero
    flyBody.MaxForce  = Vector3.new(1e5,1e5,1e5)
    flyBody.Parent    = root
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyGyro.P         = 1e4
    flyGyro.Parent    = root
    flyConn = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local _, r = getChar()
        if not r then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        flyGyro.CFrame   = cam.CFrame
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect() end
    if flyBody  then flyBody:Destroy()   end
    if flyGyro  then flyGyro:Destroy()   end
    local hum, _ = getChar()
    if hum then hum.PlatformStand = false end
end

-- NOCLIP
local function updateNoclip()
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

-- GOD MODE
local function updateGod()
    local hum, _ = getChar()
    if not hum then return end
    if godEnabled then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godEnabled then hum.Health = math.huge end
        end)
    end
end

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum, _ = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ESP
local function clearESP()
    for _, h in pairs(espHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    espHighlights = {}
end

local function applyESP()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = Instance.new("Highlight")
            h.FillColor         = Color3.fromRGB(255, 50, 50)
            h.OutlineColor      = Color3.fromRGB(255, 200, 0)
            h.FillTransparency  = 0.45
            h.Parent            = p.Character
            espHighlights[p.Name] = h
            p.CharacterAdded:Connect(function(char)
                if not espEnabled then return end
                local nh = Instance.new("Highlight")
                nh.FillColor        = Color3.fromRGB(255, 50, 50)
                nh.OutlineColor     = Color3.fromRGB(255, 200, 0)
                nh.FillTransparency = 0.45
                nh.Parent           = char
                espHighlights[p.Name] = nh
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if not espEnabled then return end
    p.CharacterAdded:Connect(function(char)
        local h = Instance.new("Highlight")
        h.FillColor         = Color3.fromRGB(255, 50, 50)
        h.OutlineColor      = Color3.fromRGB(255, 200, 0)
        h.FillTransparency  = 0.45
        h.Parent            = char
        espHighlights[p.Name] = h
    end)
end)

-- CLICK TP
local clickConn
local function updateClickTP()
    if clickTPEnabled then
        clickConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local _, root = getChar()
                if not root then return end
                local ray = workspace:Raycast(
                    workspace.CurrentCamera.CFrame.Position,
                    workspace.CurrentCamera.CFrame.LookVector * 500
                )
                if ray then
                    root.CFrame = CFrame.new(ray.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
    else
        if clickConn then clickConn:Disconnect() end
    end
end

-- ============================================================
-- GUI ULTRA PREMIUM
-- ============================================================
local old = game:GetService("CoreGui"):FindFirstChild("MLGHack")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name          = "MLGHack"
ScreenGui.ResetOnSpawn  = false
ScreenGui.ZIndexBehavior= Enum.ZIndexBehavior.Sibling
ScreenGui.Parent        = game:GetService("CoreGui")

-- ── JANELA PRINCIPAL ──────────────────────────────────────────
local Main = Instance.new("Frame")
Main.Size              = UDim2.new(0, 420, 0, 560)
Main.Position          = UDim2.new(0.5, -210, 0.5, -280)
Main.BackgroundColor3  = Color3.fromRGB(10, 10, 16)
Main.BorderSizePixel   = 0
Main.ClipsDescendants  = true
Main.Parent            = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

-- Borda neon animada (via UIStroke)
local stroke = Instance.new("UIStroke")
stroke.Color     = Color3.fromRGB(0, 255, 120)
stroke.Thickness = 2
stroke.Parent    = Main

-- Anima borda
local strokeHue = 0
RunService.Heartbeat:Connect(function()
    strokeHue = (strokeHue + 0.3) % 360
    stroke.Color = Color3.fromHSV(strokeHue/360, 1, 1)
end)

-- Fundo grade/scanlines
local Grid = Instance.new("Frame")
Grid.Size             = UDim2.new(1,0,1,0)
Grid.BackgroundColor3 = Color3.fromRGB(0,0,0)
Grid.BackgroundTransparency = 0.85
Grid.BorderSizePixel  = 0
Grid.ZIndex           = 0
Grid.Parent           = Main

-- ── TOPBAR ───────────────────────────────────────────────────
local TopBar = Instance.new("Frame")
TopBar.Size            = UDim2.new(1,0,0,54)
TopBar.BackgroundColor3= Color3.fromRGB(8, 8, 14)
TopBar.BorderSizePixel = 0
TopBar.ZIndex          = 5
TopBar.Parent          = Main

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,180,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180,0,255))
}
TopGrad.Rotation = 90
TopGrad.Parent   = TopBar

-- Logo / Título
local Logo = Instance.new("TextLabel")
Logo.Size               = UDim2.new(0, 200, 1, 0)
Logo.Position           = UDim2.new(0, 14, 0, 0)
Logo.BackgroundTransparency = 1
Logo.Text               = "⚡ MLG HACK"
Logo.TextColor3         = Color3.fromRGB(255, 255, 255)
Logo.TextScaled         = true
Logo.Font               = Enum.Font.GothamBold
Logo.ZIndex             = 6
Logo.Parent             = TopBar

-- Sub-título versão
local Ver = Instance.new("TextLabel")
Ver.Size                = UDim2.new(0, 120, 0, 16)
Ver.Position            = UDim2.new(0, 14, 1, -18)
Ver.BackgroundTransparency = 1
Ver.Text                = "v2.0  |  UNIVERSAL"
Ver.TextColor3          = Color3.fromRGB(200, 255, 220)
Ver.TextScaled          = true
Ver.Font                = Enum.Font.GothamSemibold
Ver.ZIndex              = 6
Ver.Parent              = TopBar

-- Botões minimize / close
local function makeTopBtn(txt, color, xOff)
    local b = Instance.new("TextButton")
    b.Size              = UDim2.new(0,30,0,30)
    b.Position          = UDim2.new(1, xOff, 0.5, -15)
    b.BackgroundColor3  = color
    b.Text              = txt
    b.TextColor3        = Color3.new(1,1,1)
    b.TextScaled        = true
    b.Font              = Enum.Font.GothamBold
    b.ZIndex            = 7
    b.Parent            = TopBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local CloseBtn = makeTopBtn("✕", Color3.fromRGB(255,55,55), -10)
local MinBtn   = makeTopBtn("−", Color3.fromRGB(60,60,80),  -46)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    -- Anima
    local target = guiVisible and UDim2.new(0,420,0,560) or UDim2.new(0,420,0,54)
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = target}):Play()
end)

-- ── ABAS / TABS ──────────────────────────────────────────────
local TabBar = Instance.new("Frame")
TabBar.Size            = UDim2.new(1, 0, 0, 40)
TabBar.Position        = UDim2.new(0, 0, 0, 54)
TabBar.BackgroundColor3= Color3.fromRGB(14, 14, 22)
TabBar.BorderSizePixel = 0
TabBar.ZIndex          = 5
TabBar.Parent          = Main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent  = TabBar

local tabPages = {}
local tabBtns  = {}

local function makeTab(id, icon, label)
    local btn = Instance.new("TextButton")
    btn.Size              = UDim2.new(0, 100, 0, 30)
    btn.BackgroundColor3  = Color3.fromRGB(22,22,35)
    btn.Text              = icon .. "  " .. label
    btn.TextColor3        = Color3.fromRGB(140,140,170)
    btn.TextScaled        = true
    btn.Font              = Enum.Font.GothamSemibold
    btn.ZIndex            = 6
    btn.Parent            = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local page = Instance.new("ScrollingFrame")
    page.Size                = UDim2.new(1,-20, 1, -110)
    page.Position            = UDim2.new(0, 10, 0, 100)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness  = 3
    page.ScrollBarImageColor3= Color3.fromRGB(0,255,120)
    page.Visible             = false
    page.ZIndex              = 4
    page.Parent              = Main

    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0, 8)
    pl.Parent  = page
    pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,pl.AbsoluteContentSize.Y+10)
    end)

    tabPages[id]  = page
    tabBtns[id]   = btn

    btn.MouseButton1Click:Connect(function()
        -- Esconde tudo
        for k, p in pairs(tabPages) do
            p.Visible = false
            tabBtns[k].BackgroundColor3 = Color3.fromRGB(22,22,35)
            tabBtns[k].TextColor3       = Color3.fromRGB(140,140,170)
        end
        -- Mostra selecionado
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(0,200,100)
        btn.TextColor3       = Color3.new(1,1,1)
        currentTab = id
    end)

    return page
end

local movPage  = makeTab("movement", "🏃", "Move")
local combPage = makeTab("combat",   "⚔️",  "Combat")
local visPage  = makeTab("visual",   "👁️",  "Visual")

-- Ativa aba padrão
tabPages["movement"].Visible       = true
tabBtns["movement"].BackgroundColor3 = Color3.fromRGB(0,200,100)
tabBtns["movement"].TextColor3       = Color3.new(1,1,1)

-- ── STATUS BAR (fundo) ────────────────────────────────────────
local StatusBar = Instance.new("Frame")
StatusBar.Size            = UDim2.new(1,0,0,30)
StatusBar.Position        = UDim2.new(0,0,1,-30)
StatusBar.BackgroundColor3= Color3.fromRGB(8,8,14)
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex          = 5
StatusBar.Parent          = Main

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size               = UDim2.new(1,-10,1,0)
StatusLbl.Position           = UDim2.new(0,10,0,0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text               = "✅ Pronto  |  Insert = esconder  |  P/Ç = velocidade"
StatusLbl.TextColor3         = Color3.fromRGB(0,255,120)
StatusLbl.TextScaled         = true
StatusLbl.Font               = Enum.Font.Gotham
StatusLbl.TextXAlignment     = Enum.TextXAlignment.Left
StatusLbl.ZIndex             = 6
StatusLbl.Parent             = StatusBar

-- ── COMPONENTES DE LINHA ──────────────────────────────────────
local function glow(frame, color)
    local s = Instance.new("UIStroke")
    s.Color     = color or Color3.fromRGB(0,255,120)
    s.Thickness = 1.5
    s.Transparency = 0.5
    s.Parent    = frame
end

local function makeToggleRow(parent, icon, name, isOn, onToggle, hasSlider, sliderVal, onSlider)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -8, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(16,16,26)
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
    glow(row, Color3.fromRGB(40,40,70))

    -- Ícone decorativo
    local ic = Instance.new("TextLabel")
    ic.Size               = UDim2.new(0,36,0,36)
    ic.Position           = UDim2.new(0,8,0.5,-18)
    ic.BackgroundColor3   = Color3.fromRGB(22,22,38)
    ic.Text               = icon
    ic.TextScaled         = true
    ic.Font               = Enum.Font.GothamBold
    ic.TextColor3         = Color3.new(1,1,1)
    ic.ZIndex             = 5
    ic.Parent             = row
    Instance.new("UICorner", ic).CornerRadius = UDim.new(0,8)

    -- Nome
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(0.45,0,0,20)
    lbl.Position          = UDim2.new(0,52,0,6)
    lbl.BackgroundTransparency = 1
    lbl.Text              = name
    lbl.TextColor3        = Color3.new(1,1,1)
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.TextScaled        = true
    lbl.Font              = Enum.Font.GothamBold
    lbl.ZIndex            = 5
    lbl.Parent            = row

    -- Valor (se tiver slider)
    local valLbl
    if hasSlider then
        valLbl = Instance.new("TextLabel")
        valLbl.Size             = UDim2.new(0.45,0,0,16)
        valLbl.Position         = UDim2.new(0,52,0,28)
        valLbl.BackgroundTransparency = 1
        valLbl.Text             = tostring(sliderVal)
        valLbl.TextColor3       = Color3.fromRGB(0,255,120)
        valLbl.TextXAlignment   = Enum.TextXAlignment.Left
        valLbl.TextScaled       = true
        valLbl.Font             = Enum.Font.Gotham
        valLbl.ZIndex           = 5
        valLbl.Parent           = row
    end

    -- Toggle pill
    local pillBg = Instance.new("Frame")
    pillBg.Size             = UDim2.new(0,54,0,28)
    pillBg.Position         = UDim2.new(1,-64,0.5,-14)
    pillBg.BackgroundColor3 = isOn and Color3.fromRGB(0,200,100) or Color3.fromRGB(50,50,70)
    pillBg.BorderSizePixel  = 0
    pillBg.ZIndex           = 5
    pillBg.Parent           = row
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1,0)

    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0,22,0,22)
    pill.Position        = isOn and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)
    pill.BackgroundColor3= Color3.new(1,1,1)
    pill.BorderSizePixel = 0
    pill.ZIndex          = 6
    pill.Parent          = pillBg
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

    -- Caixa de valor numérico (se slider)
    if hasSlider then
        local box = Instance.new("TextBox")
        box.Size             = UDim2.new(0,54,0,24)
        box.Position         = UDim2.new(1,-124,0.5,-12)
        box.BackgroundColor3 = Color3.fromRGB(22,22,38)
        box.Text             = tostring(sliderVal)
        box.TextColor3       = Color3.fromRGB(0,255,180)
        box.TextScaled       = true
        box.Font             = Enum.Font.GothamBold
        box.ZIndex           = 5
        box.Parent           = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n and onSlider then
                onSlider(n)
                if valLbl then valLbl.Text = tostring(n) end
            end
        end)
    end

    -- Clique no toggle
    local tog = Instance.new("TextButton")
    tog.Size             = UDim2.new(0,54,0,28)
    tog.Position         = pillBg.Position
    tog.BackgroundTransparency = 1
    tog.Text             = ""
    tog.ZIndex           = 7
    tog.Parent           = row

    tog.MouseButton1Click:Connect(function()
        local state = onToggle()
        -- Anima pill
        TweenService:Create(pillBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0,200,100) or Color3.fromRGB(50,50,70)
        }):Play()
        TweenService:Create(pill, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11)
        }):Play()
    end)

    -- Hover effect
    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(22,22,36)
        }):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(16,16,26)
        }):Play()
    end)

    return row
end

-- ── ABA MOVIMENTO ─────────────────────────────────────────────
makeToggleRow(movPage, "⚡", "Speed Hack", speedEnabled,
    function()
        speedEnabled = not speedEnabled
        return speedEnabled
    end, true, speedValue,
    function(v) speedValue = math.max(16, v) end
)

makeToggleRow(movPage, "🦅", "Fly Mode", flyEnabled,
    function()
        flyEnabled = not flyEnabled
        if flyEnabled then enableFly() else disableFly() end
        return flyEnabled
    end, true, flySpeed,
    function(v) flySpeed = math.max(10, v) end
)

makeToggleRow(movPage, "👻", "Noclip", noclipEnabled,
    function()
        noclipEnabled = not noclipEnabled
        updateNoclip()
        return noclipEnabled
    end
)

makeToggleRow(movPage, "♾️", "Infinite Jump", infJumpEnabled,
    function()
        infJumpEnabled = not infJumpEnabled
        return infJumpEnabled
    end
)

makeToggleRow(movPage, "🖱️", "Click Teleport", clickTPEnabled,
    function()
        clickTPEnabled = not clickTPEnabled
        updateClickTP()
        return clickTPEnabled
    end
)

-- ── ABA COMBAT ────────────────────────────────────────────────
makeToggleRow(combPage, "🛡️", "God Mode", godEnabled,
    function()
        godEnabled = not godEnabled
        updateGod()
        return godEnabled
    end
)

makeToggleRow(combPage, "💥", "Kill Aura (WIP)", false,
    function()
        StatusLbl.Text = "⚠️ Kill Aura em breve!"
        return false
    end
)

makeToggleRow(combPage, "🎯", "Auto Aim (WIP)", false,
    function()
        StatusLbl.Text = "⚠️ Auto Aim em breve!"
        return false
    end
)

-- ── ABA VISUAL ────────────────────────────────────────────────
makeToggleRow(visPage, "👁️", "ESP Players", espEnabled,
    function()
        espEnabled = not espEnabled
        if espEnabled then applyESP() else clearESP() end
        return espEnabled
    end
)

makeToggleRow(visPage, "🌈", "Rainbow Char", false,
    function()
        StatusLbl.Text = "⚠️ Rainbow em breve!"
        return false
    end
)

makeToggleRow(visPage, "🔦", "Fullbright", false,
    function()
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 5
        lighting.ClockTime  = 14
        StatusLbl.Text = "✅ Fullbright ativado!"
        return true
    end
)

-- ── DRAG ──────────────────────────────────────────────────────
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = i.Position
        startPos  = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ── ANIMAÇÃO DE ENTRADA ───────────────────────────────────────
Main.Size = UDim2.new(0,0,0,0)
Main.Position = UDim2.new(0.5,0,0.5,0)
TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size     = UDim2.new(0,420,0,560),
    Position = UDim2.new(0.5,-210,0.5,-280)
}):Play()

-- ── ATALHOS ───────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        if guiVisible then
            Main.Visible = true
            TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0,420,0,560)
            }):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
            task.delay(0.25, function() Main.Visible = false end)
        end
    end
    if input.KeyCode == Enum.KeyCode.P then
        speedValue = speedValue + 20
        StatusLbl.Text = "⚡ Velocidade: " .. speedValue
    end
    if input.KeyCode == Enum.KeyCode.Semicolon then
        speedValue = math.max(16, speedValue - 20)
        StatusLbl.Text = "⚡ Velocidade: " .. speedValue
    end
end)

-- ── FIM ───────────────────────────────────────────────────────
print("╔═══════════════════════════════╗")
print("║      ⚡ MLG HACK v2.0 ⚡       ║")
print("║   Universal - Delta Ready    ║")
print("╚═══════════════════════════════╝")
print("Insert = esconder | P = +vel | Ç = -vel")
