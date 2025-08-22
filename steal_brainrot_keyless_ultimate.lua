-- Script Lua para Delta Executor (Gratuito) - Steal a Brainrot (Spawnar Brainrots com Mutações, Keyless, Seguro)
-- Aviso: Usar scripts viola os Termos de Serviço do Roblox. Use em conta alternativa!

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Listas de opções
local listaBrainrots = {
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

local listaMutacoes = {
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

local listaEventos = {
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

-- Estrutura para logs
local logs = { Remotes = {}, Brainrots = {}, Mutacoes = {}, Automacao = {}, Erros = {} }

local function adicionarLog(categoria, mensagem)
    table.insert(logs[categoria], os.date("%H:%M:%S") .. " - " .. mensagem)
    if #logs[categoria] > 50 then
        table.remove(logs[categoria], 1)
    end
end

local function notificar(titulo, mensagem, duracao)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titulo,
            Text = mensagem,
            Duration = duracao or 5
        })
        adicionarLog("Automacao", "Notificação: " .. mensagem)
    end)
end

local function listarRemotes()
    local remotes = {}
    local servicos = {ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage")}
    for _, servico in pairs(servicos) do
        pcall(function()
            for _, obj in pairs(servico:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(remotes, obj.Name .. " (" .. obj.ClassName .. ") em " .. servico.Name)
                    adicionarLog("Remotes", "Encontrado: " .. obj.Name .. " (" .. obj.ClassName .. ") em " .. servico.Name)
                end
            end
        end)
    end
    return remotes
end

local function explorarWorkspace()
    local objetos = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
            table.insert(objetos, obj.Name .. " (Model) em " .. obj:GetFullName())
            adicionarLog("Brainrots", "Encontrado: " .. obj.Name .. " em " .. obj:GetFullName())
        elseif obj:IsA("Part") and obj.Name:lower():find("conveyor") then
            table.insert(objetos, obj.Name .. " (Conveyor) em " .. obj:GetFullName())
            adicionarLog("Brainrots", "Conveyor encontrado: " .. obj.Name .. " em " .. obj:GetFullName())
        end
    end
    return objetos
end

local function encontrarRemote(nome)
    local servicos = {ReplicatedStorage, game:GetService("ServerScriptService"), game:GetService("ServerStorage")}
    for _, servico in pairs(servicos) do
        local sucesso, resultado = pcall(function()
            for _, obj in pairs(servico:GetDescendants()) do
                if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower():find(nome:lower()) then
                    return obj
                end
            end
        end)
        if sucesso and resultado then
            return resultado
        end
    end
    return nil
end

local function acionarRemote(nomeRemote, ...)
    local remote = encontrarRemote(nomeRemote)
    if remote then
        pcall(function()
            wait(math.random(0.1, 0.5))
            if remote:IsA("RemoteEvent") then
                remote:FireServer(...)
                notificar("Sucesso", "Disparado " .. nomeRemote, 3)
                adicionarLog("Automacao", "Disparado Remote: " .. nomeRemote)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(...)
                notificar("Sucesso", "Invocado " .. nomeRemote, 3)
                adicionarLog("Automacao", "Invocado Remote: " .. nomeRemote)
            end
        end)
    else
        notificar("Erro", "Remote " .. nomeRemote .. " não encontrado! Use Dex Explorer.", 5)
        adicionarLog("Erros", "Remote " .. nomeRemote .. " não encontrado")
    end
end

local function spawnarBrainrot(nomeBrainrot, mutacao)
    local spawnRemote = encontrarRemote("spawn") or encontrarRemote("brainrot") or encontrarRemote("mutation")
    if spawnRemote then
        pcall(function()
            acionarRemote(spawnRemote.Name, nomeBrainrot, mutacao)
            adicionarLog("Brainrots", "Tentou spawnar: " .. nomeBrainrot .. " com mutação: " .. mutacao)
        end)
        return
    end

    -- Alternativa: clonar Brainrot do workspace
    local brainrot = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(nomeBrainrot:lower()) then
            brainrot = obj
            break
        end
    end
    if brainrot then
        pcall(function()
            local clone = brainrot:Clone()
            clone.Parent = Workspace
            clone:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
            local mutationRemote = encontrarRemote(mutacao:lower()) or encontrarRemote("mutation")
            if mutationRemote then
                acionarRemote(mutationRemote.Name, clone, mutacao)
            end
            notificar("Sucesso", "Clone de " .. nomeBrainrot .. " criado com mutação: " .. mutacao, 5)
            adicionarLog("Brainrots", "Clone criado: " .. nomeBrainrot .. " com mutação: " .. mutacao)
        end)
    else
        notificar("Erro", "Brainrot " .. nomeBrainrot .. " não encontrado! Use Dex Explorer.", 5)
        adicionarLog("Erros", "Brainrot " .. nomeBrainrot .. " não encontrado")
    end
end

-- ESP (highlight visual para Brainrots)
local espAtivado = false
local function ativarESP(estado)
    espAtivado = estado
    if estado then
        adicionarLog("Automacao", "ESP ativado")
        spawn(function()
            while espAtivado do
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Model") and obj.Name:lower():find("brainrot") then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = obj
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                            highlight.Parent = obj
                            adicionarLog("Brainrots", "ESP aplicado: " .. obj.Name)
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
            adicionarLog("Automacao", "ESP desativado")
        end)
    end
end

-- Auto Collect (coletar moeda automaticamente)
local autoCollectAtivado = false
local function ativarAutoCollect(estado)
    autoCollectAtivado = estado
    if estado then
        adicionarLog("Automacao", "Auto Collect ativado")
        spawn(function()
            while autoCollectAtivado do
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("Part") and obj.Name:lower():find("cash") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                            wait(math.random(0.2, 0.5))
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 1)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, obj, 0)
                            adicionarLog("Automacao", "Coletado: " .. obj.Name)
                        end
                    end
                end)
                wait(0.5)
            end
            adicionarLog("Automacao", "Auto Collect desativado")
        end)
    end
end

-- Auto Steal (roubar Brainrots de outros jogadores)
local autoStealAtivado = false
local function ativarAutoSteal(estado)
    autoStealAtivado = estado
    if estado then
        adicionarLog("Automacao", "Auto Steal ativado")
        spawn(function()
            while autoStealAtivado do
                pcall(function()
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local base = Workspace:FindFirstChild(player.Name .. "_Base")
                            if base then
                                for _, brainrot in pairs(base:GetDescendants()) do
                                    if brainrot:IsA("Model") and brainrot.Name:lower():find("brainrot") then
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = brainrot:GetPrimaryPartCFrame()
                                        wait(math.random(0.2, 0.5))
                                        local stealRemote = encontrarRemote("steal")
                                        if stealRemote then
                                            acionarRemote(stealRemote.Name, brainrot)
                                        end
                                        adicionarLog("Automacao", "Tentou roubar: " .. brainrot.Name .. " de " .. player.Name)
                                    end
                                end
                            end
                        end
                    end
                end)
                wait(1)
            end
            adicionarLog("Automacao", "Auto Steal desativado")
        end)
    end
end

-- Monitorar eventos
local function monitorarEventos()
    Workspace.ChildAdded:Connect(function(child)
        if child.Name:lower():find("bloodmoon") or child.Name:lower():find("event") then
            notificar("Evento Detectado", "Evento " .. child.Name .. " iniciado!", 5)
            adicionarLog("Automacao", "Evento detectado: " .. child.Name)
            acionarRemote("bloodmoon")
        end
    end)
end

-- Interface gráfica Rayfield
local Rayfield = nil
local sucesso, resultado = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
end)
if sucesso and resultado then
    Rayfield = resultado
else
    notificar("Erro", "Falha ao carregar Rayfield! Verifique sua conexão ou o link.", 10)
    return
end

local Janela = Rayfield:CreateWindow({
    Name = "Steal a Brainrot - Keyless Ultimate",
    LoadingTitle = "Carregando Script",
    LoadingSubtitle = "por xAI",
})

local AbaPrincipal = Janela:CreateTab("Principal", nil)
local AbaAutomacao = Janela:CreateTab("Automação", nil)
local AbaLogs = Janela:CreateTab("Logs", nil)

-- Seção de logs
local LabelRemotes = AbaLogs:CreateLabel("Remotes (atualiza automaticamente)")
local LabelBrainrots = AbaLogs:CreateLabel("Brainrots (atualiza automaticamente)")
local LabelMutacoes = AbaLogs:CreateLabel("Mutações (atualiza automaticamente)")
local LabelAutomacao = AbaLogs:CreateLabel("Automação (atualiza automaticamente)")
local LabelErros = AbaLogs:CreateLabel("Erros (atualiza automaticamente)")

local function atualizarLogs()
    LabelRemotes:Set(table.concat(logs.Remotes, "\n"))
    LabelBrainrots:Set(table.concat(logs.Brainrots, "\n"))
    LabelMutacoes:Set(table.concat(logs.Mutacoes, "\n"))
    LabelAutomacao:Set(table.concat(logs.Automacao, "\n"))
    LabelErros:Set(table.concat(logs.Erros, "\n"))
end

-- Botão para copiar logs
AbaLogs:CreateButton({
    Name = "Copiar Todos os Logs",
    Callback = function()
        if setclipboard then
            local todosLogs = "Remotes:\n" .. table.concat(logs.Remotes, "\n") ..
                "\n\nBrainrots:\n" .. table.concat(logs.Brainrots, "\n") ..
                "\n\nMutações:\n" .. table.concat(logs.Mutacoes, "\n") ..
                "\n\nAutomação:\n" .. table.concat(logs.Automacao, "\n") ..
                "\n\nErros:\n" .. table.concat(logs.Erros, "\n")
            setclipboard(todosLogs)
            notificar("Sucesso", "Logs copiados para a área de transferência!", 5)
            adicionarLog("Automacao", "Logs copiados para a área de transferência")
        else
            notificar("Erro", "Função setclipboard não suportada!", 5)
            adicionarLog("Erros", "setclipboard não suportado")
        end
        atualizarLogs()
    end
})

-- Botão para listar Remotes
AbaPrincipal:CreateButton({
    Name = "Listar Todos os Remotes (use Dex Explorer para mais detalhes)",
    Callback = function()
        local remotes = listarRemotes()
        if #remotes > 0 then
            local lista = table.concat(remotes, "\n")
            notificar("Remotes Encontrados", lista, 10)
            adicionarLog("Remotes", "Remotes listados:\n" .. lista)
        else
            notificar("Erro", "Nenhum Remote encontrado! Use Dex Explorer.", 5)
            adicionarLog("Erros", "Nenhum Remote encontrado")
        end
        atualizarLogs()
    end
})

-- Botão para explorar Workspace
AbaPrincipal:CreateButton({
    Name = "Explorar Workspace (Brainrots/Conveyor)",
    Callback = function()
        local objetos = explorarWorkspace()
        if #objetos > 0 then
            local lista = table.concat(objetos, "\n")
            notificar("Objetos Encontrados", lista, 10)
            adicionarLog("Brainrots", "Objetos listados:\n" .. lista)
        else
            notificar("Erro", "Nenhum Brainrot ou Conveyor encontrado!", 5)
            adicionarLog("Erros", "Nenhum Brainrot ou Conveyor encontrado")
        end
        atualizarLogs()
    end
})

-- Dropdown para eventos
AbaPrincipal:CreateDropdown({
    Name = "Disparar Evento",
    Options = listaEventos,
    CurrentOption = listaEventos[1],
    Callback = function(opcao)
        acionarRemote(opcao)
        atualizarLogs()
    end
})

-- Dropdowns para spawnar Brainrot com mutação
local brainrotSelecionado = listaBrainrots[1]
local mutacaoSelecionada = listaMutacoes[1]

AbaPrincipal:CreateDropdown({
    Name = "Selecionar Brainrot",
    Options = listaBrainrots,
    CurrentOption = listaBrainrots[1],
    Callback = function(opcao)
        brainrotSelecionado = opcao
        adicionarLog("Brainrots", "Brainrot selecionado: " .. opcao)
        atualizarLogs()
    end
})

AbaPrincipal:CreateDropdown({
    Name = "Selecionar Mutação",
    Options = listaMutacoes,
    CurrentOption = listaMutacoes[1],
    Callback = function(opcao)
        mutacaoSelecionada = opcao
        adicionarLog("Mutacoes", "Mutação selecionada: " .. opcao)
        atualizarLogs()
    end
})

AbaPrincipal:CreateButton({
    Name = "Spawnar Brainrot com Mutação",
    Callback = function()
        spawnarBrainrot(brainrotSelecionado, mutacaoSelecionada)
        atualizarLogs()
    end
})

AbaPrincipal:CreateInput({
    Name = "Disparar Remote Personalizado (ex.: SpawnBrainrot)",
    PlaceholderText = "Digite o nome do Remote",
    Callback = function(texto)
        if texto ~= "" then
            acionarRemote(texto)
        else
            notificar("Erro", "Digite um nome de Remote válido!", 5)
            adicionarLog("Erros", "Nome de Remote inválido")
        end
        atualizarLogs()
    end
})

AbaAutomacao:CreateToggle({
    Name = "Ativar ESP (Highlight Brainrots)",
    CurrentValue = false,
    Callback = function(estado)
        ativarESP(estado)
        atualizarLogs()
    end
})

AbaAutomacao:CreateToggle({
    Name = "Ativar Auto Collect (Coletar Moeda)",
    CurrentValue = false,
    Callback = function(estado)
        ativarAutoCollect(estado)
        atualizarLogs()
    end
})

AbaAutomacao:CreateToggle({
    Name = "Ativar Auto Steal (Roubar Brainrots)",
    CurrentValue = false,
    Callback = function(estado)
        ativarAutoSteal(estado)
        atualizarLogs()
    end
})

AbaAutomacao:CreateToggle({
    Name = "Monitorar Eventos",
    CurrentValue = false,
    Callback = function(estado)
        if estado then
            notificar("Monitoramento", "Monitorando eventos (ex.: Bloodmoon)...", 5)
            adicionarLog("Automacao", "Monitoramento de eventos ativado")
            monitorarEventos()
        else
            adicionarLog("Automacao", "Monitoramento de eventos desativado")
        end
        atualizarLogs()
    end
})

-- Atualização automática dos logs
spawn(function()
    while wait(1) do
        atualizarLogs()
    end
end)

-- Inicialização e checagem de jogo
notificar("Script Carregado", "Script Keyless Ultimate para Steal a Brainrot iniciado!", 5)
adicionarLog("Automacao", "Script iniciado")

if game.PlaceId == 126884695634066 then
    Rayfield:Load()
else
    notificar("Erro", "Este script é para Steal a Brainrot! Jogo incorreto.", 10)
    adicionarLog("Erros", "Jogo incorreto (PlaceId: " .. game.PlaceId .. ")")
end

while wait(1) do
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
        notificar("Aviso", "Aguardando personagem carregar...", 3)
        adicionarLog("Erros", "Aguardando personagem carregar")
    end
end
