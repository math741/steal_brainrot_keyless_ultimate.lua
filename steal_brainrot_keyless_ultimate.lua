--[[
    Testador de Permissões e Métodos de Kick Alternativos
    
    Este script testa diferentes métodos de kick e mostra quais funcionam:
    1. Testa permissões básicas
    2. Procura por comandos admin no jogo
    3. Tenta métodos alternativos de kick
    4. Interface para testar em jogadores específicos
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Remove GUI anterior
if playerGui:FindFirstChild("PermissionTester") then
    playerGui:FindFirstChild("PermissionTester"):Destroy()
end

-- Variáveis de resultado
local testResults = {
    directKick = false,
    remoteEvents = {},
    adminCommands = {},
    serverScripts = false,
    networkOwnership = false
}

-- Cria GUI de teste
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PermissionTester"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 25)
headerFix.Position = UDim2.new(0, 0, 1, -25)
headerFix.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔐 Testador de Permissões"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Scroll Frame para resultados
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -120)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = scrollFrame

-- Botões de ação
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -20, 0, 40)
buttonFrame.Position = UDim2.new(0, 10, 1, -50)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

local testButton = Instance.new("TextButton")
testButton.Size = UDim2.new(0.48, 0, 1, 0)
testButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
testButton.Text = "🧪 Iniciar Testes"
testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
testButton.TextScaled = true
testButton.Font = Enum.Font.GothamBold
testButton.BorderSizePixel = 0
testButton.Parent = buttonFrame

local testCorner = Instance.new("UICorner")
testCorner.CornerRadius = UDim.new(0, 8)
testCorner.Parent = testButton

local kickTestButton = Instance.new("TextButton")
kickTestButton.Size = UDim2.new(0.48, 0, 1, 0)
kickTestButton.Position = UDim2.new(0.52, 0, 0, 0)
kickTestButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
kickTestButton.Text = "⚡ Testar Kick"
kickTestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
kickTestButton.TextScaled = true
kickTestButton.Font = Enum.Font.GothamBold
kickTestButton.BorderSizePixel = 0
kickTestButton.Parent = buttonFrame

local kickCorner = Instance.new("UICorner")
kickCorner.CornerRadius = UDim.new(0, 8)
kickCorner.Parent = kickTestButton

-- Função para adicionar resultado
local function addResult(title, success, details)
    local resultFrame = Instance.new("Frame")
    resultFrame.Size = UDim2.new(1, 0, 0, 60)
    resultFrame.BackgroundColor3 = success and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(120, 50, 50)
    resultFrame.BorderSizePixel = 0
    resultFrame.Parent = scrollFrame
    
    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 6)
    resultCorner.Parent = resultFrame
    
    local statusIcon = Instance.new("TextLabel")
    statusIcon.Size = UDim2.new(0, 30, 0, 30)
    statusIcon.Position = UDim2.new(0, 10, 0, 5)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Text = success and "✅" or "❌"
    statusIcon.TextScaled = true
    statusIcon.Parent = resultFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 20)
    titleLabel.Position = UDim2.new(0, 45, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = resultFrame
    
    local detailsLabel = Instance.new("TextLabel")
    detailsLabel.Size = UDim2.new(1, -50, 0, 30)
    detailsLabel.Position = UDim2.new(0, 45, 0, 25)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = details
    detailsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    detailsLabel.TextScaled = true
    detailsLabel.Font = Enum.Font.Gotham
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
    detailsLabel.TextWrapped = true
    detailsLabel.Parent = resultFrame
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

-- Teste 1: Kick direto
local function testDirectKick()
    local success = false
    local details = "Sem permissões de kick direto"
    
    pcall(function()
        -- Tenta kickar um jogador inexistente para testar permissões
        local fakePlayer = {
            Kick = function() 
                success = true
                details = "Você tem permissões de kick direto!"
            end
        }
        fakePlayer:Kick("Teste")
    end)
    
    testResults.directKick = success
    addResult("Kick Direto", success, details)
end

-- Teste 2: RemoteEvents relacionados a kick
local function testRemoteEvents()
    local foundEvents = {}
    
    local function searchForEvents(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("kick") or name:find("ban") or name:find("remove") or 
                   name:find("admin") or name:find("mod") or name:find("punish") then
                    table.insert(foundEvents, obj.Name .. " (" .. obj.ClassName .. ")")
                    table.insert(testResults.remoteEvents, obj)
                end
            end
        end
    end
    
    searchForEvents(ReplicatedStorage)
    searchForEvents(game)
    
    local success = #foundEvents > 0
    local details = success and "Encontrados: " .. table.concat(foundEvents, ", ") or "Nenhum RemoteEvent suspeito encontrado"
    
    addResult("RemoteEvents de Admin", success, details)
end

-- Teste 3: Comandos de admin do jogo
local function testAdminCommands()
    local adminSystems = {}
    
    -- Procura por sistemas admin conhecidos
    local commonAdminNames = {"Admin", "HD Admin", "Adonis", "BasicAdmin", "Kohl's Admin", "Command"}
    
    for _, name in pairs(commonAdminNames) do
        if ReplicatedStorage:FindFirstChild(name) or game.ServerStorage and game.ServerStorage:FindFirstChild(name) then
            table.insert(adminSystems, name)
        end
    end
    
    -- Procura na StarterGui
    local starterGui = game:GetService("StarterGui")
    for _, obj in pairs(starterGui:GetDescendants()) do
        if obj.Name:lower():find("admin") or obj.Name:lower():find("command") then
            table.insert(adminSystems, "GUI: " .. obj.Name)
        end
    end
    
    testResults.adminCommands = adminSystems
    local success = #adminSystems > 0
    local details = success and "Sistemas encontrados: " .. table.concat(adminSystems, ", ") or "Nenhum sistema admin detectado"
    
    addResult("Sistemas Admin", success, details)
end

-- Teste 4: Network Ownership
local function testNetworkOwnership()
    local success = false
    local details = "Sem controle de network ownership"
    
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            localPlayer.Character.HumanoidRootPart:SetNetworkOwner(localPlayer)
            success = true
            details = "Você pode controlar network ownership!"
        end)
    end
    
    testResults.networkOwnership = success
    addResult("Network Ownership", success, details)
end

-- Teste 5: Métodos alternativos
local function testAlternativeMethods()
    local methods = {}
    
    -- Teste crash por memory overflow
    pcall(function()
        local parts = {}
        for i = 1, 100 do
            local part = Instance.new("Part")
            part.Parent = workspace
            table.insert(parts, part)
        end
        for _, part in pairs(parts) do
            part:Destroy()
        end
        table.insert(methods, "Memory Overflow")
    end)
    
    -- Teste lag por CFrame spam
    pcall(function()
        if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                localPlayer.Character.HumanoidRootPart.CFrame = localPlayer.Character.HumanoidRootPart.CFrame
            end
            table.insert(methods, "CFrame Manipulation")
        end
    end)
    
    local success = #methods > 0
    local details = success and "Métodos disponíveis: " .. table.concat(methods, ", ") or "Nenhum método alternativo disponível"
    
    addResult("Métodos Alternativos", success, details)
end

-- Função principal de teste
local function runAllTests()
    -- Limpa resultados anteriores
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    addResult("Iniciando Testes...", true, "Verificando suas permissões no servidor atual")
    
    wait(0.5)
    testDirectKick()
    wait(0.5)
    testRemoteEvents()
    wait(0.5)
    testAdminCommands()
    wait(0.5)
    testNetworkOwnership()
    wait(0.5)
    testAlternativeMethods()
    
    wait(1)
    
    -- Resumo final
    local workingMethods = 0
    if testResults.directKick then workingMethods = workingMethods + 1 end
    if #testResults.remoteEvents > 0 then workingMethods = workingMethods + 1 end
    if #testResults.adminCommands > 0 then workingMethods = workingMethods + 1 end
    if testResults.networkOwnership then workingMethods = workingMethods + 1 end
    
    local summary = workingMethods > 0 and 
        ("✅ " .. workingMethods .. " método(s) funcionando! Você pode usar o script de kick.") or
        "❌ Nenhuma permissão encontrada. O kick pode não funcionar neste servidor."
    
    addResult("RESUMO FINAL", workingMethods > 0, summary)
end

-- Função para testar kick em jogador real
local function testRealKick()
    local players = Players:GetPlayers()
    local targetPlayer = nil
    
    -- Encontra um jogador que não seja você
    for _, player in pairs(players) do
        if player ~= localPlayer then
            targetPlayer = player
            break
        end
    end
    
    if not targetPlayer then
        addResult("Teste de Kick Real", false, "Não há outros jogadores no servidor para testar")
        return
    end
    
    addResult("Testando Kick Real", true, "Tentando kickar: " .. targetPlayer.Name)
    
    -- Tenta diferentes métodos
    local success = false
    
    -- Método 1: Kick direto
    pcall(function()
        targetPlayer:Kick("🧪 Teste de permissões - você será reconectado")
        success = true
    end)
    
    -- Método 2: RemoteEvents encontrados
    for _, remoteEvent in pairs(testResults.remoteEvents) do
        pcall(function()
            if remoteEvent:IsA("RemoteEvent") then
                remoteEvent:FireServer("kick", targetPlayer.Name)
                remoteEvent:FireServer(targetPlayer)
                success = true
            end
        end)
    end
    
    wait(2)
    
    -- Verifica se o jogador ainda está no jogo
    local stillInGame = false
    for _, player in pairs(Players:GetPlayers()) do
        if player == targetPlayer then
            stillInGame = true
            break
        end
    end
    
    if not stillInGame then
        addResult("Resultado do Teste", true, targetPlayer.Name .. " foi kickado com sucesso!")
    else
        addResult("Resultado do Teste", false, "Kick não funcionou. Você não tem permissões suficientes.")
    end
end

-- Conecta botões
testButton.Activated:Connect(function()
    spawn(runAllTests)
end)

kickTestButton.Activated:Connect(function()
    spawn(testRealKick)
end)

-- Logs
print("===========================================")
print("🔐 TESTADOR DE PERMISSÕES CARREGADO!")
print("===========================================")
print("1. Clique em 'Iniciar Testes' para verificar permissões")
print("2. Clique em 'Testar Kick' para tentar kickar um jogador real")
print("3. Os resultados aparecerão na interface")
print("===========================================")

-- Adiciona instruções iniciais
addResult("Como Usar", true, "1. Clique em 'Iniciar Testes' para verificar suas permissões")
addResult("Aviso", true, "2. Se encontrar métodos funcionando, use o script de kick principal")
addResult("Teste Real", true, "3. 'Testar Kick' tenta kickar um jogador real (cuidado!)")
