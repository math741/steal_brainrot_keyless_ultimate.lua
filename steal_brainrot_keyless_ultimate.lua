--[[
    🌟 STEAL A BRAINROT - REPLICATOR EDITION V8 🌟
    Desenvolvido por: math741
    Versão: 8.0.0
    Última atualização: 2025-08-22 16:30:51
]]

-- Proteção Inicial
if getgenv().ReplicatorProtected then return end
getgenv().ReplicatorProtected = true

-- Serviços
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace")
}

-- Sistema de Replicação
local Replicator = {
    events = {},
    remotes = {},
    cache = {},
    logs = {}
}

-- Scanner de Eventos
function Replicator:ScanRemotes()
    print("🔍 Iniciando scan de remotes...")
    
    -- Procura em todos os serviços
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(self.remotes, {
                remote = obj,
                name = obj.Name,
                path = obj:GetFullName(),
                calls = 0,
                args = {}
            })
            print("📡 Remote encontrado:", obj.Name)
        end
    end
end

-- Sistema de Captura de Eventos
function Replicator:HookRemotes()
    print("🎣 Iniciando hook dos remotes...")
    
    for _, remoteData in pairs(self.remotes) do
        local remote = remoteData.remote
        
        -- Hook do FireServer
        if remote:IsA("RemoteEvent") then
            local oldFireServer = remote.FireServer
            remote.FireServer = newcclosure(function(self, ...)
                local args = {...}
                remoteData.calls = remoteData.calls + 1
                table.insert(remoteData.args, args)
                
                -- Guarda apenas os últimos 10 argumentos
                if #remoteData.args > 10 then
                    table.remove(remoteData.args, 1)
                end
                
                print(string.format("🔄 Remote chamado: %s | Args: %s", 
                    remoteData.name, 
                    table.concat(args, ", ")
                ))
                
                return oldFireServer(self, ...)
            end)
        end
    end
end

-- Sistema de Replicação de Brainrot
function Replicator:ReplicateBrainrot(target)
    print("🎯 Iniciando replicação do Brainrot:", target.Name)
    
    -- Captura propriedades do Brainrot
    local properties = {
        CFrame = target.PrimaryPart and target.PrimaryPart.CFrame or target:GetPivot(),
        Size = target.PrimaryPart and target.PrimaryPart.Size or Vector3.new(1, 1, 1),
        BrickColor = target.PrimaryPart and target.PrimaryPart.BrickColor or BrickColor.new("Medium stone grey"),
        Material = target.PrimaryPart and target.PrimaryPart.Material or Enum.Material.Plastic
    }
    
    -- Captura animações
    local animations = {}
    if target:FindFirstChild("Humanoid") and target.Humanoid:FindFirstChild("Animator") then
        for _, track in pairs(target.Humanoid.Animator:GetPlayingAnimationTracks()) do
            table.insert(animations, {
                id = track.Animation.AnimationId,
                speed = track.Speed,
                weight = track.WeightCurrent
            })
        end
    end
    
    -- Captura efeitos
    local effects = {}
    for _, part in pairs(target:GetDescendants()) do
        if part:IsA("ParticleEmitter") then
            table.insert(effects, {
                part = part.Name,
                properties = {
                    Color = part.Color,
                    Size = part.Size,
                    Speed = part.Speed,
                    Rate = part.Rate
                }
            })
        end
    end
    
    -- Armazena dados capturados
    local replicationData = {
        name = target.Name,
        class = target.ClassName,
        properties = properties,
        animations = animations,
        effects = effects,
        timestamp = os.time()
    }
    
    -- Salva no cache
    self.cache[target.Name] = replicationData
    
    print("✅ Replicação completa!")
    return replicationData
end

-- Sistema de Reprodução
function Replicator:PlayReplication(data)
    print("▶️ Reproduzindo replicação:", data.name)
    
    -- Cria modelo base
    local model = Instance.new("Model")
    model.Name = data.name .. "_Replicated"
    
    -- Cria parte principal
    local main = Instance.new("Part")
    main.CFrame = data.properties.CFrame
    main.Size = data.properties.Size
    main.BrickColor = data.properties.BrickColor
    main.Material = data.properties.Material
    main.Anchored = true
    main.Parent = model
    
    -- Adiciona animações
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
        end
    end
    
    -- Adiciona efeitos
    for _, effect in pairs(data.effects) do
        local emitter = Instance.new("ParticleEmitter")
        emitter.Color = effect.properties.Color
        emitter.Size = effect.properties.Size
        emitter.Speed = effect.properties.Speed
        emitter.Rate = effect.properties.Rate
        emitter.Parent = main
    end
    
    model.Parent = workspace
    print("✅ Replicação reproduzida!")
    return model
end

-- Interface do Replicador
local ReplicatorUI = {}
ReplicatorUI.__index = ReplicatorUI

function ReplicatorUI.new()
    local self = setmetatable({}, ReplicatorUI)
    
    -- GUI Principal
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "BrainrotReplicator"
    
    -- Frame Principal
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Size = UDim2.new(0, 300, 0, 400)
    self.mainFrame.Position = UDim2.new(1, -320, 0.5, -200)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "Brainrot Replicator v8"
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = self.mainFrame
    
    -- Lista de Brainrots
    self.brainrotList = Instance.new("ScrollingFrame")
    self.brainrotList.Size = UDim2.new(1, -20, 1, -60)
    self.brainrotList.Position = UDim2.new(0, 10, 0, 50)
    self.brainrotList.BackgroundTransparency = 1
    self.brainrotList.ScrollBarThickness = 4
    self.brainrotList.Parent = self.mainFrame
    
    -- Auto Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = self.brainrotList
    
    return self
end

function ReplicatorUI:AddBrainrot(brainrot)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.Text = brainrot.Name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Parent = self.brainrotList
    
    -- Botões de ação
    local replicateBtn = Instance.new("TextButton")
    replicateBtn.Size = UDim2.new(0, 80, 1, -10)
    replicateBtn.Position = UDim2.new(1, -85, 0, 5)
    replicateBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    replicateBtn.Text = "Replicar"
    replicateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replicateBtn.Parent = button
    
    -- Eventos
    replicateBtn.MouseButton1Click:Connect(function()
        local data = Replicator:ReplicateBrainrot(brainrot)
        Replicator:PlayReplication(data)
    end)
end

-- Inicialização
local function Initialize()
    print("🚀 Iniciando Brainrot Replicator...")
    
    -- Inicializa sistemas
    Replicator:ScanRemotes()
    Replicator:HookRemotes()
    
    -- Cria interface
    local UI = ReplicatorUI.new()
    
    -- Scan inicial de Brainrots
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and 
           (obj.Name:lower():find("brainrot") or 
            obj.Name:lower():find("pet") or 
            obj.Name:lower():find("creature")) then
            UI:AddBrainrot(obj)
        end
    end
    
    -- Scan contínuo
    Services.RunService.Heartbeat:Connect(function()
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and 
               (obj.Name:lower():find("brainrot") or 
                obj.Name:lower():find("pet") or 
                obj.Name:lower():find("creature")) and
               not UI.brainrotList:FindFirstChild(obj.Name) then
                UI:AddBrainrot(obj)
            end
        end
    end)
    
    -- Parent to CoreGui
    UI.gui.Parent = game:GetService("CoreGui")
    
    print("✨ Replicator iniciado com sucesso!")
    return UI
end

-- Execute
return Initialize()
