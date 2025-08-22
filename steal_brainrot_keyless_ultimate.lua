-- Script Lua para Delta Executor (Gratuito) - Steal a Brainrot (Spawnar Brainrots com Mutações, Keyless, Seguro)
-- Aviso: Usar scripts viola os Termos de Serviço do Roblox. Use em conta alternativa!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Lista expandida de Brainrots
local brainrotList = {
    "Tung Tung Tung Sahur",
    "La Vacca Saturno Saturnita",
    "Los Tralalleritos",
    "Baby Gronk",
    "Sammyni Spiderini",
    "Brainrot Mutant",
    "Secret Brainrot 1",
    "Secret Brainrot 2",
    -- Adicione mais nomes encontrados pelo Dex Explorer
}

-- Lista de mutações conhecidas
local mutationList = {
    "Bloodrot",
    "Galactic",
    "Nyan Cat",
    "Lava",
    "Rainbow",
    "Golden",
    "Dark",
    "Crystal",
    -- Adicione mais mutações encontradas pelo Dex Explorer
}

-- Lista de eventos conhecidos
local eventList = {
    "Bloodmoon",
    "Lava",
    "Rainbow",
    "Galaxy",
    "Nyan Cat",
    "Golden",
    "Dark",
    "Crystal",
    -- Adicione mais eventos encontrados pelo Dex Explorer
}

-- Lista para armazenar logs
local logs = { Remotes = {}, Brainrots = {}, Mutations = {}, Automation = {}, Errors = {} }

-- Função para adicionar logs
local function addLog(category, message)
    table.insert(logs[category], os.date("%H:%M:%S") .. " - " .. message)
    if #logs[category] > 50 then -- Limita logs por categoria
        table.remove(logs[category], 1)
    end
end

-- Função para exibir notificações
local function notify(title, message, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = message,
            Duration = duration or 5
        })
        addLog("Automation", "Notificação: " .. message)
    end)
end

-- Função para listar todos os Remote Events e Remote Functions
local function listRemotes()
    local remotes = {}
    local services = {ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage")}
    for _, service in pairs(services) do
        pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj.Name .. " (" .. obj.ClassName .. ") em " .. service.Name)
                    addLog("Remotes", "Encontrado: " .. obj.Name .. " (" .. obj.ClassName .. ") em " .. service.Name)
                end
            end
        end)
    end
    return remotes
end

-- Função para explorar o Workspace (Brainrots, Conveyor, Mutações)
local function exploreWorkspace()
    local objects = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
            table.insert(objects, obj.Name .. " (Model) em " .. obj:GetFullName())
            addLog("Brainrots", "Encontrado: " .. obj.Name .. " em " .. obj:GetFullName())
        elseif obj:IsA("Part") and obj.Name:lower():find("conveyor") then
            table.insert(objects, obj.Name .. " (Conveyor Belt) em " .. obj:GetFullName())
            addLog("Brainrots", "Conveyor encontrado: " .. obj.Name .. " em " .. obj:GetFullName())
        end
    end
    return objects
end

-- Função para encontrar um Remote específico
local function findRemote(name)
    local services = {ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage")}
    for _, service in pairs(services) do
        local success, result = pcall(function()
            for _, obj in pairs(service:GetDescendants()) do
                if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower():find(name:lower()) then
                    return obj
                end
            end
        end)
        if success and result then
            return result
        end
    end
    return nil
end

-- Função para disparar um Remote Event/Function com bypass
local function triggerRemote(remoteName, ...)
    local remote = findRemote(remoteName)
    if remote then
        pcall(function()
            wait(math.random(0.1, 0.5)) -- Delay aleatório para bypass
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
                notify("Sucesso", "Disparado " .. remoteName, 3)
                addLog("Automation", "Disparado Remote: " .. remoteName)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
                notify("Sucesso", "Invocado " .. remoteName, 3)
                addLog("Automation", "Invocado Remote: " .. remoteName)
            end
        end)
    else
        notify("Erro", "Remote " .. remoteName .. " não encontrado! Use Dex Explorer.", 5)
        addLog("Errors", "Remote " .. remoteName .. " não encontrado")
    end
end

-- Função para spawnar um Brainrot com mutação específica
local function spawnBrainrot(brainrotName, mutation)
    local spawnRemote = findRemote("spawn") or findRemote("brainrot") or findRemote("mutation")
    if spawnRemote then
        pcall(function()
            triggerRemote(spawnRemote.Name, brainrotName, mutation)
            addLog("Brainrots", "Tentou spawnar: " .. brainrotName .. " com mutação: " .. mutation)
        end)
        return
    end

    -- Alternativa: Clonar um Brainrot existente no Workspace
    local brainrot = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(brainrotName:lower()) then
            brainrot = obj
            break
        end
    end
    if brainrot then
        pcall(function()
            local clone = brainrot:Clone()
            clone.Parent = Workspace
            clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
            local mutationRemote = findRemote(mutation:lower()) or findRemote("mutation")
            if mutationRemote then
                triggerRemote(mutationRemote.Name, clone, mutation)
            end
            notify("Sucesso", "Clone de " .. brainrotName .. " criado com mutação: " .. mutation, 5)
            addLog("Brainrots", "Clone criado: " .. brainrotName .. " com mutação: " .. mutation)
        end)
    else
        notify("Erro", "Brainrot " .. brainrotName .. " não encontrado! Use Dex Explorer.", 5)
        addLog("Errors", "Brainrot " .. brainrotName .. " não encontrado")
    end
end

-- Função para ESP (highlight visual para Brainrots)
local espEnabled = false
local function toggleESP(state)
    espEnabled = state
    if state then
        addLog("Automation", "ESP ativado")
        spawn(function()
            while espEnabled do
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = obj
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                            highlight.Parent = obj
                            addLog("Brainrots", "ESP aplicado: " .. obj.Name)
                        end
                    end
                end)
                wait(1)
            end
            for _, obj in pairs(Workspace:GetDescendants()) do
                for _, highlight in pairs(obj:GetChildren()) do
                    if highlight:IsA("Highlight") then
                        highlight:Destroy()
                    end
                end
            end
            addLog("Automation", "ESP desativado")
        end)
    end
end

-- Função para Auto Collect (coletar moeda automaticamente)
local autoCollectEnabled = false
local function toggleAutoCollect(state)
    autoCollectEnabled = state
    if state then
        addLog("Automation", "Auto Collect ativado")
        spawn(function()
            while autoCollectEnabled do
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Name:lower():find("cash") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                            wait(math.random(0.2, 0.5)) -- Delay para bypass
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            addLog("Automation", "Coletado: " .. obj.Name)
                        end
                    end
                end)
                wait(0.5)
            end
            addLog("Automation", "Auto Collect desativado")
        end)
    end
end

-- Função para Auto Steal (roubar Brainrots de outros jogadores)
local autoStealEnabled = false
local function toggleAutoSteal(state)
    autoStealEnabled = state
    if state then
        addLog("Automation", "Auto Steal ativado")
        spawn(function()
            while autoStealEnabled do
                pcall(function()
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local base = Workspace:FindFirstChild(player.Name .. "_Base")
                            if base then
                                for _, brainrot in pairs(base:GetDescendants()) do
                                    if brainrot:IsA("Model") and brainrot.Name:lower():find("brainrot") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = brainrot:GetPrimaryPartCFrame()
                                        wait(math.random(0.2, 0.5)) -- Delay para bypass
                                        local stealRemote = findRemote("steal")
                                        if stealRemote then
                                            triggerRemote(stealRemote.Name, brainrot)
                                        end
                                        addLog("Automation", "Tentou roubar: " .. brainrot.Name .. " de " .. player.Name)
                                    end
                                end
                            end
                        end
                    end
                end)
                wait(1)
            end
            addLog("Automation", "Auto Steal desativado")
        end)
    end
end

-- Função para monitorar eventos
local function monitorEvents()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name:lower():find("bloodmoon") or child.Name:lower():find("event") then
            notify("Evento Detectado", "Evento " .. child.Name .. " iniciado!", 5)
            addLog("Automation", "Evento detectado: " .. child.Name)
            triggerRemote("bloodmoon")
        end
    end)
end

-- Interface Gráfica com Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
    Name = "Steal a Brainrot - Keyless Ultimate",
    LoadingTitle = "Carregando Script",
    LoadingSubtitle = "by xAI",
})

local MainTab = Window:CreateTab("Main", nil)
local AutomationTab = Window:CreateTab("Automation", nil)
local LogTab = Window:CreateTab("Logs", nil)

-- Seção de logs
local LogRemotesLabel = LogTab:CreateLabel("Remotes (atualiza automaticamente)")
local LogBrainrotsLabel = LogTab:CreateLabel("Brainrots (atualiza automaticamente)")
local LogMutationsLabel = LogTab:CreateLabel("Mutações (atualiza automaticamente)")
local LogAutomationLabel = LogTab:CreateLabel("Automação (atualiza automaticamente)")
local LogErrorsLabel = LogTab:CreateLabel("Erros (atualiza automaticamente)")

-- Função para atualizar os logs na interface
local function updateLogs()
    LogRemotesLabel:Set(table.concat(logs.Remotes, "\n"))
    LogBrainrotsLabel:Set(table.concat(logs.Brainrots, "\n"))
    LogMutationsLabel:Set(table.concat(logs.Mutations, "\n"))
    LogAutomationLabel:Set(table.concat(logs.Automation, "\n"))
    LogErrorsLabel:Set(table.concat(logs.Errors, "\n"))
end

-- Botão para copiar logs
LogTab:CreateButton({
    Name = "Copiar Todos os Logs",
    Callback = function()
        if setclipboard then
            local allLogs = "Remotes:\n" .. table.concat(logs.Remotes, "\n") .. "\n\nBrainrots:\n" .. table.concat(logs.Brainrots, "\n") .. "\n\nMutações:\n" .. table.concat(logs.Mutations, "\n") .. "\n\nAutomação:\n" .. table.concat(logs.Automation, "\n") .. "\n\nErros:\n" .. table.concat(logs.Errors, "\n")
            setclipboard(allLogs)
            notify("Sucesso", "Logs copiados para a área de transferência!", 5)
            addLog("Automation", "Logs copiados para a área de transferência")
        else
            notify("Erro", "Função setclipboard não suportada!", 5)
            addLog("Errors", "setclipboard não suportado")
        end
        updateLogs()
    end
})

-- Botão para listar Remote Events/Functions
MainTab:CreateButton({
    Name = "Listar Todos os Remotes (use Dex Explorer para mais detalhes)",
    Callback = function()
        local remotes = listRemotes()
        if #remotes > 0 then
            local remoteList = table.concat(remotes, "\n")
            notify("Remotes Encontrados", remoteList, 10)
            addLog("Remotes", "Remotes listados:\n" .. remoteList)
        else
            notify("Erro", "Nenhum Remote encontrado! Use Dex Explorer.", 5)
            addLog("Errors", "Nenhum Remote encontrado")
        end
        updateLogs()
    end
})

-- Botão para explorar o Workspace
MainTab:CreateButton({
    Name = "Explorar Workspace (Brainrots/Conveyor)",
    Callback = function()
        local objects = exploreWorkspace()
        if #objects > 0 then
            local objectList = table.concat(objects, "\n")
            notify("Objetos Encontrados", objectList, 10)
            addLog("Brainrots", "Objetos listados:\n" .. objectList)
        else
            notify("Erro", "Nenhum Brainrot ou Conveyor encontrado!", 5)
            addLog("Errors", "Nenhum Brainrot ou Conveyor encontrado")
        end
        updateLogs()
    end
})

-- Dropdown para disparar eventos
MainTab:CreateDropdown({
    Name = "Disparar Evento",
    Options = eventList,
    CurrentOption = eventList[1],
    Callback = function(option)
        triggerRemote(option)
        updateLogs()
    end
})

-- Dropdowns para spawnar Brainrot com mutação
local selectedBrainrot = brainrotList[1]
local selectedMutation = mutationList[1]

MainTab:CreateDropdown({
    Name = "Selecionar Brainrot",
    Options = brainrotList,
    CurrentOption = brainrotList[1],
    Callback = function(option)
        selectedBrainrot = option
        addLog("Brainrots", "Brainrot selecionado: " .. option)
        updateLogs()
    end
})

MainTab:CreateDropdown({
    Name = "Selecionar Mutação",
    Options = mutationList,
    CurrentOption = mutationList[1],
    Callback = function(option)
        selectedMutation = option
        addLog("Mutations", "Mutação selecionada: " .. option)
        updateLogs()
    end
})

MainTab:CreateButton({
    Name = "Spawnar Brainrot com Mutação",
    Callback = function()
        spawnBrainrot(selectedBrainrot, selectedMutation)
        updateLogs()
    end
})

-- Campo de texto para disparar Remote personalizado
MainTab:CreateInput({
    Name = "Disparar Remote Personalizado (ex.: SpawnBrainrot)",
    PlaceholderText = "Digite o nome do Remote",
    Callback = function(text)
        if text ~= "" then
            triggerRemote(text)
        else
            notify("Erro", "Digite um nome de Remote válido!", 5)
            addLog("Errors", "Nome de Remote inválido")
        end
        updateLogs()
    end
})

-- Toggles para automação
AutomationTab:CreateToggle({
    Name = "Ativar ESP (Highlight Brainrots)",
    CurrentValue = false,
    Callback = function(state)
        toggleESP(state)
        updateLogs()
    end
})

AutomationTab:CreateToggle({
    Name = "Ativar Auto Collect (Coletar Moeda)",
    CurrentValue = false,
    Callback = function(state)
        toggleAutoCollect(state)
        updateLogs()
    end
})

AutomationTab:CreateToggle({
    Name = "Ativar Auto Steal (Roubar Brainrots)",
    CurrentValue = false,
    Callback = function(state)
        toggleAutoSteal(state)
        updateLogs()
    end
})

AutomationTab:CreateToggle({
    Name = "Monitorar Eventos",
    CurrentValue = false,
    Callback = function(state)
        if state then
            notify("Monitoramento", "Monitorando eventos (ex.: Bloodmoon)...", 5)
            addLog("Automation", "Monitoramento de eventos ativado")
            monitorEvents()
        else
            addLog("Automation", "Monitoramento de eventos desativado")
        end
        updateLogs()
    end
})

-- Atualizar logs periodicamente
spawn(function()
    while wait(1) do
        updateLogs()
    end
end)

-- Inicialização
notify("Script Carregado", "Script Keyless Ultimate para Steal a Brainrot iniciado!", 5)
addLog("Automation", "Script iniciado")

-- Verifica se o jogador está no jogo
if game.PlaceId == 126884695634066 then -- ID do Steal a Brainrot
    Rayfield:Load()
else
    notify("Erro", "Este script é para Steal a Brainrot! Jogo incorreto.", 10)
    addLog("Errors", "Jogo incorreto (PlaceId: " .. game.PlaceId .. ")")
end

-- Loop para manter o script ativo
while wait(1) do
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        notify("Aviso", "Aguardando personagem carregar...", 3)
        addLog("Errors", "Aguardando personagem carregar")
    end
end