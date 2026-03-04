-- STEAL A BRAINROT - UNIVERSAL (QUALQUER JOGO)
-- Compatível com qualquer jogo Roblox
-- Execute no Delta ou outro executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ============================================================
-- ESTADO GLOBAL
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

local flyConn, noclipConn, espConn
local flyBody

-- ============================================================
-- UTILITÁRIOS
-- ============================================================
local function getChar()
    local char = player.Character
    if not char then return nil, nil end
    return char:FindFirstChildOfClass("Humanoid"),
           char:FindFirstChild("HumanoidRootPart")
end

-- Reconecta ao trocar de personagem
local function onCharAdded(char)
    char:WaitForChild("Humanoid")
    char:WaitForChild("HumanoidRootPart")

    -- Reaplica inf jump
    if infJumpEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if infJumpEnabled and hum.Jump then
                    hum.JumpPower = 100
                end
            end)
        end
    end
end

player.CharacterAdded:Connect(onCharAdded)
if player.Character then onCharAdded(player.Character) end

-- ============================================================
-- SPEED HACK
-- ============================================================
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

-- ============================================================
-- FLY
-- ============================================================
local function enableFly()
    local hum, root = getChar()
    if not hum or not root then return end

    hum.PlatformStand = true

    flyBody = Instance.new("BodyVelocity")
    flyBody.Velocity = Vector3.zero
    flyBody.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBody.Parent = root

    local gyro = Instance.new("BodyGyro")
    gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    gyro.P = 1e4
    gyro.Parent = root

    flyConn = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        local hum2, root2 = getChar()
        if not root2 then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

        flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        gyro.CFrame = cam.CFrame
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect() end
    if flyBody then flyBody:Destroy() end
    local hum, _ = getChar()
    if hum then hum.PlatformStand = false end
end

-- ============================================================
-- NOCLIP
-- ============================================================
local function updateNoclip()
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if not char then return end
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local char = player.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

-- ============================================================
-- GOD MODE
-- ============================================================
local function updateGod()
    local hum, _ = getChar()
    if not hum then return end
    if godEnabled then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godEnabled then hum.Health = math.huge end
        end)
    end
end

-- ============================================================
-- INF JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local hum, _ = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================================
-- ESP (Highlight universal)
-- ============================================================
local espHighlights = {}

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
            h.FillColor = Color3.fromRGB(255, 0, 0)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.FillTransparency = 0.5
            h.Parent = p.Character
            espHighlights[p.Name] = h

            p.CharacterAdded:Connect(function(char)
                if not espEnabled then return end
                local nh = Instance.new("Highlight")
                nh.FillColor = Color3.fromRGB(255, 0, 0)
                nh.OutlineColor = Color3.fromRGB(255, 255, 255)
                nh.FillTransparency = 0.5
                nh.Parent = char
                espHighlights[p.Name] = nh
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if not espEnabled then return end
    p.CharacterAdded:Connect(function(char)
        local h = Instance.new("Highlight")
        h.FillColor = Color3.fromRGB(255, 0, 0)
        h.OutlineColor = Color3.fromRGB(255, 255, 255)
        h.FillTransparency = 0.5
        h.Parent = char
        espHighlights[p.Name] = h
    end)
end)

-- ============================================================
-- CLICK TELEPORT
-- ============================================================
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
                    (workspace.CurrentCamera.CFrame.LookVector) * 500
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
-- GUI
-- ============================================================
-- Remove GUI antiga se existir
local old = game:GetService("CoreGui"):FindFirstChild("StealBrainrot")
if old then old:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealBrainrot"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 370, 0, 600)
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.new(0,0,0)
shadow.ImageTransparency = 0.4
shadow.ZIndex = -1
shadow.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 55)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🧠 Steal a Brainrot"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Botão fechar
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -45, 0, 10)
Close.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
Close.Text = "✕"
Close.TextScaled = true
Close.Font = Enum.Font.GothamBold
Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = MainFrame
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Divisor
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.9, 0, 0, 2)
Divider.Position = UDim2.new(0.05, 0, 0, 56)
Divider.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Lista de features
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollFrame.Position = UDim2.new(0, 10, 0, 65)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)
ScrollFrame.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = ScrollFrame

local function makeRow(name, isOn, onToggle, hasBox, boxDefault, onBox)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 40)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    row.BorderSizePixel = 0
    row.Parent = ScrollFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = row

    if hasBox then
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.22, 0, 0.7, 0)
        box.Position = UDim2.new(0.56, 0, 0.15, 0)
        box.BackgroundColor3 = Color3.fromRGB(38, 38, 55)
        box.Text = tostring(boxDefault)
        box.TextColor3 = Color3.new(1,1,1)
        box.TextScaled = true
        box.Font = Enum.Font.Gotham
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        box.FocusLost:Connect(function() if onBox then onBox(box.Text) end end)
    end

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0.18, 0, 0.7, 0)
    tog.Position = UDim2.new(0.8, 0, 0.15, 0)
    tog.BackgroundColor3 = isOn and Color3.fromRGB(0,220,100) or Color3.fromRGB(200,50,50)
    tog.Text = isOn and "ON" or "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.TextScaled = true
    tog.Font = Enum.Font.GothamBold
    tog.Parent = row
    Instance.new("UICorner", tog).CornerRadius = UDim.new(0, 6)

    tog.MouseButton1Click:Connect(function()
        local state = onToggle()
        tog.Text = state and "ON" or "OFF"
        tog.BackgroundColor3 = state and Color3.fromRGB(0,220,100) or Color3.fromRGB(200,50,50)
    end)

    return row
end

-- Cria as linhas
makeRow("⚡ Speed Hack", speedEnabled, function()
    speedEnabled = not speedEnabled
    return speedEnabled
end, true, speedValue, function(v)
    speedValue = tonumber(v) or 120
end)

makeRow("🦅 Fly", flyEnabled, function()
    flyEnabled = not flyEnabled
    if flyEnabled then enableFly() else disableFly() end
    return flyEnabled
end, true, flySpeed, function(v)
    flySpeed = tonumber(v) or 80
end)

makeRow("👻 Noclip", noclipEnabled, function()
    noclipEnabled = not noclipEnabled
    updateNoclip()
    return noclipEnabled
end)

makeRow("♾️ Inf Jump", infJumpEnabled, function()
    infJumpEnabled = not infJumpEnabled
    return infJumpEnabled
end)

makeRow("🛡️ God Mode", godEnabled, function()
    godEnabled = not godEnabled
    updateGod()
    return godEnabled
end)

makeRow("👁️ ESP", espEnabled, function()
    espEnabled = not espEnabled
    if espEnabled then applyESP() else clearESP() end
    return espEnabled
end)

makeRow("🖱️ Click TP", clickTPEnabled, function()
    clickTPEnabled = not clickTPEnabled
    updateClickTP()
    return clickTPEnabled
end)

-- Atualiza canvas
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ============================================================
-- ATALHOS DE TECLADO
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Insert: esconder/mostrar GUI
    if input.KeyCode == Enum.KeyCode.Insert then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end

    -- P: +20 velocidade
    if input.KeyCode == Enum.KeyCode.P then
        speedValue = speedValue + 20
        print("Velocidade: " .. speedValue)
    end

    -- Ç / Semicolon: -20 velocidade
    if input.KeyCode == Enum.KeyCode.Semicolon then
        speedValue = math.max(16, speedValue - 20)
        print("Velocidade: " .. speedValue)
    end
end)

-- ============================================================
print("✅ STEAL A BRAINROT CARREGADO!")
print("🚀 Speed já ligado automaticamente")
print("P = +20 vel | Ç = -20 vel | Insert = esconder GUI")
