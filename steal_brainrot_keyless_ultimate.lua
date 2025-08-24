--[[
    No-Clip e Imortalidade (LocalScript)

    Este script de executor permite que você ative e desative o modo "no clip".
    Ele foi aprimorado para usar a física mais moderna do Roblox
    (VectorForce e AlignOrientation) para um movimento mais suave, estável
    e menos detectável por sistemas anti-cheat.

    Quando ativado, você se torna invulnerável a todos os danos e pode
    voar livremente, passando por objetos sólidos e paredes.

    Instruções de Uso:
    - Pressione a tecla 'G' para ativar ou desativar o modo no clip.
]]--

-- Obtém os serviços essenciais do jogo
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local vectorForce = nil -- Variável para armazenar o VectorForce
local alignOrientation = nil -- Variável para manter a orientação do personagem

-- Variáveis de controle
local isNoClipEnabled = false
local originalWalkSpeed = 16 -- Velocidade de caminhada padrão
local originalMaxHealth = 100 -- Saúde máxima padrão

-- Variáveis para o voo no modo no-clip
local flySpeed = 50 -- Velocidade de voo no modo no-clip

-- Função para habilitar o modo no-clip
local function enableNoClip()
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        print("[Executor] Modo No-Clip ativado! Usando física avançada...")
        
        -- Salva as propriedades originais
        originalWalkSpeed = humanoid.WalkSpeed
        originalMaxHealth = humanoid.MaxHealth
        
        -- Torna o jogador imortal e desativa a física padrão do jogo sobre ele
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
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

        -- Cria um attachment para os forces
        local attachment = Instance.new("Attachment")
        attachment.Parent = rootPart
        
        -- Cria e configura o VectorForce para controlar o movimento
        vectorForce = Instance.new("VectorForce")
        vectorForce.Force = Vector3.new(0, 0, 0)
        vectorForce.Attachment0 = attachment
        vectorForce.Parent = rootPart

        -- Cria e configura o AlignOrientation para manter o personagem na vertical
        alignOrientation = Instance.new("AlignOrientation")
        alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOrientation.Attachment0 = attachment
        alignOrientation.Responsiveness = 20
        alignOrientation.Parent = rootPart
        alignOrientation.CFrame = rootPart.CFrame

        isNoClipEnabled = true
    end
end

-- Função para desabilitar o modo no-clip
local function disableNoClip()
    local character = localPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        print("[Executor] Modo No-Clip desativado.")

        -- Destrói os forces e attachments
        if vectorForce then
            vectorForce.Parent:Destroy() -- Destrói o attachment e os forces dentro dele
            vectorForce = nil
            alignOrientation = nil
        end
        
        -- Restaura as propriedades originais
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.JumpPower = 50 -- Valor padrão para a maioria dos jogos
        humanoid.Health = originalMaxHealth
        humanoid.MaxHealth = originalMaxHealth
        
        -- Restaura a colisão de todas as partes do personagem
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        -- Retorna a posse da rede para o servidor
        rootPart:SetNetworkOwner(nil)

        isNoClipEnabled = false
    end
end

-- Conecta a função ao evento de entrada do teclado
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

-- Lógica de voo e movimento no modo no-clip
if RunService then
    RunService.Heartbeat:Connect(function(step)
        if isNoClipEnabled and vectorForce and alignOrientation then
            local character = localPlayer.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not character or not rootPart then return end
            
            -- Detecta a direção da câmera para o movimento
            local cameraCFrame = Workspace.CurrentCamera.CFrame
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
            
            -- Normaliza a direção e aplica a força ao VectorForce
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit
            end
            
            -- Calcula a força necessária para atingir a velocidade de voo
            local force = (moveDirection * flySpeed * rootPart.Mass) / 2
            vectorForce.Force = force
        else
            -- Se o modo estiver desativado, garanta que não haja força residual
            if vectorForce then
                vectorForce.Force = Vector3.new(0, 0, 0)
            end
        end
    end)
end

print("[Executor] Script de No-Clip e imortalidade carregado. Pressione 'G' para ativar/desativar.")
