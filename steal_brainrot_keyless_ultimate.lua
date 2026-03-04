-- UNIVERSAL HACK TURBO v2 (Delta Executor) - P/Ç + MUITAS FEATURES
-- Cole tudo e execute

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local speedEnabled = false
local speedValue = 120
local flyEnabled = false
local flySpeed = 80
local noclipEnabled = false
local infJumpEnabled = false
local godEnabled = false
local espEnabled = false
local clickTPEnabled = false
local jumpPowerValue = 50

local character, humanoid, root
local speedConn, flyConn, noclipConn
local bv, bg
local keys = {}
local espConnections = {}

local function updateChar()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")
end
updateChar()
player.CharacterAdded:Connect(updateChar)

-- ==================== GUI LINDA ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalHackV2"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 580)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "UNIVERSAL HACK TURBO"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Draggable + Close
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(i) 
    if i.UserInputType == Enum.UserInputType.MouseButton1 then 
        dragging = true; dragStart = i.Position; startPos = MainFrame.Position 
    end 
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35); Close.Position = UDim2.new(1,-40,0,10)
Close.BackgroundColor3 = Color3.fromRGB(255,60,60); Close.Text = "X"; Close.TextScaled = true
Close.Font = Enum.Font.GothamBold; Close.TextColor3 = Color3.new(1,1,1)
Close.Parent = MainFrame
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Função rápida pra criar toggle
local function createToggle(name, yPos, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65,0,0,35); lbl.Position = UDim2.new(0.05,0,yPos,0)
    lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextScaled = true; lbl.Font = Enum.Font.GothamSemibold
    lbl.Parent = MainFrame

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0,90,0,35); tog.Position = UDim2.new(0.72,0,yPos,0)
    tog.BackgroundColor3 = Color3.fromRGB(255,60,60); tog.Text = "OFF"; tog.TextColor3 = Color3.new(1,1,1)
    tog.TextScaled = true; tog.Font = Enum.Font.GothamBold
    tog.Parent = MainFrame
    Instance.new("UICorner", tog)

    tog.MouseButton1Click:Connect(function()
        local state = tog.Text == "OFF"
        tog.Text = state and "ON" or "OFF"
        tog.BackgroundColor3 = state and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,60,60)
        callback(state)
    end)
    return tog
end

-- ==================== FEATURES ====================

-- SPEED + HOTKEYS P / Ç
local speedTog = createToggle("Speed Hack", 70, function(state)
    speedEnabled = state
    if state then
        speedConn = RunService.Heartbeat:Connect(function()
            if root and humanoid and humanoid.MoveDirection.Magnitude > 0 then
                root.Velocity = Vector3.new(humanoid.MoveDirection.X * speedValue, root.Velocity.Y, humanoid.MoveDirection.Z * speedValue)
            end
        end)
    else
        if speedConn then speedConn:Disconnect() end
    end
end)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0.2,0,0,35); speedBox.Position = UDim2.new(0.05,0,120,0)
speedBox.BackgroundColor3 = Color3.fromRGB(35,35,45); speedBox.Text = tostring(speedValue)
speedBox.TextColor3 = Color3.new(1,1,1); speedBox.TextScaled = true; speedBox.Font = Enum.Font.Gotham
speedBox.Parent = MainFrame
Instance.new("UICorner", speedBox)
speedBox.FocusLost:Connect(function() speedValue = tonumber(speedBox.Text) or 120 end)

-- FLY
createToggle("Fly", 165, function(state)
    flyEnabled = state
    if state then
        bv = Instance.new("BodyVelocity", root); bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bg = Instance.new("BodyGyro", root); bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.P = 12500
        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            if keys[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end
            if keys[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end
            if keys[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end
            if keys[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end
            if keys[Enum.KeyCode.Space] then dir += Vector3.new(0,1,0) end
            if keys[Enum.KeyCode.LeftControl] then dir -= Vector3.new(0,1,0) end
            bv.Velocity = dir.Unit * flySpeed
            bg.CFrame = cam.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

local flyBox = Instance.new("TextBox")
flyBox.Size = UDim2.new(0.2,0,0,35); flyBox.Position = UDim2.new(0.75,0,165,0)
flyBox.BackgroundColor3 = Color3.fromRGB(35,35,45); flyBox.Text = tostring(flySpeed)
flyBox.TextColor3 = Color3.new(1,1,1); flyBox.TextScaled = true
flyBox.Parent = MainFrame; Instance.new("UICorner", flyBox)
flyBox.FocusLost:Connect(function() flySpeed = tonumber(flyBox.Text) or 80 end)

-- Noclip, Inf Jump, Godmode, ESP, Click TP
createToggle("Noclip", 220, function(s) 
    noclipEnabled = s
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            for _,v in pairs(character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
        end)
    else if noclipConn then noclipConn:Disconnect() end end
end)

createToggle("Infinite Jump", 265, function(s) infJumpEnabled = s end)

createToggle("Godmode", 310, function(s) 
    godEnabled = s
    if s then
        spawn(function()
            while godEnabled and humanoid do
                humanoid.MaxHealth = 1e5; humanoid.Health = 1e5
                task.wait(0.3)
            end
        end)
    end
end)

createToggle("ESP (Nomes)", 355, function(s)
    espEnabled = s
    if s then
        for _,p in Players:GetPlayers() do if p ~= player then createESP(p) end end
        Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end end)
    else
        for _,conn in espConnections do conn:Disconnect() end
        for _,p in Players:GetPlayers() do if p.Character then for _,g in p.Character:GetChildren() do if g:IsA("BillboardGui") then g:Destroy() end end end end
    end
end)

createToggle("Click TP (Ctrl + Clique)", 400, function(s) clickTPEnabled = s end)

-- JumpPower
local jpLabel = Instance.new("TextLabel")
jpLabel.Size = UDim2.new(0.6,0,0,35); jpLabel.Position = UDim2.new(0.05,0,445,0)
jpLabel.BackgroundTransparency = 1; jpLabel.Text = "Jump Power"; jpLabel.TextColor3 = Color3.new(1,1,1)
jpLabel.TextXAlignment = Enum.TextXAlignment.Left; jpLabel.TextScaled = true; jpLabel.Font = Enum.Font.GothamSemibold
jpLabel.Parent = MainFrame

local jpBox = Instance.new("TextBox")
jpBox.Size = UDim2.new(0.3,0,0,35); jpBox.Position = UDim2.new(0.65,0,445,0)
jpBox.BackgroundColor3 = Color3.fromRGB(35,35,45); jpBox.Text = "50"
jpBox.TextColor3 = Color3.new(1,1,1); jpBox.TextScaled = true; jpBox.Font = Enum.Font.Gotham
jpBox.Parent = MainFrame; Instance.new("UICorner", jpBox)
jpBox.FocusLost:Connect(function()
    jumpPowerValue = tonumber(jpBox.Text) or 50
    if humanoid then humanoid.JumpPower = jumpPowerValue end
end)

-- ==================== HOTKEYS ====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    keys[input.KeyCode] = true

    -- P e Ç (Semicolon = tecla Ç no teclado BR)
    if input.KeyCode == Enum.KeyCode.P then
        speedValue = speedValue + 20
        speedBox.Text = tostring(speedValue)
        print("🚀 Velocidade +20 → "..speedValue)
    end
    if input.KeyCode == Enum.KeyCode.Semicolon then  -- Ç
        speedValue = math.max(16, speedValue - 20)
        speedBox.Text = tostring(speedValue)
        print("🐢 Velocidade -20 → "..speedValue)
    end

    -- Insert esconde/mostra GUI
    if input.KeyCode == Enum.KeyCode.Insert then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

UserInputService.InputEnded:Connect(function(i) keys[i.KeyCode] = false end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Click TP
UserInputService.InputBegan:Connect(function(i)
    if clickTPEnabled and i.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = player:GetMouse()
        local ray = workspace:Raycast(mouse.Hit.Position + Vector3.new(0,50,0), Vector3.new(0,-100,0))
        if ray and root then root.CFrame = CFrame.new(ray.Position + Vector3.new(0,4,0)) end
    end
end)

-- Função simples de ESP
function createESP(plr)
    if plr == player then return end
    local conn = plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        local head = char:FindFirstChild("Head")
        if head then
            local bg = Instance.new("BillboardGui")
            bg.Adornee = head; bg.Size = UDim2.new(0, 200, 0, 50); bg.StudsOffset = Vector3.new(0, 2.5, 0)
            bg.AlwaysOnTop = true; bg.Parent = head

            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1
            txt.Text = plr.Name; txt.TextColor3 = Color3.fromRGB(0,255,100)
            txt.TextScaled = true; txt.Font = Enum.Font.GothamBold; txt.Parent = bg
        end
    end)
    table.insert(espConnections, conn)
    if plr.Character then conn:Fire() end  -- se já spawnou
end

print("✅ UNIVERSAL HACK TURBO CARREGADO!")
print("P = +20 velocidade | Ç = -20 velocidade")
print("Insert = esconder GUI | Ctrl + Clique Esquerdo = Teleport")
print("Bora dominar TUDO irmão 🔥")

