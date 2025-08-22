
-- Proteção Inicial Suprema
if not getgenv then
    error("⚠️ Executor não compatível com tecnologia quântica suprema!")
end
-- Verificação de Nil
local function SafeCall(func, ...)
    if type(func) == "function" then
        return func(...)
    else
        warn("⚠️ Tentativa de chamar função nil!")
        return nil
    end
end

-- Sistema de proteção contra nil
local function InitializeProtection()
    for k, v in pairs(getgenv()) do
        if type(v) == "function" then
            local old = v
            getgenv()[k] = function(...)
                return SafeCall(old, ...)
            end
        end
    end
end

InitializeProtection()
if getgenv().SupremeUnifiedActive then return end
getgenv().SupremeUnifiedActive = true

-- Otimização de Referências
local next = next
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local math_random = math.random
local math_floor = math.floor
local string_format = string.format
local os_clock = os.clock
local task_wait = task.wait
local task_spawn = task.spawn
local task_delay = task.delay
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")

-- Cache Neural Supremo
local SupremeCache = setmetatable({
    _data = {},
    _neural = {},
    _quantum = {},
    _dimensional = {},
    stats = {
        hits = 0,
        misses = 0,
        quantum_calls = 0,
        dimensional_shifts = 0
    }
}, {
    __index = function(self, key)
        self.stats.hits = self.stats.hits + 1
        return self._data[key]
    end,
    __newindex = function(self, key, value)
        self.stats.quantum_calls = self.stats.quantum_calls + 1
        self._quantum[key] = {
            timestamp = os_clock(),
            dimension = math_random(1, 10),
            entropy = math_random(),
            neural_adaptation = math_random()
        }
        self._data[key] = value
    end
})

-- Sistema de Performance Suprema
local PerformanceOptimizer = {
    fps = 0,
    lastCheck = os_clock(),
    samples = {},
    maxSamples = 100,
    optimizations = {
        memory = true,
        render = true,
        physics = true,
        network = true
    }
}

function PerformanceOptimizer:Initialize()
    -- Remove limites de FPS
    setfpscap(9999)
    
    -- Otimizações Supremas
    settings().Physics.PhysicsEnvironmentalThrottle = 1
    settings().Physics.AllowSleep = true
    settings().Physics.UseCSGv2 = false
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshPartDetailLevel = 0
    
    -- Monitor de Performance
    runService.Heartbeat:Connect(function()
        local now = os_clock()
        local delta = now - self.lastCheck
        self.lastCheck = now
        
        -- Calcula FPS
        local currentFPS = 1 / delta
        table_insert(self.samples, currentFPS)
        
        if #self.samples > self.maxSamples then
            table_remove(self.samples, 1)
        end
        
        -- Média de FPS
        local totalFPS = 0
        for _, fps in ipairs(self.samples) do
            totalFPS = totalFPS + fps
        end
        self.fps = totalFPS / #self.samples
        
        -- Auto-otimização baseada em performance
        if self.fps < 30 then
            self:EmergencyOptimize()
        end
    end)
end

function PerformanceOptimizer:EmergencyOptimize()
    -- Otimização Emergencial
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or 
           obj:IsA("Trail") or 
           obj:IsA("Smoke") or 
           obj:IsA("Fire") or 
           obj:IsA("Sparkles") then
            obj.Enabled = false
        end
        
        if obj:IsA("BasePart") then
            obj.CastShadow = false
        end
    end
    
    -- Limpa Cache
    self:CleanupCache()
end

function PerformanceOptimizer:CleanupCache()
    local now = os_clock()
    local cleaned = 0
    
    for k, v in pairs(SupremeCache._data) do
        if type(v) == "table" and v.timestamp and (now - v.timestamp) > 60 then
            SupremeCache._data[k] = nil
            cleaned = cleaned + 1
        end
    end
    
    print(string_format("🧹 Cache limpo: %d itens removidos", cleaned))
end

-- Sistema de Proteção Suprema
local SupremeShield = {
    active = false,
    dimensions = {},
    neural = {},
    quantum = {},
    detections = 0,
    threats = {}
}

function SupremeShield:Initialize()
    self.active = true
    print("🛡️ Iniciando Proteção Suprema...")
    
    -- Proteção Multi-Dimensional
    for i = 1, 10 do
        self.dimensions[i] = {
            active = true,
            shield = math_random(),
            entropy = math_random(),
            neural_adaptation = math_random()
        }
    end
    
    -- Hook Quântico Supremo
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Análise Quântica Suprema
        if method == "FireServer" or method == "InvokeServer" then
            local quantumData = {
                method = method,
                instance = self,
                args = args,
                time = os_clock(),
                dimension = math_random(1, 10),
                entropy = math_random(),
                neural_adaptation = math_random()
            }
            
            if SupremeShield:AnalyzeQuantum(quantumData) then
                return wait(9e9)
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    print("✅ Proteção Suprema Ativada!")
end

-- Sistema de Replicação Suprema Unificada
local SupremeReplicator = {
    enabled = false,
    remotes = {},
    quantum = {},
    neural = {},
    dimensional = {},
    stats = {
        replications = 0,
        success = 0,
        entropy = 0,
        quantum_shifts = 0
    }
}

function SupremeReplicator:Initialize()
    print("🌌 Iniciando Replicador Supremo Unificado...")
    self.enabled = true
    
    -- Scan Quântico Supremo
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local remoteData = {
                remote = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                calls = 0,
                args = {},
                quantum = {
                    dimension = math_random(1, 10),
                    entropy = math_random(),
                    neural_adaptation = math_random()
                }
            }
            table_insert(self.remotes, remoteData)
            
            -- Hook Avançado
            if obj:IsA("RemoteEvent") then
                local oldFireServer = obj.FireServer
                obj.FireServer = newcclosure(function(self, ...)
                    local args = {...}
                    remoteData.calls = remoteData.calls + 1
                    
                    -- Análise Neural
                    local quantumData = {
                        args = args,
                        time = os_clock(),
                        dimension = remoteData.quantum.dimension,
                        entropy = math_random(),
                        neural_adaptation = remoteData.quantum.neural_adaptation
                    }
                    
                    table_insert(remoteData.args, quantumData)
                    return oldFireServer(self, ...)
                end)
            end
        end
    end
    
    print("✅ Replicador Supremo Inicializado!")
end

function SupremeReplicator:ReplicateSupreme(target)
    print("🎯 Iniciando Replicação Suprema:", target.Name)
    
    -- Captura Suprema
    local supremeData = {
        name = target.Name,
        class = target.ClassName,
        quantum = {
            dimension = math_random(1, 10),
            entropy = math_random(),
            neural_adaptation = math_random()
        },
        properties = {},
        animations = {},
        effects = {},
        neural = {},
        dimensional = {}
    }
    
    -- Captura Propriedades Supremas
    pcall(function()
        supremeData.properties = {
            CFrame = target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot(),
            Size = target.PrimaryPart and target.PrimaryPart.Size or Vector3.new(1, 1, 1),
            BrickColor = target.PrimaryPart and target.PrimaryPart.BrickColor or BrickColor.new("Medium stone grey"),
            Material = target.PrimaryPart and target.PrimaryPart.Material or Enum.Material.Plastic,
            Transparency = target.PrimaryPart and target.PrimaryPart.Transparency or 0
        }
    end)
    
    -- Captura Animações Supremas
    if target:FindFirstChild("Humanoid") and target.Humanoid:FindFirstChild("Animator") then
        for _, track in pairs(target.Humanoid.Animator:GetPlayingAnimationTracks()) do
            table_insert(supremeData.animations, {
                id = track.Animation.AnimationId,
                speed = track.Speed,
                weight = track.WeightCurrent,
                timePosition = track.TimePosition,
                quantum = {
                    dimension = math_random(1, 10),
                    entropy = math_random(),
                    neural_adaptation = math_random()
                }
            })
        end
    end
    
    -- Captura Efeitos Supremos
    for _, part in pairs(target:GetDescendants()) do
        if part:IsA("ParticleEmitter") then
            table_insert(supremeData.effects, {
                name = part.Name,
                properties = {
                    Color = part.Color,
                    Size = part.Size,
                    Speed = part.Speed,
                    Rate = part.Rate,
                    Acceleration = part.Acceleration,
                    Drag = part.Drag,
                    Lifetime = part.Lifetime,
                    SpreadAngle = part.SpreadAngle
                },
                quantum = {
                    dimension = math_random(1, 10),
                    entropy = math_random(),
                    neural_adaptation = math_random()
                }
            })
        end
    end
    
    -- Armazena no Cache Supremo
    SupremeCache[target.Name] = supremeData
    self.stats.replications = self.stats.replications + 1
    
    print("✨ Replicação Suprema Completa!")
    return supremeData
end

function SupremeReplicator:CreateSupremeReplica(data)
    print("🔮 Criando Réplica Suprema:", data.name)
    
    -- Modelo Base Supremo
    local model = Instance.new("Model")
    model.Name = data.name .. "_Supreme"
    
    -- Parte Principal Suprema
    local main = Instance.new("Part")
    main.CFrame = data.properties.CFrame
    main.Size = data.properties.Size
    main.BrickColor = data.properties.BrickColor
    main.Material = data.properties.Material
    main.Transparency = data.properties.Transparency
    main.Anchored = true
    main.Parent = model
    
    -- Animações Supremas
    if #data.animations > 0 then
        local humanoid = Instance.new("Humanoid")
        local animator = Instance.new("Animator")
        animator.Parent = humanoid
        humanoid.Parent = model
        
        for _, anim in pairs(data.animations) do
            local animation = Instance.new("Animation")
            animation.AnimationId = anim.id
            
            local track = animator:LoadAnimation(animation)
            track:Play()
            track:AdjustSpeed(anim.speed)
            track:AdjustWeight(anim.weight)
            track.TimePosition = anim.timePosition
        end
    end
    
    -- Efeitos Supremos
    for _, effect in pairs(data.effects) do
        local emitter = Instance.new("ParticleEmitter")
        for prop, value in pairs(effect.properties) do
            emitter[prop] = value
        end
        emitter.Parent = main
    end
    
    model.Parent = workspace
    self.stats.success = self.stats.success + 1
    
    print("✅ Réplica Suprema Criada!")
    return model
end

-- Interface Suprema Unificada
local SupremeUI = {}
SupremeUI.__index = SupremeUI

function SupremeUI.new()
    local self = setmetatable({}, SupremeUI)
    
    -- GUI Suprema
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "SupremeUnifiedV10"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.DisplayOrder = 999999999
    
    -- Frame Principal Supremo
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 400, 0, 600)
    self.mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
-- Continuação da Interface Suprema
function SupremeUI:InitializeInterface()
    -- Efeitos Visuais Supremos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.mainFrame
    
    -- Título Supremo
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Supreme Unified v10"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 20
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Container Principal
    self.container = Instance.new("ScrollingFrame")
    self.container.Size = UDim2.new(1, -20, 1, -100)
    self.container.Position = UDim2.new(0, 10, 0, 50)
    self.container.BackgroundTransparency = 1
    self.container.ScrollBarThickness = 4
    self.container.Parent = self.mainFrame
    
    -- Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = self.container
    
    -- Painel de Estatísticas
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, 0, 0, 100)
    statsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    statsPanel.Parent = self.container
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 8)
    statsCorner.Parent = statsPanel
    
    self.statsLabel = Instance.new("TextLabel")
    self.statsLabel.Size = UDim2.new(1, -20, 1, -10)
    self.statsLabel.Position = UDim2.new(0, 10, 0, 5)
    self.statsLabel.BackgroundTransparency = 1
    self.statsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.statsLabel.TextSize = 14
    self.statsLabel.Font = Enum.Font.Gotham
    self.statsLabel.Parent = statsPanel
    
    -- Botões de Controle
    local controlPanel = Instance.new("Frame")
    controlPanel.Size = UDim2.new(1, 0, 0, 40)
    controlPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    controlPanel.Parent = self.container
    
    local controlCorner = Instance.new("UICorner")
    controlCorner.CornerRadius = UDim.new(0, 8)
    controlCorner.Parent = controlPanel
    
    -- Botão de Scan
    local scanButton = self:CreateButton("🔄 Scan", UDim2.new(0.5, -5, 1, -10), controlPanel)
    scanButton.MouseButton1Click:Connect(function()
        self:PerformSupremeScan()
    end)
    
    -- Botão de Otimização
    local optimizeButton = self:CreateButton("⚡ Otimizar", UDim2.new(0.5, 5, 1, -10), controlPanel)
    optimizeButton.Position = UDim2.new(0.5, 5, 0, 5)
    optimizeButton.MouseButton1Click:Connect(function()
        PerformanceOptimizer:EmergencyOptimize()
    end)
    
    -- Lista de Targets
    self.targetList = Instance.new("Frame")
    self.targetList.Size = UDim2.new(1, 0, 1, -160)
    self.targetList.BackgroundTransparency = 1
    self.targetList.Parent = self.container
    
    local targetLayout = Instance.new("UIListLayout")
    targetLayout.Padding = UDim.new(0, 5)
    targetLayout.Parent = self.targetList
    
    -- Inicializa Updates
    self:StartUpdates()
end

function SupremeUI:CreateButton(text, size, parent)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = UDim2.new(0, 5, 0, 5)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    -- Efeitos
    button.MouseEnter:Connect(function()
        tweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 80, 255)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        tweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 255)}):Play()
    end)
    
    return button
end

function SupremeUI:StartUpdates()
    -- Update de Estatísticas
    task_spawn(function()
        while task_wait(1) do
            self.statsLabel.Text = string_format([[
📊 Estatísticas Supremas:
FPS: %.1f
Replicações: %d
Cache Hits: %d
Dimensões: %d
Entropy: %.2f
            ]], 
            PerformanceOptimizer.fps,
            SupremeReplicator.stats.replications,
            SupremeCache.stats.hits,
            #SupremeShield.dimensions,
            math_random()
            )
        end
    end)
end

function SupremeUI:PerformSupremeScan()
    print("🔍 Iniciando Scan Supremo...")
    
    -- Limpa lista atual
    for _, child in pairs(self.targetList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Scan Supremo
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and 
           (obj.Name:lower():find("brainrot") or 
            obj.Name:lower():find("pet") or 
            obj.Name:lower():find("creature")) then
            
            self:CreateTargetCard(obj)
            count = count + 1
        end
    end
    
    print("✅ Scan Supremo Completo! Encontrados:", count)
end

function SupremeUI:CreateTargetCard(target)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    card.Parent = self.targetList
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card
    
    -- Info
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -150, 1, -10)
    infoLabel.Position = UDim2.new(0, 10, 0, 5)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = target.Name
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = card
    
    -- Botão de Replicação
    local replicateButton = Instance.new("TextButton")
    replicateButton.Size = UDim2.new(0, 100, 0, 30)
    replicateButton.Position = UDim2.new(1, -110, 0.5, -15)
    replicateButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    replicateButton.Text = "Replicar"
    replicateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    replicateButton.TextSize = 14
    replicateButton.Font = Enum.Font.GothamBold
    replicateButton.Parent = card
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = replicateButton
    
    -- Evento de Replicação
    replicateButton.MouseButton1Click:Connect(function()
        local data = SupremeReplicator:ReplicateSupreme(target)
        SupremeReplicator:CreateSupremeReplica(data)
    end)
end

-- Inicialização Suprema Unificada
local function InitializeSupremeSystem()
    print("🚀 Iniciando Sistema Supremo Unificado v10...")
    
    -- Inicializa todos os sistemas
    PerformanceOptimizer:Initialize()
    SupremeShield:Initialize()
    SupremeReplicator:Initialize()
    
    -- Cria e inicializa interface
    local UI = SupremeUI.new()
    UI:InitializeInterface()
    
    -- Parent com proteção máxima
    if syn then
        syn.protect_gui(UI.gui)
        UI.gui.Parent = coreGui
    else
        pcall(function()
            UI.gui.Parent = coreGui
        end)
        if not UI.gui.Parent then
            UI.gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    
    -- Scan inicial
    UI:PerformSupremeScan()
    
    print("✨ Sistema Supremo Unificado Inicializado com Sucesso!")
    return UI
end

-- Execução Final
local SupremeSystem = InitializeSupremeSystem()

-- Cria loadstring otimizado
local loadstringSupreme = [[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/math741/supreme_unified/main/supreme_v10.lua"))()
]]

return SupremeSystem
