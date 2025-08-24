--[[
    No-Clip Ultra Avançado (Versão 4) - Bypass Completo Anti-Cheat
    
    Técnicas avançadas de bypass:
    - Manipulação de CFrame em baixo nível
    - Simulação de movimento natural
    - Bypass de validação servidor-cliente
    - Anti-detecção com randomização
    - Sistema de teleport invisível
    - Controle total da física do personagem

    Instruções:
    - Pressione 'G' para ativar/desativar
    - WASD para movimento, Space/Shift para vertical
    - Ctrl para modo turbo
    - Tab para alternar entre modos de bypass
]]--

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil
local isNoClipEnabled = false

-- Sistema de velocidade adaptativo
local baseSpeed = 16
local flySpeed = 25
local turboSpeed = 80
local currentSpeed = flySpeed
local isTurboMode = false

-- Modos de bypass
local bypassModes = {
    "STEALTH", -- Movimento mais natural
    "GHOST",   -- Bypass total de física
    "PHASE",   -- Teleport micro-segmentado
    "QUANTUM"  -- Manipulação de CFrame direta
}
local currentBypassMode = 1

-- Objetos de controle
local bodyObjects = {}
local connections = {}

-- Sistema anti-detecção avançado
local movementBuffer = {}
local positionSmoothing = {}
local lastServerSync = 0
local bypassCooldown = 0

-- Configurações de segurança
local maxTeleportDistance = 50
local movementSmoothing = 0.8
local detectionAvoidance = true

-- Função para logging seguro
local function safeLog(message)
    if math.random(1, 5) == 1 then -- Log aleatório para evitar detecção
        print("[NoClip-v4] " .. message)
    end
end

-- Função para limpar todos os body objects
local function clearBodyObjects()
    for _, obj in pairs(bodyObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    bodyObjects = {}
end

-- Sistema de bypass STEALTH - Movimento natural
local function setupStealthMode()
    clearBodyObjects()
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    bodyObjects.velocity = bodyVelocity
    
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    bodyAngularVelocity.Parent = rootPart
    bodyObjects.angular = bodyAngularVelocity
end

-- Sistema de bypass GHOST - Física totalmente desabilitada
local function setupGhostMode()
    clearBodyObjects()
    
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPosition.Position = rootPart.Position
    bodyPosition.D = 2000
    bodyPosition.P = 10000
    bodyPosition.Parent = rootPart
    bodyObjects.position = bodyPosition
    
    -- Desabilita gravidade completamente
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    bodyObjects.antigrav = bodyVelocity
end

-- Sistema de bypass PHASE - Teleport micro-segmentado
local function setupPhaseMode()
    clearBodyObjects()
    -- Modo phase usa apenas CFrame manipulation
end

-- Sistema de bypass QUANTUM - Manipulação direta de CFrame
local function setupQuantumMode()
    clearBodyObjects()
    
    -- Cria um attachment invisível para manipulação
    local attachment = Instance.new("Attachment")
    attachment.Name = "QuantumAnchor"
    attachment.Parent = rootPart
    
    local alignPosition = Instance.new("AlignPosition")
    alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPosition.Attachment0 = attachment
    alignPosition.Position = rootPart.Position
    alignPosition.MaxForce = math.huge
    alignPosition.MaxVelocity = math.huge
    alignPosition.Responsiveness = 200
    alignPosition.Parent = rootPart
    bodyObjects.quantum = alignPosition
    bodyObjects.anchor = attachment
end

-- Função para configurar o modo de bypass atual
local function setupCurrentBypassMode()
    local mode = bypassModes[currentBypassMode]
    
    if mode == "STEALTH" then
        setupStealthMode()
    elseif mode == "GHOST" then
        setupGhostMode()
    elseif mode == "PHASE" then
        setupPhaseMode()
    elseif mode == "QUANTUM" then
        setupQuantumMode()
    end
    
    safeLog("Modo de bypass: " .. mode)
end

-- Função para tornar todas as partes intangíveis
local function setCollisionState(enabled)
    if not character then return end
    
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = enabled
            if not enabled then
                -- Torna levemente transparente para feedback visual
                if obj.Name ~= "HumanoidRootPart" then
                    obj.Transparency = math.min(obj.Transparency + 0.3, 0.8)
                end
                
                -- Remove todos os sounds de colisão
                for _, sound in pairs(obj:GetChildren()) do
                    if sound:IsA("Sound") and (sound.Name:find("Impact") or sound.Name:find("Step")) then
                        sound.Volume = 0
                    end
                end
            else
                -- Restaura transparência original
                if obj.Name ~= "HumanoidRootPart" then
                    obj.Transparency = math.max(obj.Transparency - 0.3, 0)
                end
            end
        end
    end
end

-- Sistema de suavização de movimento
local function smoothVector(current, target, factor)
    return current:lerp(target, factor)
end

-- Função principal de movimento
local function updateMovement(deltaTime)
    if not isNoClipEnabled or not rootPart then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Calcula direção do movimento
    local moveVector = Vector3.new()
    local cameraCFrame = camera.CFrame
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveVector = moveVector + cameraCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveVector = moveVector - cameraCFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveVector = moveVector - cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveVector = moveVector + cameraCFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveVector = moveVector + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    -- Normaliza e aplica velocidade
    if moveVector.Magnitude > 0 then
        moveVector = moveVector.Unit * currentSpeed
    end
    
    -- Sistema anti-detecção: adiciona micro-variações
    if detectionAvoidance then
        local noise = Vector3.new(
            (math.noise(tick() * 2) - 0.5) * 0.1,
            (math.noise(tick() * 3) - 0.5) * 0.1,
            (math.noise(tick() * 4) - 0.5) * 0.1
        )
        moveVector = moveVector + noise
    end
    
    -- Aplica movimento baseado no modo atual
    local mode = bypassModes[currentBypassMode]
    
    if mode == "STEALTH" and bodyObjects.velocity then
        -- Movimento suave com BodyVelocity
        local targetVel = smoothVector(bodyObjects.velocity.Velocity, moveVector, movementSmoothing)
        bodyObjects.velocity.Velocity = targetVel
        
    elseif mode == "GHOST" and bodyObjects.position then
        -- Movimento direto de posição
        local targetPos = rootPart.Position + (moveVector * deltaTime)
        bodyObjects.position.Position = targetPos
        
    elseif mode == "PHASE" then
        -- Teleport micro-segmentado para passar através de objetos
        if moveVector.Magnitude > 0 then
            local stepSize = math.min(moveVector.Magnitude * deltaTime, 2)
            local direction = moveVector.Unit
            local targetPos = rootPart.Position + (direction * stepSize)
            
            -- Verifica se há obstáculo e faz bypass
            local raycast = workspace:Raycast(rootPart.Position, direction * stepSize)
            if raycast then
                -- Se há obstáculo, teleporta através dele
                targetPos = targetPos + (direction * 5) -- Atravessa o obstáculo
            end
            
            rootPart.CFrame = CFrame.new(targetPos, targetPos + direction)
        end
        
    elseif mode == "QUANTUM" and bodyObjects.quantum then
        -- Manipulação direta com AlignPosition
        local targetPos = rootPart.Position + (moveVector * deltaTime)
        bodyObjects.quantum.Position = targetPos
    end
end

-- Sistema de bypass de validação
local function bypassValidation()
    if not isNoClipEnabled or not humanoid then return end
    
    -- Impede que o servidor corrija a posição
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    -- Define ownership de rede para todas as partes
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            pcall(function()
                part:SetNetworkOwner(localPlayer)
            end)
        end
    end
    
    -- Reseta flags anti-cheat
    if humanoid.Health ~= math.huge then
        humanoid.Health = math.huge
        humanoid.MaxHealth = math.huge
    end
end

-- Função para ativar no-clip
local function enableNoClip()
    character = localPlayer.Character
    if not character then return end
    
    humanoid = character:FindFirstChildOfClass("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    safeLog("Ativando modo fantasma ultra...")
    
    -- Configurações do Humanoid
    humanoid.PlatformStand = true
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
    
    -- Imortalidade
    humanoid.Health = math.huge
    humanoid.MaxHealth = math.huge
    
    -- Desabilita colisões
    setCollisionState(false)
    
    -- Configura modo de bypass atual
    setupCurrentBypassMode()
    
    isNoClipEnabled = true
    
    safeLog("Modo " .. bypassModes[currentBypassMode] .. " ativado!")
end

-- Função para desativar no-clip
local function disableNoClip()
    if not character or not humanoid or not rootPart then return end
    
    safeLog("Desativando modo fantasma...")
    
    -- Limpa objetos de controle
    clearBodyObjects()
    
    -- Restaura configurações do Humanoid
    humanoid.PlatformStand = false
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    
    -- Restaura saúde
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    
    -- Reabilita colisões
    setCollisionState(true)
    
    -- Retorna ownership para servidor
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            pcall(function()
                part:SetNetworkOwner(nil)
            end)
        end
    end
    
    isNoClipEnabled = false
    safeLog("Modo normal restaurado.")
end

-- Event handlers
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        -- Toggle no-clip
        if isNoClipEnabled then
            disableNoClip()
        else
            enableNoClip()
        end
        
    elseif input.KeyCode == Enum.KeyCode.LeftControl and isNoClipEnabled then
        -- Modo turbo
        isTurboMode = not isTurboMode
        currentSpeed = isTurboMode and turboSpeed or flySpeed
        safeLog("Turbo: " .. (isTurboMode and "ON" or "OFF") .. " (Speed: " .. currentSpeed .. ")")
        
    elseif input.KeyCode == Enum.KeyCode.Tab and isNoClipEnabled then
        -- Troca modo de bypass
        currentBypassMode = (currentBypassMode % #bypassModes) + 1
        setupCurrentBypassMode()
        safeLog("Modo alterado para: " .. bypassModes[currentBypassMode])
    end
end)

-- Scroll para ajustar velocidade
UserInputService.InputChanged:Connect(function(input)
    if not isNoClipEnabled then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then
            flySpeed = math.min(flySpeed + 3, 150)
        else
            flySpeed = math.max(flySpeed - 3, 8)
        end
        
        if not isTurboMode then
            currentSpeed = flySpeed
        end
        
        safeLog("Velocidade: " .. flySpeed)
    end
end)

-- Loop principal (alta frequência)
connections.heartbeat = RunService.Heartbeat:Connect(updateMovement)

-- Loop de bypass de validação (baixa frequência para evitar detecção)
connections.validation = RunService.Heartbeat:Connect(function()
    bypassCooldown = bypassCooldown + 1
    if bypassCooldown >= 30 then -- A cada meio segundo aproximadamente
        bypassValidation()
        bypassCooldown = 0
    end
end)

-- Cleanup
local function cleanup()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    if isNoClipEnabled then
        disableNoClip()
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        cleanup()
    end
end)

-- Log inicial
safeLog("NoClip Ultra v4 carregado!")
safeLog("Controles:")
safeLog("G = Toggle NoClip")
safeLog("Ctrl = Turbo Mode") 
safeLog("Tab = Trocar modo bypass")
safeLog("Scroll = Ajustar velocidade")
safeLog("Modo atual: " .. bypassModes[currentBypassMode])
