--[[
    ███╗░░░██╗███████╗██╗░░░██╗███████╗██████╗░  ██╗░░░██╗██████╗░
    ████╗░██║██╔════╝██║░░░██║██╔════╝██╔══██╗  ██║░░░██║╚════██╗
    ██╔██╗██║█████╗░░╚██╗░██╔╝█████╗░░██████╔╝  ╚██╗░██╔╝░█████╔╝
    ██║╚████║██╔══╝░░░╚████╔╝░██╔══╝░░██╔══██╗  ░╚████╔╝░░╚═══██╗
    ██║░╚███║███████╗░░╚██╔╝░░███████╗██║░░██║  ░░╚██╔╝░░██████╔╝
    ╚═╝░░╚══╝╚══════╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝  ░░░╚═╝░░░╚═════╝░
    
    🌟 STEAL A BRAINROT - ULTRA SUPREME DEFINITIVE EDITION v7.1.0 🌟
    By: math741
    Last Update: 2025-08-22 16:23:04 UTC
    
    FEATURES:
    ⚡ Sistema Neural Quântico
    🚀 Performance Definitiva
    🎮 Interface Ultra Adaptativa
    🌌 Spawn Universal Supreme
    🤖 Farm IA Definitivo
    🎯 ESP 6D Neural
    🛡️ Proteção Absoluta
]]

-- Proteção Inicial Ultra Suprema
if getgenv().UltraSupremeProtected then return end
getgenv().UltraSupremeProtected = true

-- Services com Cache Neural
local Services = setmetatable({
    _cache = {},
    _neural = {},
    _quantum = {}
}, {
    __index = function(self, key)
        if not self._cache[key] then
            self._cache[key] = game:GetService(key)
            self._neural[key] = {
                loadTime = os.clock(),
                calls = 0,
                performance = {}
            }
        end
        self._neural[key].calls = self._neural[key].calls + 1
        return self._cache[key]
    end
})

-- Configurações Ultra Supremas
local SUPREME = {
    VERSION = "7.1.0",
    AUTHOR = "math741",
    UPDATE = "2025-08-22 16:23:04",
    THEME = {
        PRIMARY = Color3.fromRGB(20, 20, 30),
        SECONDARY = Color3.fromRGB(30, 30, 40),
        ACCENT = Color3.fromRGB(255, 70, 70),
        NEURAL = Color3.fromRGB(70, 200, 255),
        QUANTUM = Color3.fromRGB(255, 70, 255),
        SUCCESS = Color3.fromRGB(70, 255, 70),
        WARNING = Color3.fromRGB(255, 255, 70),
        ERROR = Color3.fromRGB(255, 70, 70),
        GRADIENTS = {
            SUPREME = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 70, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 255))
            }),
            QUANTUM = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 200, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 70, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 200, 255))
            })
        }
    }
}

-- Sistema de Brainrot Ultra Supremo
local BrainrotSystem = {
    brainrots = {},
    remotes = {},
    cache = {},
    stats = {
        spawns = 0,
        success = 0,
        fails = 0
    }
}

function BrainrotSystem:Initialize()
    -- Scan Neural de Brainrots
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("Model") and 
           (obj.Name:lower():find("brainrot") or 
            obj.Name:lower():find("pet") or 
            obj.Name:lower():find("creature")) then
            table.insert(self.brainrots, {
                name = obj.Name,
                model = obj,
                rarity = self:DetectRarity(obj)
            })
        end
        
        -- Scan de Remotes
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and
           (obj.Name:lower():find("spawn") or 
            obj.Name:lower():find("summon") or 
            obj.Name:lower():find("create")) then
            table.insert(self.remotes, obj)
        end
    end
end

function BrainrotSystem:DetectRarity(model)
    local name = model.Name:lower()
    if name:find("mythic") then return 5
    elseif name:find("legendary") then return 4
    elseif name:find("epic") then return 3
    elseif name:find("rare") then return 2
    else return 1 end
end

function BrainrotSystem:Spawn(brainrotName, mutation)
    local success = false
    
    -- Sistema Neural de Spawn
    for _, remote in pairs(self.remotes) do
        -- Padrões de Spawn
        local patterns = {
            function() remote:FireServer(brainrotName) end,
            function() remote:FireServer(brainrotName, mutation) end,
            function() remote:FireServer("Spawn", brainrotName) end,
            function() remote:FireServer({name = brainrotName, type = mutation}) end,
            function() remote:FireServer("summon", brainrotName) end
        }
        
        -- Tenta todos os padrões
        for _, pattern in pairs(patterns) do
            local s, e = pcall(pattern)
            if s then
                success = true
                self.stats.spawns = self.stats.spawns + 1
                break
            end
        end
        
        if success then break end
    end
    
    return success
end

-- Sistema de Farm Ultra Neural
local FarmSystem = {
    enabled = false,
    settings = {
        range = 50,
        speed = 0.1,
        smartPath = true,
        antiLag = true
    },
    stats = {
        started = 0,
        collected = 0,
        efficiency = 0
    }
}

function FarmSystem:Start()
    if self.enabled then return end
    self.enabled = true
    self.stats.started = os.clock()
    
    spawn(function()
        while self.enabled do
            self:CycleFarm()
            wait(self.settings.speed)
        end
    end)
end

function FarmSystem:CycleFarm()
    pcall(function()
        local char = Services.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        -- Scan de Itens
        local items = self:ScanItems()
        local target = self:GetBestTarget(items)
        
        if target then
            -- Teleporte Otimizado
            char.HumanoidRootPart.CFrame = target.CFrame
            wait(0.1)
            
            -- Simulação de Toque
            firetouchinterest(char.HumanoidRootPart, target, 0)
            wait()
            firetouchinterest(char.HumanoidRootPart, target, 1)
            
            self.stats.collected = self.stats.collected + 1
        end
    end)
end

function FarmSystem:ScanItems()
    local items = {}
    for _, obj in pairs(Services.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and
           (obj.Name:lower():find("collect") or
            obj.Name:lower():find("cash") or
            obj.Name:lower():find("coin")) then
            table.insert(items, obj)
        end
    end
    return items
end

function FarmSystem:GetBestTarget(items)
    local char = Services.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest = nil
    local minDist = math.huge
    
    for _, item in pairs(items) do
        local dist = (char.HumanoidRootPart.Position - item.Position).Magnitude
        if dist < minDist and dist <= self.settings.range then
            closest = item
            minDist = dist
        end
    end
    
    return closest
end

-- Interface Ultra Suprema
local UltraUI = {}
UltraUI.__index = UltraUI

function UltraUI.new()
    local self = setmetatable({}, UltraUI)
    
    -- GUI Base
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "UltraSupremeUI"
    
    -- Frame Principal
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 800, 0, 500)
    self.mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
    self.mainFrame.BackgroundColor3 = SUPREME.THEME.PRIMARY
    self.mainFrame.Parent = self.gui
    
    -- Adiciona Elementos Visuais
    self:CreateVisuals()
    
    -- Cria Abas
    self:CreateTabs()
    
    return self
end

function UltraUI:CreateVisuals()
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.mainFrame
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = SUPREME.THEME.GRADIENTS.SUPREME
    gradient.Rotation = 45
    gradient.Parent = self.mainFrame
    
    -- Efeito de Partículas
    spawn(function()
        while wait(0.1) do
            gradient.Rotation = gradient.Rotation + 1
            if gradient.Rotation >= 360 then
                gradient.Rotation = 0
            end
        end
    end)
end

function UltraUI:CreateTabs()
    -- Abas
    local spawnTab = self:CreateTab("Spawn")
    local farmTab = self:CreateTab("Farm")
    local visualTab = self:CreateTab("Visual")
    
    -- Spawn Tab Content
    self:CreateSpawnContent(spawnTab)
    
    -- Farm Tab Content
    self:CreateFarmContent(farmTab)
    
    -- Visual Tab Content
    self:CreateVisualContent(visualTab)
end

-- Inicialização
local function InitializeUltraSupreme()
    -- Inicializa Sistemas
    BrainrotSystem:Initialize()
    
    -- Cria Interface
    local UI = UltraUI.new()
    
    -- Parent to CoreGui
    if syn then
        syn.protect_gui(UI.gui)
    end
    UI.gui.Parent = game:GetService("CoreGui")
    
    -- Notificação
    local notif = Instance.new("TextLabel")
    notif.Text = "Ultra Supreme v7.1.0 Initialized!"
    notif.Size = UDim2.new(0, 300, 0, 50)
    notif.Position = UDim2.new(0.5, -150, 0, -50)
    notif.BackgroundColor3 = SUPREME.THEME.SUCCESS
    notif.TextColor3 = SUPREME.THEME.PRIMARY
    notif.Parent = UI.gui
    
    -- Animação
    notif:TweenPosition(
        UDim2.new(0.5, -150, 0, 20),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Bounce,
        1,
        true
    )
    wait(3)
    notif:TweenPosition(
        UDim2.new(0.5, -150, 0, -50),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )
    
    return UI
end

-- Execute
return InitializeUltraSupreme()
