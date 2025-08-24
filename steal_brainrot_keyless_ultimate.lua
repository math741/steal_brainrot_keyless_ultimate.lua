--[[
    No-Clip EXTREMO (Versão 5) - Bypass Total Anti-Teleport
    
    Esta versão usa técnicas extremas para garantir atravessar paredes:
    - CFrame Stepping direto (ignora física completamente)
    - Heartbeat de alta frequência para sobrescrever teleports
    - Sistema de "tunneling" através de objetos
    - Backup contínuo de posição
    - Força bruta contra anti-cheat
    
    GARANTIDO: Atravessa qualquer parede, nunca volta ao local original!
    
    Controles:
    G = Toggle NoClip
    WASD = Movimento horizontal  
    Space = Subir
    Shift = Descer
    Scroll = Velocidade
]]--

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil
local isNoClipEnabled = false

-- Configurações de movimento
local moveSpeed = 16
local minSpeed = 5
local maxSpeed = 200

-- Variáveis de controle
local currentVelocity = Vector3.new(0, 0, 0)
local lastValidPosition = nil
local forcePosition = nil
local stepSize = 0.5

-- Conexões
local heartbeatConnection = nil
local renderSteppedConnection = nil

-- Função para aplicar movimento direto via CFrame (ignora física)
local function applyDirectMovement()
    if not isNoClipEnabled or not rootPart then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    -- Calcula direção do movimento
    local moveVector = Vector3.new(0, 0, 0)
    local cameraCFrame = camera.CFrame
    
    -- Input de movimento
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
        moveVector = moveVector.Unit
        currentVelocity = moveVector * moveSpeed
    else
        currentVelocity = Vector3.new(0, 0, 0)
    end
    
    -- Aplica movimento direto via CFrame (FORÇA BRUTA)
    if currentVelocity.Magnitude > 0 then
        local currentPos = rootPart.Position
        local targetPos = currentPos + (currentVelocity * stepSize)
        
        -- FORÇA A POSIÇÃO DIRETAMENTE - IGNORA TODA FÍSICA
        rootPart.CFrame = CFrame.new(targetPos, targetPos + currentVelocity.Unit)
        
        -- Salva posição válida para backup
        lastValidPosition = targetPos
        forcePosition = targetPos
    end
end

-- Função para forçar posição (anti-teleport extremo)
local function forceAntiTeleport()
    if not isNoClipEnabled or not rootPart or not forcePosition then return end
    
    local currentPos = rootPart.Position
    
    -- Se detectar que foi teleportado (diferença muito grande), força a posição de volta
    if (currentPos - forcePosition).Magnitude > moveSpeed * 2 then
        -- FORÇA BRUTA: Sobrescreve qualquer tentativa de teleport
        rootPart.CFrame = CFrame.new(forcePosition)
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        print("[NoClip-v5] TELEPORT DETECTADO E BLOQUEADO! Forçando posição de volta.")
    end
end

-- Função para setup completo de no-clip
local function setupNoClip()
    if not character or not humanoid or not rootPart then return end
    
    print("[NoClip-v5] Configurando bypass extremo...")
    
    -- === FASE 1: DESABILITA TODA A FÍSICA ===
    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    -- Desabilita todos os estados que podem causar problemas
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        if state ~= Enum.HumanoidStateType.Physics and 
           state ~= Enum.HumanoidStateType.None then
            humanoid:SetStateEnabled(state, false)
        end
    end
    
    -- === FASE 2: REMOVE TODAS AS COLISÕES ===
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            -- Define ownership para o cliente
            pcall(function()
                obj:SetNetworkOwner(localPlayer)
            end)
        end
    end
    
    -- === FASE 3: IMORTALIDADE EXTREMA ===
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    -- Remove qualquer BodyMover que possa interferir
    for _, obj in pairs(rootPart:GetChildren()) do
        if obj:IsA("BodyMover") or obj:IsA("BodyVelocity") or 
           obj:IsA("BodyPosition") or obj:IsA("BodyAngularVelocity") then
            obj:Destroy()
        end
    end
    
    -- === FASE 4: FORÇA POSIÇÃO INICIAL ===
    lastValidPosition = rootPart.Position
    forcePosition = rootPart.Position
    
    print("[NoClip-v5] Setup completo! Modo EXTREMO ativado.")
end

-- Função para ativar no-clip
local function enableNoClip()
    character = localPlayer.Character
    if not character then return end
    
    humanoid = character:FindFirstChildOfClass("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then 
        warn("[NoClip-v5] Personagem não encontrado!")
        return 
    end
    
    setupNoClip()
    
    -- === CONEXÕES DE ALTA FREQUÊNCIA ===
    -- Heartbeat: Movimento principal (60fps)
    heartbeatConnection = RunService.Heartbeat:Connect(applyDirectMovement)
    
    -- RenderStepped: Anti-teleport extremo (60-240fps)
    renderSteppedConnection = RunService.RenderStepped:Connect(forceAntiTeleport)
    
    isNoClipEnabled = true
    print("[NoClip-v5] ✅ NO-CLIP EXTREMO ATIVADO!")
    print("[NoClip-v5] 🚀 Agora você pode atravessar QUALQUER parede!")
end

-- Função para desativar no-clip
local function disableNoClip()
    if not character or not humanoid or not rootPart then return end
    
    print("[NoClip-v5] Desativando no-clip...")
    
    -- Desconecta loops
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    
    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
    end
    
    -- Restaura física normal
    humanoid.PlatformStand = false
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    
    -- Reabilita estados do Humanoid
    for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        humanoid:SetStateEnabled(state, true)
    end
    
    -- Restaura colisões
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.CanCollide = true
            -- Retorna ownership para o servidor
            pcall(function()
                obj:SetNetworkOwner(nil)
            end)
        end
    end
    
    -- Restaura saúde normal
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    
    isNoClipEnabled = false
    currentVelocity = Vector3.new(0, 0, 0)
    forcePosition = nil
    
    print("[NoClip-v5] ❌ No-clip desativado.")
end

-- === EVENT HANDLERS ===

-- Toggle principal
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        if isNoClipEnabled then
            disableNoClip()
        else
            enableNoClip()
        end
    end
end)

-- Controle de velocidade com scroll
UserInputService.InputChanged:Connect(function(input)
    if not isNoClipEnabled then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then
            moveSpeed = math.min(moveSpeed + 8, maxSpeed)
        else
            moveSpeed = math.max(moveSpeed - 8, minSpeed)
        end
        print("[NoClip-v5] 🏃 Velocidade: " .. moveSpeed)
    end
end)

-- Reaplicar no-clip se o personagem respawnar
localPlayer.CharacterAdded:Connect(function(newCharacter)
    if isNoClipEnabled then
        -- Aguarda o personagem carregar completamente
        wait(1)
        character = newCharacter
        humanoid = character:FindFirstChildOfClass("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            setupNoClip()
            print("[NoClip-v5] 🔄 No-clip reaplicado após respawn!")
        end
    end
end)

-- Cleanup ao sair
game.Players.PlayerRemoving:Connect(function(player)
    if player == localPlayer and isNoClipEnabled then
        disableNoClip()
    end
end)

-- === LOGS INICIAIS ===
print("===========================================")
print("🚀 NO-CLIP EXTREMO V5 CARREGADO!")
print("===========================================")
print("📋 CONTROLES:")
print("   G = Ativar/Desativar NoClip")
print("   WASD = Movimento horizontal")
print("   Space = Subir")
print("   Shift = Descer") 
print("   Scroll = Ajustar velocidade")
print("")
print("⚡ CARACTERÍSTICAS:")
print("   ✅ Atravessa QUALQUER parede")
print("   ✅ NUNCA volta ao local original")
print("   ✅ Imortalidade total")
print("   ✅ Movimento suave")
print("   ✅ Anti-teleport extremo")
print("")
print("🎮 Pressione 'G' para começar!")
print("===========================================")

-- Força inicial baixa para evitar detecção
stepSize = 0.3
moveSpeed = 12
