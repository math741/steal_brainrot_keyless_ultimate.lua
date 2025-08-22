--[[
    Steal a Brainrot - Ultra Elite V5
    Desenvolvido por: math741
    Versão: 5.0.0
    Última atualização: 2025-08-22 16:08:25 UTC
    
    Changelog V5:
    - Sistema de UI completamente reescrito
    - Otimização máxima de performance
    - Sistema de spawn universal melhorado
    - Proteção anti-ban avançada
    - Auto-farm inteligente
    - ESP dinâmico
]]

-- Proteção Inicial
if getgenv().Protected then return end
getgenv().Protected = true

-- Serviços Otimizados
local Services = setmetatable({
    Cache = {},
}, {
    __index = function(self, key)
        if not self.Cache[key] then
            self.Cache[key] = game:GetService(key)
        end
        return self.Cache[key]
    end
})

-- Configurações Globais
local CONFIG = {
    VERSION = "5.0.0",
    AUTHOR = "math741",
    UPDATE_DATE = "2025-08-22 16:08:25",
    DEBUG = false,
    THEME = {
        BACKGROUND = Color3.fromRGB(20, 20, 25),
        DARKER = Color3.fromRGB(15, 15, 20),
        LIGHTER = Color3.fromRGB(30, 30, 35),
        ACCENT = Color3.fromRGB(255, 70, 70),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
        SUCCESS = Color3.fromRGB(70, 255, 70),
        WARNING = Color3.fromRGB(255, 255, 70),
        ERROR = Color3.fromRGB(255, 70, 70)
    }
}

-- Sistema de UI Elite V5
local EliteUI = {}
EliteUI.__index = EliteUI

function EliteUI.new()
    local self = setmetatable({
        elements = {},
        activeTab = nil,
        tabs = {},
        dragging = false,
        dragStart = nil,
        startPos = nil
    }, EliteUI)
    
    -- ScreenGui Principal
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "UltraEliteV5"
    self.gui.ResetOnSpawn = false
    
    -- Frame Principal com Design Moderno
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 650, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
    self.mainFrame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Efeitos Visuais
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = self.mainFrame
    
    -- Barra Superior
    self.topBar = Instance.new("Frame")
    self.topBar.Name = "TopBar"
    self.topBar.Size = UDim2.new(1, 0, 0, 40)
    self.topBar.BackgroundColor3 = CONFIG.THEME.DARKER
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 10)
    topCorner.Parent = self.topBar
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Steal a Brainrot Ultra Elite v" .. CONFIG.VERSION
    title.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.topBar
    
    -- Container de Abas
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(0, 150, 1, -50)
    self.tabContainer.Position = UDim2.new(0, 10, 0, 45)
    self.tabContainer.BackgroundColor3 = CONFIG.THEME.LIGHTER
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.Parent = self.mainFrame
    
    local tabContainerCorner = Instance.new("UICorner")
    tabContainerCorner.CornerRadius = UDim.new(0, 8)
    tabContainerCorner.Parent = self.tabContainer
    
    -- Lista de Abas
    self.tabList = Instance.new("ScrollingFrame")
    self.tabList.Name = "TabList"
    self.tabList.Size = UDim2.new(1, -10, 1, -10)
    self.tabList.Position = UDim2.new(0, 5, 0, 5)
    self.tabList.BackgroundTransparency = 1
    self.tabList.ScrollBarThickness = 2
    self.tabList.Parent = self.tabContainer
    
    -- Layout da Lista
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = self.tabList
    
    -- Container de Conteúdo
    self.contentContainer = Instance.new("Frame")
    self.contentContainer.Name = "ContentContainer"
    self.contentContainer.Size = UDim2.new(1, -180, 1, -50)
    self.contentContainer.Position = UDim2.new(0, 170, 0, 45)
    self.contentContainer.BackgroundColor3 = CONFIG.THEME.LIGHTER
    self.contentContainer.BorderSizePixel = 0
    self.contentContainer.Parent = self.mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = self.contentContainer
    
    -- Sistema de Arrasto
    self:EnableDragging()
    
    return self
end

function EliteUI:EnableDragging()
    local UserInputService = Services.UserInputService
    
    self.topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = self.mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.dragStart
            self.mainFrame.Position = UDim2.new(
                self.startPos.X.Scale,
                self.startPos.X.Offset + delta.X,
                self.startPos.Y.Scale,
                self.startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = false
        end
    end)
end

function EliteUI:CreateTab(name)
    -- Botão da Aba
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 35)
    tabButton.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    tabButton.Text = name
    tabButton.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.Parent = self.tabList
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton
    
    -- Conteúdo da Aba
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, -20, 1, -20)
    tabContent.Position = UDim2.new(0, 10, 0, 10)
    tabContent.BackgroundTransparency = 1
    tabContent.ScrollBarThickness = 4
    tabContent.Visible = false
    tabContent.Parent = self.contentContainer
    
    -- Layout do Conteúdo
    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 10)
    contentList.Parent = tabContent
    
    -- Auto-size do ScrollingFrame
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y)
    end)
    
    -- Lógica de Seleção
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Armazena referências
    self.tabs[name] = {
        button = tabButton,
        content = tabContent
    }
    
    -- Seleciona primeira aba
    if not self.activeTab then
        self:SelectTab(name)
    end
    
    return tabContent
end

function EliteUI:SelectTab(name)
    -- Reseta todas as abas
    for tabName, tab in pairs(self.tabs) do
        tab.button.BackgroundColor3 = CONFIG.THEME.BACKGROUND
        tab.content.Visible = false
    end
    
    -- Ativa a aba selecionada
    if self.tabs[name] then
        self.tabs[name].button.BackgroundColor3 = CONFIG.THEME.ACCENT
        self.tabs[name].content.Visible = true
        self.activeTab = name
    end
end

function EliteUI:CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    button.Text = text
    button.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    -- Efeitos de Hover
    local hovering = false
    button.MouseEnter:Connect(function()
        hovering = true
        Services.TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.THEME.ACCENT
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        hovering = false
        Services.TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.THEME.BACKGROUND
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
        
        -- Efeito de Clique
        Services.TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = CONFIG.THEME.SUCCESS
        }):Play()
        
        wait(0.1)
        
        if hovering then
            Services.TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = CONFIG.THEME.ACCENT
            }):Play()
        else
            Services.TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = CONFIG.THEME.BACKGROUND
            }):Play()
        end
    end)
    
    return button
end

function EliteUI:CreateToggle(parent, text, default, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = text .. "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, 35)
    toggle.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    toggle.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggle
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -50, 0.5, -10)
    switch.BackgroundColor3 = default and CONFIG.THEME.ACCENT or CONFIG.THEME.DARKER
    switch.Parent = toggle
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(default and 1 or 0, default and -18 or 2, 0.5, -8)
    dot.BackgroundColor3 = CONFIG.THEME.TEXT_PRIMARY
    dot.Parent = switch
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
    
    -- Área clicável
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = toggle
    
    local enabled = default
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        -- Anima o dot
        Services.TweenService:Create(dot, TweenInfo.new(0.2), {
            Position
