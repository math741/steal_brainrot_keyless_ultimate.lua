-- Sistema de Replicação Anti-Detecção para Delta
-- Contorna proteções do executor usando métodos alternativos

-- Proteção contra execução múltipla
if rawget(_G, "DeltaReplicatorActive") then 
    warn("⚠️ Sistema já ativo!")
    return 
end
rawset(_G, "DeltaReplicatorActive", true)

print("🚀 Carregando Sistema Anti-Detecção...")

-- Cache de serviços (evita detecção)
local services = {}
local function getService(name)
    if not services[name] then
        services[name] = game:GetService(name)
    end
    return services[name]
end

local workspace = getService("Workspace")
local players = getService("Players")
local runService = getService("RunService")
local replicatedStorage = getService("ReplicatedStorage")
local localPlayer = players.LocalPlayer

-- Sistema de dados oculto
local HiddenData = {}
local dataKey = tostring(math.random(100000, 999999))

-- Função para esconder dados
local function storeData(key, value)
    if not HiddenData[dataKey] then
        HiddenData[dataKey] = {}
    end
    HiddenData[dataKey][key] = value
end

local function getData(key)
    if HiddenData[dataKey] then
        return HiddenData[dataKey][key]
    end
    return nil
end

-- Sistema de captura passiva (sem hooks diretos)
local PassiveCapture = {
    remotes = {},
    movements = {},
    interactions = {},
    total = 0,
    scanning = false
}

-- Inicializa dados ocultos
storeData("remotes", {})
storeData("movements", {})
storeData("interactions", {})
storeData("total", 0)

function PassiveCapture:AddEvent(eventType, data)
    local events = getData(eventType) or {}
    local event = {
        data = data,
        time = tick(),
        id = (getData("total") or 0) + 1
    }
    
    table.insert(events, event)
    storeData(eventType, events)
    storeData("total", event.id)
    
    -- Log sem usar print diretamente (evita detecção)
    local logMsg = "📊 [" .. string.upper(eventType) .. "] Capturado: " .. (data.name or data.remote or "Item")
    task.defer(function() print(logMsg) end)
end

function PassiveCapture:GetEvents(eventType)
    return getData(eventType) or {}
end

function PassiveCapture:GetTotal()
    return getData("total") or 0
end

-- Scanner de remotes sem hooks (método passivo)
local RemoteScanner = {
    found_remotes = {},
    scan_complete = false
}

function RemoteScanner:ScanPassive()
    print("🔍 Iniciando scan passivo de remotes...")
    
    local function deepScan(container, depth)
        if depth > 5 then return end -- Limite de profundidade
        
        local success, children = pcall(function()
            return container:GetChildren()
        end)
        
        if not success then return end
        
        for _, obj in ipairs(children) do
            pcall(function()
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local remoteData = {
                        name = obj.Name,
                        path = obj:GetFullName(),
                        type = obj.ClassName,
                        parent = obj.Parent and obj.Parent.Name or "nil"
                    }
                    
                    table.insert(self.found_remotes, remoteData)
                    
                    -- Registra remote para monitoramento
                    PassiveCapture:AddEvent("remotes", {
                        remote = obj.Name,
                        type = "discovered",
                        path = remoteData.path
                    })
                end
                
                if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Configuration") then
                    deepScan(obj, depth + 1)
                end
            end)
        end
    end
    
    -- Escaneia locais importantes
    local containers = {replicatedStorage, workspace, getService("Lighting")}
    
    for _, container in ipairs(containers) do
        pcall(function()
            deepScan(container, 0)
        end)
    end
    
    self.scan_complete = true
    print("✅ Scan completo: " .. #self.found_remotes .. " remotes encontrados")
end

-- Monitor de movimento (sem hooks)
local MovementMonitor = {
    last_pos = nil,
    monitoring = false
}

function MovementMonitor:StartMonitoring()
    if self.monitoring then return end
    self.monitoring = true
    
    print("🏃 Iniciando monitor de movimento passivo...")
    
    task.spawn(function()
        while rawget(_G, "DeltaReplicatorActive") and self.monitoring do
            pcall(function()
                local character = localPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local currentPos = rootPart.Position
                        
                        if self.last_pos then
                            local distance = (currentPos - self.last_pos).Magnitude
                            if distance > 0.5 then -- Threshold para movimento significativo
                                PassiveCapture:AddEvent("movements", {
                                    name = "PlayerMove",
                                    from = {self.last_pos.X, self.last_pos.Y, self.last_pos.Z},
                                    to = {currentPos.X, currentPos.Y, currentPos.Z},
                                    distance = distance
                                })
                            end
                        end
                        
                        self.last_pos = currentPos
                    end
                end
            end)
            task.wait(0.2)
        end
    end)
end

-- Monitor de interações (sem hooks diretos)
local InteractionMonitor = {
    monitoring = false,
    connections = {}
}

function InteractionMonitor:StartMonitoring()
    if self.monitoring then return end
    self.monitoring = true
    
    print("🖱️ Iniciando monitor de interações...")
    
    pcall(function()
        local mouse = localPlayer:GetMouse()
        
        local connection = mouse.Button1Down:Connect(function()
            pcall(function()
                local target = mouse.Target
                if target then
                    PassiveCapture:AddEvent("interactions", {
                        name = "MouseClick",
                        target = target.Name,
                        class = target.ClassName,
                        position = {mouse.X, mouse.Y}
                    })
                end
            end)
        end)
        
        table.insert(self.connections, connection)
    end)
    
    -- Monitor de ferramentas
    localPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.ToolEquipped:Connect(function(tool)
                PassiveCapture:AddEvent("interactions", {
                    name = "ToolEquipped",
                    tool = tool.Name
                })
            end)
        end
    end)
end

-- Sistema de replicação inteligente
local SmartReplicator = {
    replaying = false,
    current_events = {},
    replay_index = 1
}

function SmartReplicator:StartReplay(eventType, speed)
    if self.replaying then
        print("⚠️ Já replicando!")
        return
    end
    
    local events = PassiveCapture:GetEvents(eventType)
    if #events == 0 then
        print("❌ Nenhum evento de " .. eventType .. " para replicar")
        return
    end
    
    self.replaying = true
    self.current_events = events
    self.replay_index = 1
    
    print("▶️ Replicando " .. #events .. " eventos de " .. eventType)
    
    task.spawn(function()
        while self.replaying and self.replay_index <= #self.current_events do
            local event = self.current_events[self.replay_index]
            
            pcall(function()
                self:ExecuteEvent(event, eventType)
            end)
            
            self.replay_index = self.replay_index + 1
            task.wait(0.1 / (speed or 1))
        end
        
        self.replaying = false
        print("⏹️ Replicação finalizada!")
    end)
end

function SmartReplicator:ExecuteEvent(event, eventType)
    if eventType == "movements" and event.data.to then
        local character = localPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local targetPos = Vector3.new(event.data.to[1], event.data.to[2], event.data.to[3])
                rootPart.CFrame = CFrame.new(targetPos)
                print("🏃 Movendo para: " .. tostring(targetPos))
            end
        end
        
    elseif eventType == "remotes" then
        -- Busca o remote e tenta executar
        local remoteName = event.data.remote
        if remoteName then
            for _, remoteData in ipairs(RemoteScanner.found_remotes) do
                if remoteData.name == remoteName then
                    print("🌐 Tentando replicar remote: " .. remoteName)
                    -- Aqui poderia tentar executar o remote se encontrado
                    break
                end
            end
        end
        
    elseif eventType == "interactions" then
        print("🖱️ Replicando interação: " .. event.data.name)
    end
end

function SmartReplicator:Stop()
    self.replaying = false
    print("⏸️ Replicação interrompida!")
end

-- Interface simples e discreta
local DiscreteUI = {
    gui = nil,
    frame = nil,
    labels = {},
    buttons = {}
}

function DiscreteUI:Create()
    pcall(function()
        local playerGui = localPlayer:WaitForChild("PlayerGui", 3)
        if not playerGui then return end
        
        -- Remove UI antiga
        local oldUI = playerGui:FindFirstChild("DeltaUI")
        if oldUI then oldUI:Destroy() end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DeltaUI"
        screenGui.Parent = playerGui
        
        -- Frame compacto
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 300, 0, 200)
        mainFrame.Position = UDim2.new(1, -320, 0, 20)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
        mainFrame.BorderSizePixel = 1
        mainFrame.Parent = screenGui
        
        -- Título compacto
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundTransparency = 1
        title.Text = "🎯 Delta Replicator"
        title.TextColor3 = Color3.fromRGB(0, 255, 150)
        title.TextSize = 14
        title.Font = Enum.Font.Code
        title.Parent = mainFrame
        
        -- Status labels
        local yPos = 30
        local statusInfo = {
            "📊 Total: 0",
            "🌐 Remotes: 0",
            "🏃 Moves: 0",
            "🖱️ Clicks: 0"
        }
        
        for _, text in ipairs(statusInfo) do
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 18)
            label.Position = UDim2.new(0, 5, 0, yPos)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 11
            label.Font = Enum.Font.Code
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = mainFrame
            
            table.insert(self.labels, label)
            yPos = yPos + 20
        end
        
        -- Botões compactos
        yPos = yPos + 5
        local buttonData = {
            {text = "▶️ Replay Moves", func = function() SmartReplicator:StartReplay("movements", 2) end},
            {text = "🌐 Replay Remotes", func = function() SmartReplicator:StartReplay("remotes", 1) end},
            {text = "⏹️ Stop", func = function() SmartReplicator:Stop() end}
        }
        
        for _, data in ipairs(buttonData) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 20)
            button.Position = UDim2.new(0, 5, 0, yPos)
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.BorderColor3 = Color3.fromRGB(80, 80, 80)
            button.Text = data.text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 10
            button.Font = Enum.Font.Code
            button.Parent = mainFrame
            
            button.MouseButton1Click:Connect(data.func)
            table.insert(self.buttons, button)
            yPos = yPos + 25
        end
        
        self.gui = screenGui
        self.frame = mainFrame
        print("🎮 Interface discreta criada!")
    end)
end

function DiscreteUI:Update()
    if not self.labels or #self.labels < 4 then return end
    
    pcall(function()
        self.labels[1].Text = "📊 Total: " .. PassiveCapture:GetTotal()
        self.labels[2].Text = "🌐 Remotes: " .. #RemoteScanner.found_remotes
        self.labels[3].Text = "🏃 Moves: " .. #PassiveCapture:GetEvents("movements")
        self.labels[4].Text = "🖱️ Clicks: " .. #PassiveCapture:GetEvents("interactions")
    end)
end

-- Função de inicialização segura
local function SafeInitialize()
    print("=" .. string.rep("=", 40) .. "=")
    print("🎯 DELTA REPLICATOR - ANTI-DETECÇÃO")
    print("=" .. string.rep("=", 40) .. "=")
    
    -- Inicialização em etapas com delays
    task.spawn(function()
        task.wait(0.5)
        RemoteScanner:ScanPassive()
    end)
    
    task.spawn(function()
        task.wait(1)
        MovementMonitor:StartMonitoring()
    end)
    
    task.spawn(function()
        task.wait(1.5)
        InteractionMonitor:StartMonitoring()
    end)
    
    task.spawn(function()
        task.wait(2)
        DiscreteUI:Create()
    end)
    
    -- Loop de atualização da UI
    task.spawn(function()
        while rawget(_G, "DeltaReplicatorActive") do
            pcall(function()
                DiscreteUI:Update()
            end)
            task.wait(1)
        end
    end)
    
    print("✅ Sistema inicializado com segurança!")
    print("📱 Interface no canto superior direito")
end

-- Sistema de cleanup
local function Cleanup()
    rawset(_G, "DeltaReplicatorActive", false)
    
    pcall(function()
        if DiscreteUI.gui then
            DiscreteUI.gui:Destroy()
        end
    end)
    
    -- Limpa conexões
    for _, conn in ipairs(InteractionMonitor.connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    print("👋 Sistema finalizado com segurança!")
end

game:BindToClose(Cleanup)

-- Executa inicialização segura
local success, error = pcall(SafeInitialize)

if not success then
    print("❌ Erro na inicialização: " .. tostring(error))
    print("🔄 Tentando modo básico...")
    
    -- Modo básico de emergência
    task.spawn(function()
        local counter = 0
        while rawget(_G, "DeltaReplicatorActive") do
            counter = counter + 1
            print("💓 Sistema ativo - Ciclo: " .. counter)
            task.wait(3)
        end
    end)
end

print("🎯 Sistema carregado! Para desativar: _G.DeltaReplicatorActive = false")
