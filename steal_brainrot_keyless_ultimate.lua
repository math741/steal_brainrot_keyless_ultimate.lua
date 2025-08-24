--[[
    No-Clip e Imortalidade (Versão 2)
    
    Este script foi aprimorado para resolver o problema de ser teleportado de volta,
    causado pelos sistemas anti-cheat dos jogos. Ele gerencia a física do personagem
    de forma mais otimizada, usando VectorForce e AlignOrientation para um movimento
    suave e indetectável.

    Quando ativado, você pode voar livremente, passando por objetos sólidos e paredes,
    e o script também te torna invulnerável a todos os danos.

    Instruções de Uso:
    - Pressione a tecla 'G' para ativar ou desativar o modo no clip.
]]--

-- Obtém os serviços essenciais do jogo
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil
local isNoClipEnabled = false
local originalWalkSpeed = 16
local flySpeed = 50 -- Velocidade de voo no modo no-clip

local vectorForce = nil -- Variável para armazenar o VectorForce
local alignOrientation = nil -- Variável para manter a orientação do personagem

-- A conexão com o evento Heartbeat para o voo
local heartbeatConnection = nil

-- Função para habilitar o modo no-clip
local function enableNoClip()
    -- Garante que o personagem e o HumanoidRootPart existam
    character = localPlayer.Character
    if not character then return end
    
    humanoid = character:FindFirstChildOfClass("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end

    print("[Executor] Modo No-Clip ativado! Usando física avançada...")
    
    -- Salva as propriedades originais do jogador
    originalWalkSpeed = humanoid.WalkSpeed
    
    -- Altera as propriedades para o modo no-clip
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    
    -- Torna o jogador imortal
    humanoid.Health = math.huge
    humanoid.MaxHealth = math.huge
    
    -- Desativa a colisão em todas as partes do personagem para atravessar objetos
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    -- IMPORTANTE: Define a posse da rede para o cliente. Isso impede que o servidor
    -- corrija a posição do personagem, permitindo o movimento no-clip.
    rootPart:SetNetworkOwner(localPlayer)

    -- Cria e configura o VectorForce para controlar o movimento de voo
    local forceAttachment = Instance.new("Attachment", rootPart)
    
    vectorForce = Instance.new("VectorForce")
    vectorForce.Force = Vector3.new(0, 0, 0)
    vectorForce.Attachment0 = forceAttachment
    vectorForce.Parent = rootPart

    -- Cria e configura o AlignOrientation para manter o personagem na vertical
    alignOrientation = Instance.new("AlignOrientation")
    alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOrientation.Attachment0 = forceAttachment
    alignOrientation.Responsiveness = 20
    alignOrientation.Parent = rootPart
    alignOrientation.CFrame = rootPart.CFrame

    isNoClipEnabled = true
end

-- Função para desabilitar o modo no-clip
local function disableNoClip()
    -- Garante que o personagem e o HumanoidRootPart existam
    character = localPlayer.Character
    if not character then return end
    
    humanoid = character:FindFirstChildOfClass("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end

    print("[Executor] Modo No-Clip desativado.")

    -- Destrói os forces e attachments
    if vectorForce and vectorForce.Parent then
        local parentAttachment = vectorForce.Attachment0
        if parentAttachment and parentAttachment.Parent then
            parentAttachment:Destroy()
        end
        vectorForce:Destroy()
    end
    if alignOrientation and alignOrientation.Parent then
        alignOrientation:Destroy()
    end
    vectorForce = nil
    alignOrientation = nil
    
    -- Restaura as propriedades originais
    humanoid.WalkSpeed = originalWalkSpeed
    humanoid.JumpPower = 50 -- Valor padrão para a maioria dos jogos
    humanoid.Health = humanoid.MaxHealth
    
    -- Restaura a colisão de todas as partes do personagem
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end

    -- Retorna a posse da rede para o servidor para que o jogo volte ao normal
    rootPart:SetNetworkOwner(nil)

    isNoClipEnabled = false
end

-- Conecta a função de ativação/desativação ao evento de entrada do teclado
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.G then
        if isNoClipEnabled then
            disableNoClip()
        else
            enableNoClip()
        end
    end
end)

-- Lógica de voo e movimento no modo no-clip, conectada ao RunService.Heartbeat
if RunService then
    heartbeatConnection = RunService.Heartbeat:Connect(function(step)
        if isNoClipEnabled and vectorForce and alignOrientation then
            if not rootPart then return end
            
            -- Detecta a direção da câmera para o movimento
            local cameraCFrame = workspace.CurrentCamera.CFrame
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- Movimento para frente e para trás
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + cameraCFrame.lookVector
            elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - cameraCFrame.lookVector
            end
            
            -- Movimento para a esquerda e para a direita
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - cameraCFrame.rightVector
            elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + cameraCFrame.rightVector
            end
            
            -- Movimento para cima e para baixo
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            -- Normaliza a direção para um movimento consistente
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            -- Calcula a força necessária para atingir a velocidade de voo
            local force = (moveDirection * flySpeed * rootPart.Mass)
            vectorForce.Force = force
        else
            -- Garante que não haja força residual
            if vectorForce then
                vectorForce.Force = Vector3.new(0, 0, 0)
            end
        end
    end)
end

print("[Executor] Script de No-Clip e imortalidade (v2) carregado. Pressione 'G' para ativar/desativar.")
