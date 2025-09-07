--[=[
    Script para criar uma GUI que navega e executa scripts do workspace.
    
    Funcionalidades:
    - Cria uma GUI com uma lista de scripts (Lua ou ModuleScript) no workspace.
    - Clicar em um item da lista executa o script correspondente.
    - Suporta Scripts e ModuleScripts.
--]=]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cria o ScreenGui que será a base da nossa interface
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "WorkspaceExecutorGui"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui

-- Cria o Frame principal
local executorFrame = Instance.new("Frame")
executorFrame.Name = "WorkspaceExecutor"
executorFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
executorFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
executorFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
executorFrame.BorderColor3 = Color3.new(0, 0, 0)
executorFrame.BorderSizePixel = 2
executorFrame.Active = true
executorFrame.Draggable = true
executorFrame.Parent = mainGui

-- Cria o Label do título
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.TextScaled = true
titleLabel.Text = "Executor de Workspace"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = executorFrame

-- Cria o ScrollingFrame para listar os scripts
local scriptsFrame = Instance.new("ScrollingFrame")
scriptsFrame.Name = "ScriptsList"
scriptsFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
scriptsFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
scriptsFrame.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
scriptsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scriptsFrame.ScrollBarThickness = 8
scriptsFrame.Parent = executorFrame

-- Layout para os botões dentro do ScrollingFrame
local listLayout = Instance.new("UIListLayout")
listLayout.Name = "ScriptsListLayout"
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scriptsFrame

-- Cria o botão para carregar a lista de scripts
local loadButton = Instance.new("TextButton")
loadButton.Name = "LoadButton"
loadButton.Size = UDim2.new(0.4, 0, 0.1, 0)
loadButton.Position = UDim2.new(0.05, 0, 0.88, 0)
loadButton.BackgroundColor3 = Color3.new(0, 0.5, 0)
loadButton.TextColor3 = Color3.new(1, 1, 1)
loadButton.Text = "Atualizar Lista"
loadButton.Font = Enum.Font.SourceSansBold
loadButton.Parent = executorFrame

-- Cria o botão para fechar a GUI
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.4, 0, 0.1, 0)
closeButton.Position = UDim2.new(0.55, 0, 0.88, 0)
closeButton.BackgroundColor3 = Color3.new(0.8, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "Fechar"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.Parent = executorFrame

-- Função para atualizar a lista de scripts
local function updateScriptsList()
    -- Limpa a lista atual
    for _, child in pairs(scriptsFrame:GetChildren()) do
        if child.Name ~= "ScriptsListLayout" then
            child:Destroy()
        end
    end
    
    local yOffset = 0
    
    -- Itera por todos os objetos no workspace
    for _, child in pairs(game.Workspace:GetDescendants()) do
        -- Checa se é um script e se ele não está em um local inacessível
        if (child:IsA("Script") or child:IsA("ModuleScript")) then
            
            -- Cria um botão para o script
            local scriptButton = Instance.new("TextButton")
            scriptButton.Name = child.Name
            scriptButton.Size = UDim2.new(1, 0, 0, 30)
            scriptButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
            scriptButton.TextColor3 = Color3.new(1, 1, 1)
            scriptButton.TextXAlignment = Enum.TextXAlignment.Left
            scriptButton.Text = "   " .. child.Name .. " (" .. child.ClassName .. ")"
            scriptButton.Font = Enum.Font.SourceSans
            scriptButton.Parent = scriptsFrame
            
            -- Conecta a função de execução ao clique do botão
            scriptButton.MouseButton1Click:Connect(function()
                local success, result
                if child:IsA("Script") then
                    -- Usa loadstring para executar o código do Script
                    success, result = pcall(function()
                        local func = loadstring(child.Source)
                        if func then func() end
                    end)
                elseif child:IsA("ModuleScript") then
                    -- Usa require para carregar o ModuleScript
                    success, result = pcall(require, child)
                end
                
                if not success then
                    warn("Erro ao executar script:", result)
                else
                    print("Script '" .. child.Name .. "' executado com sucesso.")
                end
            end)
            
            yOffset = yOffset + 35
        end
    end
    
    -- Ajusta o tamanho da área de rolagem
    scriptsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Evento de clique para os botões
loadButton.MouseButton1Click:Connect(updateScriptsList)
closeButton.MouseButton1Click:Connect(function()
    mainGui:Destroy()
end)

-- Deixa a janela inicialmente invisível
executorFrame.Visible = false

-- Cria um botão no canto da tela para mostrar/esconder a GUI
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.1, 0, 0.05, 0)
toggleButton.Position = UDim2.new(0.9, 0, 0, 0)
toggleButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "Abrir Exec. WS"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainGui

toggleButton.MouseButton1Click:Connect(function()
    executorFrame.Visible = not executorFrame.Visible
end)
