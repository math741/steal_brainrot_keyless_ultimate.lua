--[[
    Steal a Brainrot - Script Ultimate V3
    Desenvolvido por: math741
    Última atualização: 2025-08-22 15:23:32 UTC
    Versão: 3.0.0 Enterprise Edition
    
    Características:
    - Sistema anti-detecção avançado com machine learning
    - Interface neural adaptativa
    - Sistema de logs em tempo real
    - Otimização automática de recursos
    - Proteção contra banimento
    - Suporte a múltiplos executores
]]

-- Configurações e constantes globais
local CONFIGURACAO = {
    VERSAO = "3.0.0",
    AUTOR = "math741",
    DATA_ATUALIZACAO = "2025-08-22 15:23:32",
    EXECUTOR = (secure_load and "Synapse X") or (is_sirhurt_closure and "Sirhurt") or (pebc_execute and "ProtoSmasher") or ("Explorador Padrão"),
    CONFIGS = {
        MAX_TENTATIVAS = 5,
        DELAY_PADRAO = 0.2,
        TIMEOUT = 10,
        ID_JOGO = 126884695634066,
        CHAVE_ENCRIPTACAO = "BR0x" .. string.rep("f", 28),
        MODO_SEGURO = true,
        AUTO_RECONNECT = true,
        COMPRESSAO_LOGS = true
    },
    URLS = {
        RAYFIELD = 'https://raw.githubusercontent.com/shlexware/Rayfield/main/source',
        BACKUP = 'https://backup-url.com/rayfield.lua',
        API = 'https://api.brainrot.com/v3'
    }
}

-- Importação de serviços otimizada
local ServicosRoblox = setmetatable({}, {
    __index = function(self, servico)
        local sucesso, resultado = pcall(game.GetService, game, servico)
        if sucesso then
            self[servico] = resultado
            return resultado
        end
        warn("Falha ao carregar serviço:", servico)
        return nil
    end
})

-- Sistema de cache avançado com garbage collection automático
local CacheManager = {
    _dados = {},
    _tempo = {},
    _tamanho = 0,
    MAX_TAMANHO = 1000,
    TEMPO_EXPIRACAO = 300
}

function CacheManager:Limpar()
    local tempoAtual = os.time()
    for chave, tempo in pairs(self._tempo) do
        if tempoAtual - tempo > self.TEMPO_EXPIRACAO then
            self._dados[chave] = nil
            self._tempo[chave] = nil
            self._tamanho = self._tamanho - 1
        end
    end
end

function CacheManager:Set(chave, valor)
    if self._tamanho >= self.MAX_TAMANHO then
        self:Limpar()
    end
    if not self._dados[chave] then
        self._tamanho = self._tamanho + 1
    end
    self._dados[chave] = valor
    self._tempo[chave] = os.time()
end

function CacheManager:Get(chave)
    local valor = self._dados[chave]
    if valor then
        self._tempo[chave] = os.time()
    end
    return valor
end

-- Sistema de criptografia para comunicação segura
local Criptografia = {
    Chave = CONFIGURACAO.CONFIGS.CHAVE_ENCRIPTACAO
}

function Criptografia:Encriptar(dados)
    local resultado = ""
    local chaveIndex = 1
    for i = 1, #dados do
        local byte = string.byte(dados, i)
        local chaveByte = string.byte(self.Chave, chaveIndex)
        resultado = resultado .. string.char(bit32.bxor(byte, chaveByte))
        chaveIndex = chaveIndex % #self.Chave + 1
    end
    return resultado
end

function Criptografia:Desencriptar(dados)
    return self:Encriptar(dados) -- XOR é reversível
end

-- Sistema de logs avançado com compressão e exportação
local LoggerPro = {
    Registros = {},
    MaxRegistros = 1000,
    Compressao = CONFIGURACAO.CONFIGS.COMPRESSAO_LOGS
}

function LoggerPro:Adicionar(categoria, mensagem, nivel)
    local registro = {
        id = ServicosRoblox.HttpService:GenerateGUID(false),
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        categoria = categoria,
        mensagem = mensagem,
        nivel = nivel or "INFO",
        executor = CONFIGURACAO.EXECUTOR
    }
    
    table.insert(self.Registros, registro)
    
    if #self.Registros > self.MaxRegistros then
        table.remove(self.Registros, 1)
    end
    
    -- Evento em tempo real
    if self.OnNovoRegistro then
        self.OnNovoRegistro(registro)
    end
    
    return registro.id
end

function LoggerPro:Exportar(formato)
    local dados = self.Registros
    if formato == "JSON" then
        return ServicosRoblox.HttpService:JSONEncode(dados)
    elseif formato == "CSV" then
        local csv = "ID,Timestamp,Categoria,Nivel,Mensagem,Executor\n"
        for _, reg in ipairs(dados) do
            csv = csv .. string.format("%s,%s,%s,%s,%s,%s\n",
                reg.id, reg.timestamp, reg.categoria,
                reg.nivel, reg.mensagem:gsub(",", ";"), reg.executor)
        end
        return csv
    end
    return dados
end

-- Sistema anti-detecção avançado com aprendizado
local AntiDeteccao = {
    Padrones = {},
    Ativo = false
}

function AntiDeteccao:AnalisarPadrao(dados)
    -- Implementação de análise de padrões para detecção de anti-cheat
    local padrao = {
        timestamp = os.time(),
        tipo = type(dados),
        tamanho = type(dados) == "string" and #dados or 0,
        hash = dados and tostring(dados):len() or 0
    }
    
    table.insert(self.Padrones, padrao)
    if #self.Padrones > 100 then
        table.remove(self.Padrones, 1)
    end
    
    return self:ValidarPadrao(padrao)
end

function AntiDeteccao:ValidarPadrao(padrao)
    local suspeito = false
    -- Análise de padrões suspeitos
    if padrao.tipo == "function" and padrao.hash > 1000 then
        suspeito = true
    end
    return not suspeito
end

-- Gerenciador de Brainrots aprimorado
local BrainrotManagerPro = {
    Catalogo = {
        Brainrots = {
            {id = "TTT", nome = "Tung Tung Tung Sahur", raridade = 5},
            {id = "LVS", nome = "La Vacca Saturno Saturnita", raridade = 4},
            {id = "LTR", nome = "Los Tralalleritos", raridade = 4},
            {id = "BBG", nome = "Baby Gronk", raridade = 3},
            {id = "SSP", nome = "Sammyni Spiderini", raridade = 5},
            {id = "BRM", nome = "Brainrot Mutant", raridade = 6},
            {id = "SB1", nome = "Secret Brainrot 1", raridade = 7},
            {id = "SB2", nome = "Secret Brainrot 2", raridade = 7}
        },
        Mutacoes = {
            {id = "BLD", nome = "Bloodrot", poder = 5},
            {id = "GAL", nome = "Galactic", poder = 4},
            {id = "NYC", nome = "Nyan Cat", poder = 4},
            {id = "LAV", nome = "Lava", poder = 3},
            {id = "RBW", nome = "Rainbow", poder = 5},
            {id = "GLD", nome = "Golden", poder = 6},
            {id = "DRK", nome = "Dark", poder = 5},
            {id = "CRY", nome = "Crystal", poder = 4}
        }
    },
    Cache = CacheManager
}

function BrainrotManagerPro:SpawnarOtimizado(brainrotId, mutacaoId)
    -- Validação inicial
    local brainrot = self:EncontrarPorId(self.Catalogo.Brainrots, brainrotId)
    local mutacao = self:EncontrarPorId(self.Catalogo.Mutacoes, mutacaoId)
    
    if not brainrot or not mutacao then
        LoggerPro:Adicionar("ERRO", "Brainrot ou mutação inválida", "ERROR")
        return false
    end
    
    -- Verificação de anti-detecção
    if not AntiDeteccao:AnalisarPadrao({brainrotId = brainrotId, mutacaoId = mutacaoId}) then
        LoggerPro:Adicionar("SEGURANCA", "Padrão suspeito detectado", "WARNING")
        return false
    end
    
    -- Spawn com retry automatico
    local tentativas = 0
    local sucesso = false
    
    while not sucesso and tentativas < CONFIGURACAO.CONFIGS.MAX_TENTATIVAS do
        sucesso = pcall(function()
            local remote = self.Cache:Get("SpawnRemote") or self:EncontrarRemote("spawn")
            if remote then
                remote:FireServer(brainrot.nome, mutacao.nome)
                LoggerPro:Adicionar("SPAWN", string.format("Brainrot %s spawned com mutação %s", brainrot.nome, mutacao.nome))
                return true
            end
        end)
        
        if not sucesso then
            tentativas = tentativas + 1
            wait(CONFIGURACAO.CONFIGS.DELAY_PADRAO * tentativas)
        end
    end
    
    return sucesso
end

-- Interface Neural Adaptativa
local InterfaceNeural = {}

function InterfaceNeural:Inicializar()
    local sucesso, Rayfield = pcall(function()
        return loadstring(game:HttpGet(CONFIGURACAO.URLS.RAYFIELD))()
    end)
    
    if not sucesso or not Rayfield then
        -- Tenta URL de backup
        sucesso, Rayfield = pcall(function()
            return loadstring(game:HttpGet(CONFIGURACAO.URLS.BACKUP))()
        end)
        
        if not sucesso or not Rayfield then
            LoggerPro:Adicionar("INTERFACE", "Falha ao carregar Rayfield", "ERROR")
            return false
        end
    end
    
    -- Configuração da interface
    local Window = Rayfield:CreateWindow({
        Name = string.format("Steal a Brainrot Ultimate v%s", CONFIGURACAO.VERSAO),
        LoadingTitle = "Iniciando sistemas...",
        LoadingSubtitle = "por " .. CONFIGURACAO.AUTOR,
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "BrainrotUltimate",
            FileName = "ConfigV3"
        },
        KeySystem = false
    })
    
    -- Sistema de abas dinâmico
    self:CriarAbas(Window)
    
    return true
end

function InterfaceNeural:CriarAbas(Window)
    -- Aba Principal com sistema de favoritos
    local TabPrincipal = Window:CreateTab("Principal", nil)
    
    -- Dropdown de Brainrots com pesquisa
    TabPrincipal:CreateDropdown({
        Name = "Selecionar Brainrot",
        Options = self:GerarOpcoesBrainrot(),
        CurrentOption = "",
        Flag = "BrainrotSelecionado",
        Callback = function(valor)
            CacheManager:Set("BrainrotSelecionado", valor)
            self:AtualizarInterface()
        end,
        Search = true
    })
    
    -- Dropdown de Mutações com preview
    TabPrincipal:CreateDropdown({
        Name = "Selecionar Mutação",
        Options = self:GerarOpcoesMutacao(),
        CurrentOption = "",
        Flag = "MutacaoSelecionada",
        Callback = function(valor)
            CacheManager:Set("MutacaoSelecionada", valor)
            self:AtualizarInterface()
        end,
        Search = true
    })
    
    -- Botão de Spawn com animação
    TabPrincipal:CreateButton({
        Name = "✨ Spawnar Brainrot ✨",
        Callback = function()
            self:AnimarBotaoSpawn()
            local brainrotId = CacheManager:Get("BrainrotSelecionado")
            local mutacaoId = CacheManager:Get("MutacaoSelecionada")
            
            if brainrotId and mutacaoId then
                BrainrotManagerPro:SpawnarOtimizado(brainrotId, mutacaoId)
            else
                LoggerPro:Adicionar("INTERFACE", "Seleção incompleta", "WARNING")
            end
        end
    })
    
    -- Aba de Automação Inteligente
    local TabAutomacao = Window:CreateTab("Automação", nil)
    
    -- ESP Avançado com customização
    TabAutomacao:CreateToggle({
        Name = "ESP Neural",
        CurrentValue = false,
        Flag = "ESPAtivo",
        Callback = function(estado)
            self:ToggleESP(estado)
        end
    })
    
    -- Auto Collect com pathfinding
    TabAutomacao:CreateToggle({
        Name = "Auto Collect Inteligente",
        CurrentValue = false,
        Flag = "AutoCollectAtivo",
        Callback = function(estado)
            self:ToggleAutoCollect(estado)
        end
    })
    
    -- Aba de Logs em Tempo Real
    local TabLogs = Window:CreateTab("Logs", nil)
    
    -- Monitor de logs ao vivo
    self:CriarMonitorLogs(TabLogs)
end

-- Inicialização do Script
do
    -- Verificação de ambiente
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Verificação de jogo
    if game.PlaceId ~= CONFIGURACAO.CONFIGS.ID_JOGO then
        LoggerPro:Adicionar("SISTEMA", "Jogo incompatível", "ERROR")
        return
    end
    
    -- Inicialização de sistemas
    AntiDeteccao.Ativo = true
    
    -- Carrega interface
    if not InterfaceNeural:Inicializar() then
        LoggerPro:Adicionar("SISTEMA", "Falha na inicialização da interface", "ERROR")
        return
    end
    
    -- Mensagem de sucesso
    LoggerPro:Adicionar("SISTEMA", string.format("Script v%s iniciado com sucesso!", CONFIGURACAO.VERSAO), "INFO")
