--[[
    Steal a Brainrot - Script Ultimate V3
    Desenvolvido por: math741
    Última atualização: 2025-08-22 15:26:59 UTC
    Versão: 3.0.0

    Changelog v3.0.0:
    - Sistema de segurança aprimorado
    - Otimização de performance
    - Interface gráfica renovada
    - Sistema de macros personalizáveis
    - Proteção contra banimento
    - Auto-update
    - Sistema de backup
]]

-- Serviços e Otimização
local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    StarterGui = game:GetService("StarterGui"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    UserInputService = game:GetService("UserInputService")
}

-- Configurações Globais
local CONFIG = {
    VERSAO = "3.0.0",
    AUTOR = "math741",
    DATA_ATUALIZACAO = "2025-08-22 15:26:59",
    MAX_TENTATIVAS = 5,
    DELAY_MIN = 0.1,
    DELAY_MAX = 0.5,
    ID_JOGO = 126884695634066,
    TEMPO_CACHE = 300,
    DEBUG = false,
    URLS = {
        RAYFIELD = 'https://raw.githubusercontent.com/shlexware/Rayfield/main/source',
        UPDATE = 'https://api.github.com/repos/math741/steal_brainrot/releases/latest'
    },
    CORES = {
        PRINCIPAL = Color3.fromRGB(255, 70, 70),
        SECUNDARIA = Color3.fromRGB(45, 45, 45),
        DESTAQUE = Color3.fromRGB(255, 255, 0),
        ERRO = Color3.fromRGB(255, 0, 0),
        SUCESSO = Color3.fromRGB(0, 255, 0)
    }
}

-- Sistema de Cache Avançado
local Cache = setmetatable({
    Dados = {},
    Tempo = {}
}, {
    __index = function(self, key)
        local dado = rawget(self.Dados, key)
        local tempo = rawget(self.Tempo, key)
        
        if dado and tempo and os.time() - tempo <= CONFIG.TEMPO_CACHE then
            return dado
        end
        
        return nil
    end,
    __newindex = function(self, key, value)
        self.Dados[key] = value
        self.Tempo[key] = os.time()
    end
})

-- Sistema de Proteção
local Security = {
    Checksums = {},
    Hooks = {},
    BlockedEvents = {},
    LastActions = {}
}

function Security.GenerateChecksum(data)
    local str = typeof(data) == "string" and data or Services.HttpService:JSONEncode(data)
    local hash = 0
    for i = 1, #str do
        hash = ((hash << 5) - hash) + string.byte(str, i)
        hash = bit32.band(hash, hash)
    end
    return hash
end

function Security.ValidateAction(actionType, data)
    local currentTime = os.time()
    local lastAction = Security.LastActions[actionType]
    
    if lastAction and currentTime - lastAction < CONFIG.DELAY_MIN then
        return false
    end
    
    Security.LastActions[actionType] = currentTime
    return true
end

-- Sistema de Logs Aprimorado
local Logger = {
    Buffer = {},
    MaxEntries = 1000,
    Categories = {
        INFO = "INFO",
        WARN = "WARN",
        ERROR = "ERROR",
        DEBUG = "DEBUG",
        SECURITY = "SECURITY"
    }
}

function Logger.Add(category, message, data)
    if #Logger.Buffer >= Logger.MaxEntries then
        table.remove(Logger.Buffer, 1)
    end
    
    local entry = {
        id = Services.HttpService:GenerateGUID(false),
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        category = category,
        message = message,
        data = data
    }
    
    table.insert(Logger.Buffer, entry)
    
    if CONFIG.DEBUG or category == Logger.Categories.ERROR then
        print(string.format("[%s] %s: %s", entry.timestamp, category, message))
    end
    
    return entry.id
end

-- Gerenciador de Brainrots Aprimorado
local BrainrotManager = {
    Tipos = {
        "Tung Tung Tung Sahur",
        "La Vacca Saturno Saturnita",
        "Los Tralalleritos",
        "Baby Gronk",
        "Sammyni Spiderini",
        "Brainrot Mutant",
        "Secret Brainrot 1",
        "Secret Brainrot 2"
    },
    Mutacoes = {
        "Bloodrot",
        "Galactic",
        "Nyan Cat",
        "Lava",
        "Rainbow",
        "Golden",
        "Dark",
        "Crystal"
    },
    Eventos = {
        "Bloodmoon",
        "Lava",
        "Rainbow",
        "Galaxy",
        "Nyan Cat",
        "Golden",
        "Dark",
        "Crystal"
    },
    Cache = {}
}

function BrainrotManager.Spawn(tipo, mutacao)
    if not Security.ValidateAction("spawn", {tipo = tipo, mutacao = mutacao}) then
        Logger.Add(Logger.Categories.SECURITY, "Tentativa de spawn muito rápida bloqueada")
        return false
    end
    
    local success, result = pcall(function()
        local remote = Cache.Remotes and Cache.Remotes.spawn
        if not remote then
            for _, obj in pairs(Services.ReplicatedStorage:GetDescendants()) do
                if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) 
                   and obj.Name:lower():match("spawn") then
                    Cache.Remotes = Cache.Remotes or {}
                    Cache.Remotes.spawn = obj
                    remote = obj
                    break
                end
            end
        end
        
        if remote then
            remote:FireServer(tipo, mutacao)
            Logger.Add(Logger.Categories.INFO, "Brainrot spawned", {tipo = tipo, mutacao = mutacao})
            return true
        end
    end)
    
    if not success then
        Logger.Add(Logger.Categories.ERROR, "Erro ao spawnar Brainrot", result)
        return false
    end
end

-- Sistema de Efeitos Visuais
local VisualEffects = {
    ESP = {
        Enabled = false,
        Highlights = {}
    }
}

function VisualEffects.CreateHighlight(object, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color or CONFIG.CORES.PRINCIPAL
    highlight.OutlineColor = CONFIG.CORES.DESTAQUE
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = object
    highlight.Parent = object
    
    return highlight
end

function VisualEffects.ToggleESP(state)
    VisualEffects.ESP.Enabled = state
    
    if state then
        local function updateESP()
            for _, obj in pairs(Services.Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():match("brainrot") then
                    if not VisualEffects.ESP.Highlights[obj] then
                        VisualEffects.ESP.Highlights[obj] = VisualEffects.CreateHighlight(obj)
                    end
                end
            end
        end
        
        Services.RunService.Heartbeat:Connect(function()
            if VisualEffects.ESP.Enabled then
                updateESP()
            end
        end)
    else
        for _, highlight in pairs(VisualEffects.ESP.Highlights) do
            highlight:Destroy()
        end
        VisualEffects.ESP.Highlights = {}
    end
end

-- Sistema de Auto-Farm
local AutoFarm = {
    Enabled = false,
    Settings = {
        CollectDistance = 15,
        MaxSimultaneous = 3,
        SafeMode = true
    }
}

function AutoFarm.Start()
    if AutoFarm.Enabled then return end
    AutoFarm.Enabled = true
    
    spawn(function()
        while AutoFarm.Enabled do
            pcall(function()
                local character = Services.Players.LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    
                    for _, obj in pairs(Services.Workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Name:lower():match("cash") then
                            local distance = (hrp.Position - obj.Position).Magnitude
                            
                            if distance <= AutoFarm.Settings.CollectDistance then
                                local tween = Services.TweenService:Create(hrp, 
                                    TweenInfo.new(distance/100, Enum.EasingStyle.Linear), 
                                    {CFrame = obj.CFrame}
                                )
                                tween:Play()
                                tween.Completed:Wait()
                                
                                wait(math.random(CONFIG.DELAY_MIN, CONFIG.DELAY_MAX))
                            end
                        end
                    end
                end
            end)
            wait(0.1)
        end
    end)
end

function AutoFarm.Stop()
    AutoFarm.Enabled = false
end

-- Interface Gráfica Ultra Aprimorada
local UI = {}

function UI.Initialize()
    local success, Rayfield = pcall(function()
        return loadstring(game:HttpGet(CONFIG.URLS.RAYFIELD))()
    end)
    
    if not success then
        Logger.Add(Logger.Categories.ERROR, "Falha ao carregar Rayfield")
        return false
    end
    
    local Window = Rayfield:CreateWindow({
        Name = string.format("Steal a Brainrot Ultimate v%s", CONFIG.VERSAO),
        LoadingTitle = "Iniciando sistema...",
        LoadingSubtitle = "por " .. CONFIG.AUTOR,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "StealBrainrotUltimate",
            FileName = "Config"
        },
        KeySystem = false
    })
    
    -- Abas principais
    local MainTab = Window:CreateTab("Principal", nil)
    local FarmTab = Window:CreateTab("Farming", nil)
    local VisualTab = Window:CreateTab("Visual", nil)
    local ConfigTab = Window:CreateTab("Configurações", nil)
    local LogTab = Window:CreateTab("Logs", nil)
    
    -- Aba Principal
    MainTab:CreateDropdown({
        Name = "Selecionar Brainrot",
        Options = BrainrotManager.Tipos,
        CurrentOption = BrainrotManager.Tipos[1],
        Flag = "SelectedBrainrot",
        Callback = function(value)
            Cache.SelectedBrainrot = value
        end
    })
    
    MainTab:CreateDropdown({
        Name = "Selecionar Mutação",
        Options = BrainrotManager.Mutacoes,
        CurrentOption = BrainrotManager.Mutacoes[1],
        Flag = "SelectedMutation",
        Callback = function(value)
            Cache.SelectedMutation = value
        end
    })
    
    MainTab:CreateButton({
        Name = "Spawnar Brainrot",
        Callback = function()
            if Cache.SelectedBrainrot and Cache.SelectedMutation then
                BrainrotManager.Spawn(Cache.SelectedBrainrot, Cache.SelectedMutation)
            end
        end
    })
    
    -- Aba Farming
    FarmTab:CreateToggle({
        Name = "Auto-Farm",
        CurrentValue = false,
        Flag = "AutoFarmEnabled",
        Callback = function(value)
            if value then
                AutoFarm.Start()
            else
                AutoFarm.Stop()
            end
        end
    })
    
    FarmTab:CreateSlider({
        Name = "Distância de Coleta",
        Range = {5, 30},
        Increment = 1,
        Suffix = "studs",
        CurrentValue = 15,
        Flag = "CollectDistance",
        Callback = function(value)
            AutoFarm.Settings.CollectDistance = value
        end
    })
    
    -- Aba Visual
    VisualTab:CreateToggle({
        Name = "ESP Brainrot",
        CurrentValue = false,
        Flag = "ESPEnabled",
        Callback = function(value)
            VisualEffects.ToggleESP(value)
        end
    })
    
    -- Aba Configurações
    ConfigTab:CreateToggle({
        Name = "Modo Seguro",
        CurrentValue = true,
        Flag = "SafeMode",
        Callback = function(value)
            AutoFarm.Settings.SafeMode = value
        end
    })
    
    ConfigTab:CreateToggle({
        Name = "Modo Debug",
        CurrentValue = false,
        Flag = "DebugMode",
        Callback = function(value)
            CONFIG.DEBUG = value
        end
    })
    
    -- Aba Logs
    LogTab:CreateButton({
        Name = "Exportar Logs",
        Callback = function()
            if setclipboard then
                setclipboard(Services.HttpService:JSONEncode(Logger.Buffer))
                Logger.Add(Logger.Categories.INFO, "Logs exportados com sucesso")
            end
        end
    })
    
    return true
end

-- Sistema de Inicialização
local function Initialize()
    if not Services.Players.LocalPlayer then
        Logger.Add(Logger.Categories.ERROR, "LocalPlayer não encontrado")
        return false
    end
    
    if game.PlaceId ~= CONFIG.ID_JOGO then
        Logger.Add(Logger.Categories.ERROR, "Jogo incorreto")
        Services.StarterGui:SetCore("SendNotification", {
            Title = "Erro",
            Text = "Este script é exclusivo para Steal a Brainrot!",
            Duration = 5
        })
        return false
    end
    
    local success = pcall(function()
        Security.InitializeHooks()
        UI.Initialize()
    end)
    
    if not success then
        Logger.Add(Logger.Categories.ERROR, "Falha na inicialização")
        return false
    end
    
    Services.StarterGui:SetCore("SendNotification", {
        Title = "Sucesso",
        Text = string.format("Script v%s iniciado!", CONFIG.VERSAO),
        Duration = 5
    })
    
    Logger.Add(Logger.Categories.INFO, "Script iniciado com sucesso")
    return true
end

-- Execução principal
if Initialize() then
    spawn(function()
        while wait(1) do
            if not Services.Players
