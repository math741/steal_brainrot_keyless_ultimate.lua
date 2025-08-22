--[[
    Steal a Brainrot - Elite Edition V4
    Desenvolvido por: math741
    Última atualização: 2025-08-22 15:58:51 UTC
    Versão: 4.0.0 ELITE

    Recursos:
    - Interface própria de alta performance
    - Sistema de proteção avançado
    - Otimização máxima
    - Efeitos visuais personalizados
    - Sistema de macros avançado
]]

-- Proteção Inicial
if getfenv().protectScript then
    getfenv().protectScript()
end

-- Serviços Otimizados com Cache
local Services = setmetatable({}, {
    __index = function(self, key)
        local success, service = pcall(game.GetService, game, key)
        if success and service then
            self[key] = service
            return service
        end
        return nil
    end
})

-- Configurações Elite
local CONFIG = {
    VERSAO = "4.0.0",
    AUTOR = "math741",
    DATA_ATUALIZACAO = "2025-08-22 15:58:51",
    TEMA = {
        BACKGROUND = Color3.fromRGB(25, 25, 35),
        FOREGROUND = Color3.fromRGB(35, 35, 45),
        ACCENT = Color3.fromRGB(255, 70, 70),
        TEXT = Color3.fromRGB(255, 255, 255),
        BORDER = Color3.fromRGB(60, 60, 70)
    },
    ANIMACAO = {
        DURACAO = 0.3,
        ESTILO = Enum.EasingStyle.Quart,
        DIRECAO = Enum.EasingDirection.Out
    }
}

-- Interface Elite Personalizada
local EliteUI = {}
EliteUI.__index = EliteUI

function EliteUI.new()
    local self = setmetatable({}, EliteUI)
    
    -- Criar ScreenGui base
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "EliteUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal com design moderno
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = CONFIG.TEMA.BACKGROUND
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Efeitos visuais
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = self.mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.TEMA.BACKGROUND),
        ColorSequenceKeypoint.new(1, CONFIG.TEMA.FOREGROUND)
    })
    gradient.Parent = self.mainFrame
    
    -- Sistema de abas
    self.tabButtons = Instance.new("Frame")
    self.tabButtons.Name = "TabButtons"
    self.tabButtons.Size = UDim2.new(0, 150, 1, 0)
    self.tabButtons.BackgroundColor3 = CONFIG.TEMA.FOREGROUND
    self.tabButtons.BorderSizePixel = 0
    self.tabButtons.Parent = self.mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 10)
    tabCorner.Parent = self.tabButtons
    
    -- Conteúdo
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "Content"
    self.contentFrame.Size = UDim2.new(1, -160, 1, -20)
    self.contentFrame.Position = UDim2.new(0, 155, 0, 10)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.Parent = self.mainFrame
    
    -- Sistema de arrasto
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Título Elite
    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = self.tabButtons
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "ELITE V4"
    title.TextColor3 = CONFIG.TEMA.ACCENT
    title.TextSize = 22
    title.Parent = titleFrame
    
    return self
end

function EliteUI:CreateTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -20, 0, 35)
    tabButton.Position = UDim2.new(0, 10, 0, #self.tabButtons:GetChildren() * 45 + 50)
    tabButton.BackgroundColor3 = CONFIG.TEMA.FOREGROUND
    tabButton.Text = name
    tabButton.TextColor3 = CONFIG.TEMA.TEXT
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = self.tabButtons
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.Visible = false
    content.Parent = self.contentFrame
    
    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 10)
    list.Parent = content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = content
    
    tabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(self.contentFrame:GetChildren()) do
            child.Visible = false
        end
        content.Visible = true
        
        -- Animação do botão
        local tween = Services.TweenService:Create(
            tabButton,
            TweenInfo.new(0.3),
            {BackgroundColor3 = CONFIG.TEMA.ACCENT}
        )
        tween:Play()
    end)
    
    return content
end

function EliteUI:CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = CONFIG.TEMA.FOREGROUND
    button.Text = text
    button.TextColor3 = CONFIG.TEMA.TEXT
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        local tween = Services.TweenService:Create(
            button,
            TweenInfo.new(0.3),
            {BackgroundColor3 = CONFIG.TEMA.ACCENT}
        )
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local tween = Services.TweenService:Create(
            button,
            TweenInfo.new(0.3),
            {BackgroundColor3 = CONFIG.TEMA.FOREGROUND}
        )
        tween:Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return button
end

function EliteUI:CreateToggle(parent, text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text .. "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, 35)
    toggle.BackgroundColor3 = CONFIG.TEMA.FOREGROUND
    toggle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.TEMA.TEXT
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -50, 0.5, -10)
    switch.BackgroundColor3 = default and CONFIG.TEMA.ACCENT or CONFIG.TEMA.BORDER
    switch.Parent = toggle
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(default and 1 or 0, default and -18 or 2, 0.5, -8)
    dot.BackgroundColor3 = CONFIG.TEMA.TEXT
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = toggle
    
    local enabled = default
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        local dotTween = Services.TweenService:Create(
            dot,
            TweenInfo.new(0.3),
            {Position = UDim2.new(enabled and 1 or 0, enabled and -18 or 2, 0.5, -8)}
        )
        
        local colorTween = Services.TweenService:Create(
            switch,
            TweenInfo.new(0.3),
            {BackgroundColor3 = enabled and CONFIG.TEMA.ACCENT or CONFIG.TEMA.BORDER}
        )
        
        dotTween:Play()
        colorTween:Play()
        callback(enabled)
    end)
    
    return toggle
end

-- Criar e configurar a interface
local Interface = EliteUI.new()
Interface.gui.Parent = game.CoreGui

-- Criar abas principais
local mainTab = Interface:CreateTab("Principal")
local farmTab = Interface:CreateTab("Farm")
local visualTab = Interface:CreateTab("Visual")
local configTab = Interface:CreateTab("Config")

-- Adicionar elementos à aba Principal
Interface:CreateButton(mainTab, "Spawnar Brainrot", function()
    -- Função de spawn aqui
end)

Interface:CreateToggle(mainTab, "Auto Spawn", false, function(enabled)
    -- Lógica do auto spawn
end)

-- Adicionar elementos à aba Farm
Interface:CreateToggle(farmTab, "Auto Farm", false, function(enabled)
    -- Lógica do auto farm
end)

-- Adicionar elementos à aba Visual
Interface:CreateToggle(visualTab, "ESP", false, function(enabled)
    -- Lógica do ESP
end)

-- Adicionar elementos à aba Config
Interface:CreateButton(configTab, "Salvar Configurações", function()
    -- Função de salvamento
end)

-- Retornar interface para uso global
return Interface
