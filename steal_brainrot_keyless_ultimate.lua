--[[
    Steal a Brainrot - Elite Edition V4 COMPLETE
    Autor: math741
    Versão: 4.0.1
    Última atualização: 2025-08-22 16:02:57 UTC
]]

-- Proteção Inicial e Variáveis Globais
local startTime = os.time()
local brainrotCache = {}
local farmEnabled = false
local espEnabled = false
local autoSpawnEnabled = false

-- Serviços com Cache
local Services = setmetatable({}, {
    __index = function(self, key)
        local service = game:GetService(key)
        self[key] = service
        return service
    end
})

-- Configurações
local CONFIG = {
    VERSAO = "4.0.1",
    AUTOR = "math741",
    DATA = "2025-08-22 16:02:57",
    TEMA = {
        BACKGROUND = Color3.fromRGB(25, 25, 35),
        FOREGROUND = Color3.fromRGB(35, 35, 45),
        ACCENT = Color3.fromRGB(255, 70, 70),
        TEXT = Color3.fromRGB(255, 255, 255),
        BORDER = Color3.fromRGB(60, 60, 70)
    },
    BRAINROTS = {
        "Tung Tung Tung Sahur",
        "La Vacca Saturno Saturnita",
        "Los Tralalleritos",
        "Baby Gronk",
        "Sammyni Spiderini",
        "Brainrot Mutant",
        "Secret Brainrot 1",
        "Secret Brainrot 2"
    },
    MUTACOES = {
        "Bloodrot",
        "Galactic",
        "Nyan Cat",
        "Lava",
        "Rainbow",
        "Golden",
        "Dark",
        "Crystal"
    }
}

-- Sistema de Logs
local Logger = {
    logs = {},
    maxLogs = 1000
}

function Logger:Add(tipo, mensagem)
    local log = {
        timestamp = os.date("%H:%M:%S"),
        tipo = tipo,
        mensagem = mensagem
    }
    table.insert(self.logs, 1, log)
    if #self.logs > self.maxLogs then
        table.remove(self.logs)
    end
    return log
end

-- Funções do Brainrot
local BrainrotFunctions = {}

function BrainrotFunctions:EncontrarRemote(nome)
    if brainrotCache[nome] then
        return brainrotCache[nome]
    end
    
    for _, obj in pairs(Services.ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and 
            obj.Name:lower():find(nome:lower()) then
            brainrotCache[nome] = obj
            return obj
        end
    end
    return nil
end

function BrainrotFunctions:Spawn(tipo, mutacao)
    local remote = self:EncontrarRemote("spawn") or self:EncontrarRemote("brainrot")
    if remote then
        local success, result = pcall(function()
            remote:FireServer(tipo, mutacao)
        end)
        if success then
            Logger:Add("Sucesso", "Brainrot spawned: " .. tipo .. " com mutação " .. mutacao)
            return true
        else
            Logger:Add("Erro", "Falha ao spawnar: " .. result)
        end
    end
    return false
end

function BrainrotFunctions:AutoFarm()
    if not farmEnabled then return end
    
    spawn(function()
        while farmEnabled do
            pcall(function()
                local char = Services.Players.LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, obj in pairs(Services.Workspace:GetDescendants()) do
                        if farmEnabled and obj:IsA("Part") and obj.Name:lower():find("cash") then
                            local hrp = char.HumanoidRootPart
                            hrp.CFrame = obj.CFrame
                            wait(0.1)
                            firetouchinterest(hrp, obj, 0)
                            firetouchinterest(hrp, obj, 1)
                            wait(0.2)
                        end
                    end
                end
            end)
            wait(0.5)
        end
    end)
end

function BrainrotFunctions:ToggleESP(enabled)
    espEnabled = enabled
    
    if enabled then
        spawn(function()
            while espEnabled do
                pcall(function()
                    for _, obj in pairs(Services.Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
                            if not obj:FindFirstChild("ESP") then
                                local esp = Instance.new("BillboardGui")
                                esp.Name = "ESP"
                                esp.Size = UDim2.new(0, 100, 0, 40)
                                esp.AlwaysOnTop = true
                                esp.Parent = obj
                                
                                local label = Instance.new("TextLabel")
                                label.Size = UDim2.new(1, 0, 1, 0)
                                label.BackgroundTransparency = 1
                                label.TextColor3 = CONFIG.TEMA.ACCENT
                                label.Text = obj.Name
                                label.TextSize = 14
                                label.Font = Enum.Font.GothamBold
                                label.Parent = esp
                            end
                        end
                    end
                end)
                wait(1)
            end
        end)
    else
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
                local esp = obj:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end

function BrainrotFunctions:AutoSpawn()
    if not autoSpawnEnabled then return end
    
    spawn(function()
        while autoSpawnEnabled do
            local tipo = CONFIG.BRAINROTS[math.random(1, #CONFIG.BRAINROTS)]
            local mutacao = CONFIG.MUTACOES[math.random(1, #CONFIG.MUTACOES)]
            self:Spawn(tipo, mutacao)
            wait(5)
        end
    end)
end

-- Interface Elite
local EliteUI = {}
EliteUI.__index = EliteUI

function EliteUI.new()
    local self = setmetatable({}, EliteUI)
    
    -- ScreenGui base
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "EliteUI"
    self.gui.ResetOnSpawn = false
    
    -- Frame principal
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = CONFIG.TEMA.BACKGROUND
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Adicionar elementos visuais...
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.mainFrame
    
    -- Sistema de abas
    self.tabButtons = Instance.new("Frame")
    self.tabButtons.Name = "TabButtons"
    self.tabButtons.Size = UDim2.new(0, 150, 1, 0)
    self.tabButtons.BackgroundColor3 = CONFIG.TEMA.FOREGROUND
    self.tabButtons.BorderSizePixel = 0
    self.tabButtons.Parent = self.mainFrame
    
    -- Conteúdo
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "Content"
    self.contentFrame.Size = UDim2.new(1, -160, 1, -20)
    self.contentFrame.Position = UDim2.new(0, 155, 0, 10)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Parent = self.mainFrame
    
    return self
end

-- Criar interface e adicionar funcionalidades
local UI = EliteUI.new()
UI.gui.Parent = game:GetService("CoreGui")

-- Criar abas
local mainTab = UI:CreateTab("Principal")
local farmTab = UI:CreateTab("Farm")
local visualTab = UI:CreateTab("Visual")
local configTab = UI:CreateTab("Config")

-- Adicionar elementos à aba Principal
local selectedBrainrot = CONFIG.BRAINROTS[1]
local selectedMutation = CONFIG.MUTACOES[1]

-- Dropdown Brainrot
UI:CreateDropdown(mainTab, "Selecionar Brainrot", CONFIG.BRAINROTS, function(selected)
    selectedBrainrot = selected
end)

-- Dropdown Mutação
UI:CreateDropdown(mainTab, "Selecionar Mutação", CONFIG.MUTACOES, function(selected)
    selectedMutation = selected
end)

-- Botão Spawn
UI:CreateButton(mainTab, "Spawnar Brainrot", function()
    BrainrotFunctions:Spawn(selectedBrainrot, selectedMutation)
end)

-- Toggle Auto Spawn
UI:CreateToggle(mainTab, "Auto Spawn", false, function(enabled)
    autoSpawnEnabled = enabled
    if enabled then
        BrainrotFunctions:AutoSpawn()
    end
end)

-- Aba Farm
UI:CreateToggle(farmTab, "Auto Farm", false, function(enabled)
    farmEnabled = enabled
    if enabled then
        BrainrotFunctions:AutoFarm()
    end
end)

-- Aba Visual
UI:CreateToggle(visualTab, "ESP Brainrot", false, function(enabled)
    BrainrotFunctions:ToggleESP(enabled)
end)

-- Aba Config
UI:CreateButton(configTab, "Limpar Logs", function()
    Logger.logs = {}
end)

UI:CreateButton(configTab, "Copiar Logs", function()
    if setclipboard then
        local logText = ""
        for _, log in ipairs(Logger.logs) do
            logText = logText .. string.format("[%s] %s: %s\n", 
                log.timestamp, log.tipo, log.mensagem)
        end
        setclipboard(logText)
    end
end)

-- Sistema Anti-Detecção
local antiDetect = {}

function antiDetect:Init()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" then
            local args = {...}
            if typeof(args[1]) == "string" and args[1]:lower():find("detect") then
                return wait(9e9)
            end
        end
        return old(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- Inicialização
do
    antiDetect:Init()
    Logger:Add("Info", "Script iniciado com sucesso!")
    
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        if farmEnabled then
            BrainrotFunctions:AutoFarm()
        end
        if espEnabled then
            BrainrotFunctions:ToggleESP(true)
        end
    end)
end

return UI
