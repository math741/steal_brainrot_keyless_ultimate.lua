-- Script Roblox Otimizado e Corrigido
-- Verificações de compatibilidade melhoradas

-- Proteção inicial com verificações
local function checkCompatibility()
    local required = {
        "getgenv",
        "setfpscap", 
        "getrawmetatable",
        "setreadonly",
        "newcclosure",
        "getnamecallmethod"
    }
    
    local missing = {}
    for _, func in ipairs(required) do
        if not _G[func] then
            table.insert(missing, func)
        end
    end
    
    if #missing > 0 then
        warn("⚠️ Funções não disponíveis: " .. table.concat(missing, ", "))
        warn("Execute este script em um executor compatível (Synapse X, Krnl, etc.)")
        return false
    end
    
    return true
end

-- Verifica compatibilidade antes de continuar
if not checkCompatibility() then
    return
end

-- Proteção contra execução múltipla
if getgenv().ScriptActive then 
    warn("Script já está ativo!")
    return 
end
getgenv().ScriptActive = true

-- Otimização de referências (cache local)
local next = next
local table_insert = table.insert
local table_remove = table.remove
local math_random = math.random
local math_floor = math.floor
local string_format = string.format
local os_clock = os.clock
local task_wait = task.wait
local task_spawn = task.spawn

-- Serviços do Roblox
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

-- Sistema de Cache Otimizado
local Cache = {
    data = {},
    stats = {
        hits = 0,
        misses = 0,
        calls = 0
    }
}

function Cache:Get(key)
    if self.data[key] then
        self.stats.hits = self.stats.hits + 1
        return self.data[key]
    else
        self.stats.misses = self.stats.misses + 1
        return nil
    end
end

function Cache:Set(key, value)
    self.stats.calls = self.stats.calls + 1
    self.data[key] = {
        value = value,
        timestamp = os_clock()
    }
end

function Cache:Clean()
    local now = os_clock()
    local cleaned = 0
    
    for k, v in pairs(self.data) do
        if (now - v.timestamp) > 60 then -- Remove após 60 segundos
            self.data[k] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print(string_format("🧹 Cache limpo: %d itens removidos", cleaned))
    end
end

-- Sistema de Performance
local Performance = {
    fps = 0,
    lastCheck = os_clock(),
    samples = {},
    maxSamples = 50
}

function Performance:Initialize()
    print("🚀 Inicializando otimizações de performance...")
    
    -- Remove limite de FPS (se disponível)
    if setfpscap then
        pcall(function()
            setfpscap(9999)
        end)
    end
    
    -- Otimizações de renderização
    pcall(function()
        settings().Physics.AllowSleep = true
        settings().Rendering.QualityLevel = 1
    end)
    
    -- Monitor de FPS
    runService.Heartbeat:Connect(function()
        local now = os_clock()
        local delta = now - self.lastCheck
        self.lastCheck = now
        
        if delta > 0 then
            local currentFPS = 1 / delta
            table_insert(self.samples, currentFPS)
            
            if #self.samples > self.maxSamples then
                table_remove(self.samples, 1)
            end
            
            -- Calcula FPS médio
            local totalFPS = 0
            for _, fps in ipairs(self.samples) do
                totalFPS = totalFPS + fps
            end
            self.fps = totalFPS / #self.samples
        end
    end)
end

function Performance:GetFPS()
    return math_floor(self.fps)
end

function Performance:OptimizeWorkspace()
    local optimized = 0
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or 
               obj:IsA("Trail") or 
               obj:IsA("Smoke") or 
               obj:IsA("Fire") or 
               obj:IsA("Sparkles") then
                obj.Enabled = false
                optimized = optimized + 1
            end
            
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                optimized = optimized + 1
            end
        end)
    end
    
    print(string_format("✨ %d objetos otimizados", optimized))
end

-- Sistema de Proteção
local Protection = {
    active = false,
    detections = 0,
    blockedCalls = 0
}

function Protection:Initialize()
    print("🛡️ Iniciando sistema de proteção...")
    
    if not getrawmetatable or not setreadonly or not newcclosure or not getnamecallmethod then
        warn("⚠️ Proteção limitada - funções avançadas não disponíveis")
        return
    end
    
    local success, mt = pcall(getrawmetatable, game)
    if not success then
        warn("⚠️ Não foi possível obter metatable")
        return
    end
    
    local success2 = pcall(setreadonly, mt, false)
    if not success2 then
        warn("⚠️ Não foi possível modificar metatable")
        return
    end
    
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local success, method = pcall(getnamecallmethod)
        if not success then
            return oldNamecall(self, ...)
        end
        
        local args = {...}
        
        -- Análise de chamadas suspeitas
        if method == "FireServer" or method == "InvokeServer" then
            self.detections = self.detections + 1
            
            -- Verifica padrões suspeitos
            local suspicious = false
            for _, arg in ipairs(args) do
                if type(arg) == "string" then
                    local lower = string.lower(arg)
                    if string.find(lower, "ban") or 
                       string.find(lower, "kick") or 
                       string.find(lower, "anticheat") then
                        suspicious = true
                        break
                    end
                end
            end
            
            if suspicious then
                self.blockedCalls = self.blockedCalls + 1
                warn("🚫 Chamada suspeita bloqueada")
                return wait(9e9) -- Bloqueia indefinidamente
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    pcall(setreadonly, mt, true)
    self.active = true
    print("✅ Proteção ativada com sucesso!")
end

function Protection:GetStats()
    return {
        active = self.active,
        detections = self.detections,
        blocked = self.blockedCalls
    }
end

-- Sistema de Monitoramento de Remotes
local RemoteMonitor = {
    enabled = false,
    remotes = {},
    totalCalls = 0
}

function RemoteMonitor:Initialize()
    print("🌐 Inicializando monitor de remotes...")
    self.enabled = true
    
    -- Escaneia remotes existentes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:TrackRemote(obj)
        end
    end
    
    -- Monitora novos remotes
    game.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            self:TrackRemote(obj)
        end
    end)
end

function RemoteMonitor:TrackRemote(remote)
    local remoteData = {
        remote = remote,
        name = remote.Name,
        path = remote:GetFullName(),
        calls = 0,
        lastCall = 0
    }
    
    table_insert(self.remotes, remoteData)
    
    if remote:IsA("RemoteEvent") then
        local oldFireServer = remote.FireServer
        remote.FireServer = newcclosure(function(self, ...)
            remoteData.calls = remoteData.calls + 1
            remoteData.lastCall = os_clock()
            RemoteMonitor.totalCalls = RemoteMonitor.totalCalls + 1
            return oldFireServer(self, ...)
        end)
    end
end

function RemoteMonitor:GetStats()
    return {
        totalRemotes = #self.remotes,
        totalCalls = self.totalCalls,
        enabled = self.enabled
    }
end

-- Interface de Status
local StatusGUI = {
    gui = nil,
    frame = nil,
    labels = {}
}

function StatusGUI:Create()
    -- Cria GUI simples para mostrar status
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StatusGUI"
    screenGui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(0, 1, 0)
    frame.Parent = screenGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🚀 Script Status"
    title.TextColor3 = Color3.new(0, 1, 0)
    title.TextScaled = true
    title.Font = Enum.Font.Code
    title.Parent = frame
    
    -- Labels de status
    local yPos = 35
    for _, text in ipairs({"FPS: 0", "Cache: 0 hits", "Protection: ❌", "Remotes: 0"}) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 25)
        label.Position = UDim2.new(0, 5, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        table_insert(self.labels, label)
        yPos = yPos + 30
    end
    
    self.gui = screenGui
    self.frame = frame
end

function StatusGUI:Update()
    if not self.labels or #self.labels == 0 then return end
    
    local protectionStats = Protection:GetStats()
    local remoteStats = RemoteMonitor:GetStats()
    
    self.labels[1].Text = string_format("FPS: %d", Performance:GetFPS())
    self.labels[2].Text = string_format("Cache: %d hits/%d miss", Cache.stats.hits, Cache.stats.misses)
    self.labels[3].Text = string_format("Protection: %s (%d blocked)", 
        protectionStats.active and "✅" or "❌", protectionStats.blocked)
    self.labels[4].Text = string_format("Remotes: %d tracked", remoteStats.totalRemotes)
end

-- Inicialização Principal
local function Initialize()
    print("=" .. string.rep("=", 50) .. "=")
    print("🚀 Iniciando Script Otimizado...")
    print("=" .. string.rep("=", 50) .. "=")
    
    -- Inicializa sistemas
    Performance:Initialize()
    Protection:Initialize()
    RemoteMonitor:Initialize()
    StatusGUI:Create()
    
    -- Loop de atualização
    task_spawn(function()
        while getgenv().ScriptActive do
            StatusGUI:Update()
            Cache:Clean()
            task_wait(1)
        end
    end)
    
    -- Otimização automática de performance
    task_spawn(function()
        while getgenv().ScriptActive do
            task_wait(10)
            if Performance:GetFPS() < 30 then
                print("⚡ Performance baixa detectada, otimizando...")
                Performance:OptimizeWorkspace()
            end
        end
    end)
    
    print("✅ Script inicializado com sucesso!")
    print("📊 GUI de status criada no canto superior esquerdo")
end

-- Executa inicialização
Initialize()

-- Cleanup ao sair
game:BindToClose(function()
    getgenv().ScriptActive = false
    if StatusGUI.gui then
        StatusGUI.gui:Destroy()
    end
    print("👋 Script finalizado!")
end)
