-- Sistema Ultra Básico para Delta Executor
-- Usa apenas funções fundamentais do Roblox

-- Verificação simples
if _G["DELTA_ACTIVE"] then 
    return 
end
_G["DELTA_ACTIVE"] = true

print("Iniciando sistema basico...")

-- Serviços básicos
local workspace = game.Workspace
local players = game.Players
local localPlayer = players.LocalPlayer

-- Dados simples
local captured_data = {
    movements = {},
    clicks = {},
    remotes = {},
    count = 0
}

-- Sistema de captura básico
local function addData(dataType, info)
    if not captured_data[dataType] then
        captured_data[dataType] = {}
    end
    
    local entry = {
        data = info,
        time = tick()
    }
    
    table.insert(captured_data[dataType], entry)
    captured_data.count = captured_data.count + 1
    
    print("Capturado:", dataType, "-", (info.name or "item"))
end

-- Monitor de movimento básico
local last_position = nil
local function trackMovement()
    local character = localPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local pos = rootPart.Position
            
            if last_position then
                local distance = (pos - last_position).Magnitude
                if distance > 1 then
                    addData("movements", {
                        name = "move",
                        from = {last_position.X, last_position.Y, last_position.Z},
                        to = {pos.X, pos.Y, pos.Z}
                    })
                end
            end
            
            last_position = pos
        end
    end
end

-- Monitor de cliques básico
local function setupClicks()
    local mouse = localPlayer:GetMouse()
    
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target then
            addData("clicks", {
                name = "click",
                target = target.Name,
                class = target.ClassName
            })
        end
    end)
end

-- Scanner de remotes básico
local function scanRemotes()
    local found = {}
    
    local function scan(container)
        for _, obj in pairs(container:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(found, {
                    name = obj.Name,
                    type = obj.ClassName,
                    path = obj:GetFullName()
                })
            end
            
            if obj:IsA("Folder") then
                scan(obj)
            end
        end
    end
    
    scan(game.ReplicatedStorage)
    scan(workspace)
    
    for _, remote in pairs(found) do
        addData("remotes", remote)
    end
    
    print("Encontrados", #found, "remotes")
end

-- Sistema de replay básico
local replaying = false
local function replayMovements()
    if replaying then
        print("Ja replicando")
        return
    end
    
    replaying = true
    print("Iniciando replay de", #captured_data.movements, "movimentos")
    
    spawn(function()
        for i, movement in pairs(captured_data.movements) do
            if not replaying then break end
            
            local character = localPlayer.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart and movement.data.to then
                    local targetPos = Vector3.new(
                        movement.data.to[1],
                        movement.data.to[2], 
                        movement.data.to[3]
                    )
                    rootPart.CFrame = CFrame.new(targetPos)
                    print("Movendo para:", targetPos)
                end
            end
            
            wait(0.2)
        end
        
        replaying = false
        print("Replay finalizado")
    end)
end

local function stopReplay()
    replaying = false
    print("Replay parado")
end

-- Interface ultra simples
local gui = nil
local function createGUI()
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    
    -- Remove GUI antiga
    local old = playerGui:FindFirstChild("SimpleGUI")
    if old then
        old:Destroy()
    end
    
    -- Cria nova GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SimpleGUI"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 180)
    frame.Position = UDim2.new(1, -270, 0, 20)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderColor3 = Color3.new(0, 1, 0)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "Delta System"
    title.TextColor3 = Color3.new(0, 1, 0)
    title.TextSize = 16
    title.Parent = frame
    
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -10, 0, 60)
    info.Position = UDim2.new(0, 5, 0, 30)
    info.BackgroundTransparency = 1
    info.Text = "Carregando..."
    info.TextColor3 = Color3.new(1, 1, 1)
    info.TextSize = 12
    info.TextWrapped = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Parent = frame
    
    local button1 = Instance.new("TextButton")
    button1.Size = UDim2.new(1, -10, 0, 25)
    button1.Position = UDim2.new(0, 5, 0, 95)
    button1.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button1.Text = "Replay Moves"
    button1.TextColor3 = Color3.new(1, 1, 1)
    button1.TextSize = 12
    button1.Parent = frame
    
    local button2 = Instance.new("TextButton")
    button2.Size = UDim2.new(1, -10, 0, 25)
    button2.Position = UDim2.new(0, 5, 0, 125)
    button2.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button2.Text = "Stop Replay"
    button2.TextColor3 = Color3.new(1, 1, 1)
    button2.TextSize = 12
    button2.Parent = frame
    
    local button3 = Instance.new("TextButton")
    button3.Size = UDim2.new(1, -10, 0, 25)
    button3.Position = UDim2.new(0, 5, 0, 155)
    button3.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button3.Text = "Scan Remotes"
    button3.TextColor3 = Color3.new(1, 1, 1)
    button3.TextSize = 12
    button3.Parent = frame
    
    -- Conecta botões
    button1.MouseButton1Click:Connect(replayMovements)
    button2.MouseButton1Click:Connect(stopReplay)
    button3.MouseButton1Click:Connect(scanRemotes)
    
    gui = screenGui
    
    -- Atualiza info
    spawn(function()
        while gui and gui.Parent do
            info.Text = string.format(
                "Total: %d\nMovimentos: %d\nCliques: %d\nRemotes: %d",
                captured_data.count,
                #captured_data.movements,
                #captured_data.clicks,
                #captured_data.remotes
            )
            wait(1)
        end
    end)
end

-- Sistema de limpeza
local function cleanup()
    _G["DELTA_ACTIVE"] = false
    replaying = false
    
    if gui then
        gui:Destroy()
    end
    
    print("Sistema finalizado")
end

-- Inicialização ultra básica
local function initialize()
    print("=== DELTA SYSTEM BASICO ===")
    
    wait(0.5)
    setupClicks()
    
    wait(0.5) 
    createGUI()
    
    -- Loop de movimento
    spawn(function()
        while _G["DELTA_ACTIVE"] do
            trackMovement()
            wait(0.3)
        end
    end)
    
    print("Sistema inicializado")
    print("GUI criada no canto superior direito")
end

-- Conecta cleanup
game:BindToClose(cleanup)

-- Inicia
spawn(function()
    initialize()
end)

-- Comandos manuais
_G.replayMoves = replayMovements
_G.stopReplay = stopReplay
_G.scanRemotes = scanRemotes
_G.showData = function()
    print("=== DADOS CAPTURADOS ===")
    print("Total:", captured_data.count)
    print("Movimentos:", #captured_data.movements)
    print("Cliques:", #captured_data.clicks) 
    print("Remotes:", #captured_data.remotes)
end

print("Sistema carregado!")
print("Comandos: _G.replayMoves(), _G.stopReplay(), _G.scanRemotes(), _G.showData()")
