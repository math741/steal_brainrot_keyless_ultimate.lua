--[[
    Sistema Completo de Replicação para Delta Executor
    
    Este script foi projetado para capturar e replicar todas as ações
    de um jogador e do ambiente do jogo, como eventos de comunicação,
    movimento, sons e interações. Ele cria uma interface de usuário (GUI)
    para controlar a captura e a reprodução dos dados.
]]--

-- Verifica se o replicador já está ativo para evitar duplicatas.
if _G.ReplicatorActive then 
    warn("⚠️ Replicador já está ativo!")
    return 
end
_G.ReplicatorActive = true

print("🚀 Iniciando Sistema de Replicação Completa...")

-- Obtém os serviços essenciais do jogo.
local workspace = game:GetService("Workspace")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")
local soundService = game:GetService("SoundService")
local localPlayer = players.LocalPlayer

--[[
    MÓDULO: UniversalCapture
    
    Responsável por capturar todos os eventos do jogo e armazená-los.
]]--
local UniversalCapture = {
    remotes = {},
    movements = {},
    interactions = {},
    sounds = {},
    animations = {},
    tools = {},
    total_captured = 0,
    filters = {
        -- Filtros para ignorar eventos e propriedades desnecessárias.
        ignore_properties = {
            "Color3", "BrickColor", "Color", "Transparency", "CanCollide",
            "Material", "Reflectance", "SpecularColor", "StudsPerTileU", "StudsPerTileV"
        },
        ignore_events = {
            "RenderStepped", "Heartbeat", "MouseMoved", "UserInput",
            "CameraChanged", "ViewportChanged"
        },
        ignore_remotes = {
            "UpdateCamera", "SetCamera", "MousePosition", "Ping",
            "HeartBeat", "FPS", "Render"
        }
    },
    recording = true
}

-- Verifica se uma propriedade deve ser ignorada.
function UniversalCapture:ShouldIgnoreProperty(propertyName)
    for _, ignored in ipairs(self.filters.ignore_properties) do
        if string.find(string.lower(propertyName), string.lower(ignored)) then
            return true
        end
    end
    return false
end

-- Verifica se um remote deve ser ignorado.
function UniversalCapture:ShouldIgnoreRemote(remoteName)
    for _, ignored in ipairs(self.filters.ignore_remotes) do
        if string.find(string.lower(remoteName), string.lower(ignored)) then
            return true
        end
    end
    return false
end

-- Captura um evento e o armazena na tabela correspondente.
function UniversalCapture:CaptureEvent(eventType, data)
    if not self.recording then return end
    
    local event = {
        type = eventType,
        data = data,
        timestamp = tick(), -- Marca o tempo exato do evento.
        player = localPlayer.Name,
        id = self.total_captured + 1
    }
    
    self.total_captured = self.total_captured + 1
    
    -- Organiza o evento por tipo para fácil acesso.
    if eventType == "remote" then
        table.insert(self.remotes, event)
    elseif eventType == "movement" then
        table.insert(self.movements, event)
    elseif eventType == "interaction" then
        table.insert(self.interactions, event)
    elseif eventType == "sound" then
        table.insert(self.sounds, event)
    elseif eventType == "animation" then
        table.insert(self.animations, event)
    elseif eventType == "tool" then
        table.insert(self.tools, event)
    end
    
    print("📊 [" .. eventType:upper() .. "] Evento capturado: " .. (data.name or data.remote or "Desconhecido"))
end

--[[
    MÓDULO: RemoteHooker
    
    Hooka todos os eventos de RemoteEvent e RemoteFunction para interceptar
    a comunicação entre cliente e servidor.
]]--
local RemoteHooker = {
    hooked_remotes = {},
    blocked_count = 0
}

-- Hooka um remote específico para capturar sua chamada.
function RemoteHooker:HookRemote(remote)
    if self.hooked_remotes[remote] then return end
    
    local remoteName = remote.Name
    if UniversalCapture:ShouldIgnoreRemote(remoteName) then return end
    
    self.hooked_remotes[remote] = true
    
    if remote:IsA("RemoteEvent") then
        local originalFire = remote.FireServer
        
        -- Sobrescreve a função FireServer para capturar os dados.
        remote.FireServer = function(self, ...)
            local args = {...}
            
            -- Salva os dados do remote, incluindo o nome e os argumentos.
            local captureData = {
                remote = remoteName,
                path = remote:GetFullName(),
                args = {},
                arg_types = {}
            }
            
            -- Processa os argumentos para um formato legível.
            for i, arg in ipairs(args) do
                local argType = type(arg)
                captureData.arg_types[i] = argType
                
                if argType == "string" or argType == "number" or argType == "boolean" then
                    captureData.args[i] = arg
                elseif argType == "table" then
                    captureData.args[i] = "Table[" .. #arg .. "]"
                elseif typeof(arg) == "Vector3" then
                    captureData.args[i] = {x = arg.X, y = arg.Y, z = arg.Z}
                elseif typeof(arg) == "CFrame" then
                    captureData.args[i] = {pos = {arg.Position.X, arg.Position.Y, arg.Position.Z}}
                elseif typeof(arg) == "Instance" then
                    captureData.args[i] = arg:GetFullName()
                else
                    captureData.args[i] = tostring(arg)
                end
            end
            
            UniversalCapture:CaptureEvent("remote", captureData)
            return originalFire(self, unpack(args))
        end
        
    elseif remote:IsA("RemoteFunction") then
        local originalInvoke = remote.InvokeServer
        
        remote.InvokeServer = function(self, ...)
            local args = {...}
            
            local captureData = {
                remote = remoteName,
                path = remote:GetFullName(),
                args = args,
                type = "RemoteFunction"
            }
            
            UniversalCapture:CaptureEvent("remote", captureData)
            return originalInvoke(self, unpack(args))
        end
    end
end

-- Escaneia e hooka todos os remotes em áreas importantes do jogo.
function RemoteHooker:ScanAndHookAll()
    print("🔍 Escaneando e hookeando todos os remotes...")
    
    local function scanContainer(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                self:HookRemote(obj)
            end
        end
    end
    
    scanContainer(replicatedStorage)
    scanContainer(workspace)
    scanContainer(lighting)
    
    print("✅ Remotes hookeados: " .. #self.hooked_remotes)
end

--[[
    MÓDULO: MovementTracker
    
    Rastreia o movimento do jogador.
]]--
local MovementTracker = {
    last_position = nil,
    last_rotation = nil,
    movement_threshold = 0.1
}

function MovementTracker:Initialize()
    print("🏃 Iniciando rastreamento de movimento...")
    
    spawn(function()
        while _G.ReplicatorActive do
            local character = localPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local currentPos = rootPart.Position
                local currentRot = rootPart.CFrame.LookVector
                
                -- Detecta movimento significativo para evitar capturar dados em excesso.
                if self.last_position then
                    local distance = (currentPos - self.last_position).Magnitude
                    if distance > self.movement_threshold then
                        local moveData = {
                            name = "PlayerMovement",
                            from = {x = self.last_position.X, y = self.last_position.Y, z = self.last_position.Z},
                            to = {x = currentPos.X, y = currentPos.Y, z = currentPos.Z},
                            distance = distance,
                            rotation = {x = currentRot.X, y = currentRot.Y, z = currentRot.Z}
                        }
                        
                        UniversalCapture:CaptureEvent("movement", moveData)
                    end
                end
                
                self.last_position = currentPos
                self.last_rotation = currentRot
            end
            wait(0.1)
        end
    end)
end

--[[
    MÓDULO: InteractionTracker
    
    Rastreia interações do jogador, como cliques do mouse e uso de ferramentas.
]]--
local InteractionTracker = {
    monitored_objects = {},
    click_connections = {}
}

function InteractionTracker:Initialize()
    print("🖱️ Iniciando rastreamento de interações...")
    
    -- Monitora cliques do mouse.
    if localPlayer:GetMouse() then
        local mouse = localPlayer:GetMouse()
        
        mouse.Button1Down:Connect(function()
            local target = mouse.Target
            if target then
                local interactionData = {
                    name = "MouseClick",
                    target = target:GetFullName(),
                    target_class = target.ClassName,
                    position = {x = mouse.X, y = mouse.Y},
                    world_position = mouse.Hit and {
                        x = mouse.Hit.Position.X,
                        y = mouse.Hit.Position.Y, 
                        z = mouse.Hit.Position.Z
                    } or nil
                }
                
                UniversalCapture:CaptureEvent("interaction", interactionData)
            end
        end)
    end
    
    -- Monitora mudanças de ferramentas (equipar/desequipar).
    localPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
        humanoid.ToolEquipped:Connect(function(tool)
            local toolData = {
                name = "ToolEquipped",
                tool_name = tool.Name,
                tool_class = tool.ClassName
            }
            UniversalCapture:CaptureEvent("tool", toolData)
        end)
        
        humanoid.ToolUnequipped:Connect(function(tool)
            local toolData = {
                name = "ToolUnequipped",
                tool_name = tool.Name,
                tool_class = tool.ClassName
            }
            UniversalCapture:CaptureEvent("tool", toolData)
        end)
    end)
end

--[[
    MÓDULO: SoundTracker
    
    Rastreia e captura sons reproduzidos no jogo.
]]--
local SoundTracker = {
    tracked_sounds = {}
}

function SoundTracker:Initialize()
    print("🔊 Iniciando rastreamento de sons...")
    
    -- Monitora sons no workspace.
    local function trackSound(sound)
        if self.tracked_sounds[sound] then return end
        self.tracked_sounds[sound] = true
        
        sound.Played:Connect(function()
            local soundData = {
                name = "SoundPlayed",
                sound_name = sound.Name,
                sound_id = sound.SoundId,
                volume = sound.Volume,
                pitch = sound.Pitch
            }
            UniversalCapture:CaptureEvent("sound", soundData)
        end)
    end
    
    -- Escaneia sons existentes e monitora novos sons.
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Sound") then
            trackSound(obj)
        end
    end
    
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Sound") then
            trackSound(obj)
        end
    end)
end

--[[
    MÓDULO: Replicator
    
    Reproduz os eventos capturados, simulando as ações do jogador.
]]--
local Replicator = {
    replaying = false,
    replay_events = {},
    replay_index = 1,
    replay_speed = 1.0
}

-- Inicia a reprodução dos eventos.
function Replicator:StartReplay(events, speed)
    if self.replaying then
        print("⚠️ Já está replicando!")
        return
    end
    
    self.replaying = true
    self.replay_events = events or {}
    self.replay_index = 1
    self.replay_speed = speed or 1.0
    
    print("▶️ Iniciando replicação de " .. #self.replay_events .. " eventos...")
    
    spawn(function()
        local startTime = tick()
        
        while self.replaying and self.replay_index <= #self.replay_events do
            local event = self.replay_events[self.replay_index]
            
            -- Calcula o atraso para sincronizar com o tempo original.
            if self.replay_index > 1 then
                local prevEvent = self.replay_events[self.replay_index - 1]
                local delay = (event.timestamp - prevEvent.timestamp) / self.replay_speed
                if delay > 0 then
                    wait(delay)
                end
            end
            
            self:ReplicateEvent(event)
            self.replay_index = self.replay_index + 1
        end
        
        self.replaying = false
        print("⏹️ Replicação finalizada!")
    end)
end

-- Executa um evento de replicação.
function Replicator:ReplicateEvent(event)
    if event.type == "remote" and event.data.remote then
        -- Replica a chamada de um remote event.
        local remote = game:GetDescendants()
        for _, obj in ipairs(remote) do
            if obj.Name == event.data.remote and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                print("🔄 Replicando: " .. event.data.remote)
                
                if obj:IsA("RemoteEvent") then
                    obj:FireServer(unpack(event.data.args or {}))
                elseif obj:IsA("RemoteFunction") then
                    obj:InvokeServer(unpack(event.data.args or {}))
                end
                break
            end
        end
        
    elseif event.type == "movement" and event.data.to then
        -- Replica o movimento do jogador.
        local character = localPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            local targetPos = Vector3.new(event.data.to.x, event.data.to.y, event.data.to.z)
            
            rootPart.CFrame = CFrame.new(targetPos)
            print("🏃 Replicando movimento para: " .. tostring(targetPos))
        end
        
    elseif event.type == "tool" then
        -- Replica ações de ferramenta.
        print("🔧 Replicando ação de ferramenta: " .. event.data.name)
    end
end

-- Interrompe a reprodução.
function Replicator:StopReplay()
    self.replaying = false
    print("⏸️ Replicação interrompida!")
end

--[[
    MÓDULO: ControlGUI
    
    Cria a interface de usuário para o script.
]]--
local ControlGUI = {
    gui = nil,
    buttons = {},
    labels = {}
}

-- Cria a GUI na tela do jogador.
function ControlGUI:Create()
    local playerGui = localPlayer:WaitForChild("PlayerGui")
    
    -- Remove GUIs antigas para evitar problemas.
    local oldGui = playerGui:FindFirstChild("ReplicatorGUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ReplicatorGUI"
    screenGui.Parent = playerGui
    
    -- Cria o frame principal.
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    mainFrame.BorderColor3 = Color3.new(0, 1, 0)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui
    
    -- Título da GUI.
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎬 Sistema de Replicação Completa"
    title.TextColor3 = Color3.new(0, 1, 0)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Labels para exibir o status em tempo real.
    local yPos = 40
    local statusTexts = {
        "📊 Eventos Capturados: 0",
        "🌐 Remotes Hookeados: 0", 
        "🏃 Movimentos: 0",
        "🖱️ Interações: 0",
        "🔊 Sons: 0",
        "🔧 Ferramentas: 0",
        "▶️ Status: Capturando..."
    }
    
    for i, text in ipairs(statusTexts) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = mainFrame
        
        table.insert(self.labels, label)
        yPos = yPos + 25
    end
    
    -- Botões de controle para as ações do script.
    yPos = yPos + 10
    local buttons = {
        {text = "▶️ Replicar Tudo", action = function() self:ReplayAll() end},
        {text = "🌐 Replicar Remotes", action = function() self:ReplayRemotes() end},
        {text = "🏃 Replicar Movimentos", action = function() self:ReplayMovements() end},
        {text = "⏹️ Parar Replicação", action = function() Replicator:StopReplay() end},
        {text = "🗑️ Limpar Dados", action = function() self:ClearData() end}
    }
    
    for _, buttonData in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 25)
        button.Position = UDim2.new(0, 5, 0, yPos)
        button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        button.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
        button.Text = buttonData.text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 12
        button.Font = Enum.Font.SourceSans
        button.Parent = mainFrame
        
        button.MouseButton1Click:Connect(buttonData.action)
        table.insert(self.buttons, button)
        yPos = yPos + 30
    end
    
    self.gui = screenGui
    print("🎮 Interface de controle criada!")
end

-- Atualiza os labels da GUI com os dados mais recentes.
function ControlGUI:Update()
    if not self.labels or #self.labels < 7 then return end
    
    self.labels[1].Text = "📊 Eventos Capturados: " .. UniversalCapture.total_captured
    self.labels[2].Text = "🌐 Remotes Hookeados: " .. #RemoteHooker.hooked_remotes
    self.labels[3].Text = "🏃 Movimentos: " .. #UniversalCapture.movements
    self.labels[4].Text = "🖱️ Interações: " .. #UniversalCapture.interactions
    self.labels[5].Text = "🔊 Sons: " .. #UniversalCapture.sounds
    self.labels[6].Text = "🔧 Ferramentas: " .. #UniversalCapture.tools
    self.labels[7].Text = "▶️ Status: " .. (Replicator.replaying and "Replicando..." or "Capturando...")
end

-- Combina e ordena todos os eventos para reprodução.
function ControlGUI:ReplayAll()
    local allEvents = {}
    
    -- Combina todos os eventos capturados.
    for _, event in ipairs(UniversalCapture.remotes) do table.insert(allEvents, event) end
    for _, event in ipairs(UniversalCapture.movements) do table.insert(allEvents, event) end
    for _, event in ipairs(UniversalCapture.interactions) do table.insert(allEvents, event) end
    for _, event in ipairs(UniversalCapture.tools) do table.insert(allEvents, event) end
    
    -- Ordena os eventos por tempo para reprodução correta.
    table.sort(allEvents, function(a, b) return a.timestamp < b.timestamp end)
    
    Replicator:StartReplay(allEvents, 1.0)
end

function ControlGUI:ReplayRemotes()
    Replicator:StartReplay(UniversalCapture.remotes, 1.0)
end

function ControlGUI:ReplayMovements()
    Replicator:StartReplay(UniversalCapture.movements, 0.5)
end

-- Limpa todos os dados capturados.
function ControlGUI:ClearData()
    UniversalCapture.remotes = {}
    UniversalCapture.movements = {}
    UniversalCapture.interactions = {}
    UniversalCapture.sounds = {}
    UniversalCapture.tools = {}
    UniversalCapture.total_captured = 0
    print("🗑️ Todos os dados foram limpos!")
end

--[[
    FUNÇÃO DE INICIALIZAÇÃO PRINCIPAL
    
    Chama todas as funções para iniciar o sistema.
]]--
local function Initialize()
    print("=" .. string.rep("=", 50) .. "=")
    print("🎬 SISTEMA DE REPLICAÇÃO COMPLETA ATIVO")
    print("=" .. string.rep("=", 50) .. "=")
    
    RemoteHooker:ScanAndHookAll()
    MovementTracker:Initialize()
    InteractionTracker:Initialize()  
    SoundTracker:Initialize()
    ControlGUI:Create()
    
    -- Loop para manter a GUI atualizada.
    spawn(function()
        while _G.ReplicatorActive do
            ControlGUI:Update()
            wait(1)
        end
    end)
    
    print("✅ Sistema de replicação completo iniciado!")
    print("🎮 Use a interface para controlar a captura e replicação")
end

--[[
    LIMPEZA
    
    Garante que a GUI seja destruída quando o script for fechado.
]]--
game:BindToClose(function()
    _G.ReplicatorActive = false
    if ControlGUI.gui then
        ControlGUI.gui:Destroy()
    end
    print("👋 Sistema de replicação finalizado!")
end)

-- Inicia o script.
Initialize()
