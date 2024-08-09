-- Menu.lua
local menu = {}
-- Aqui não tem referência ao game.lua (não existente nesse arquivo) e não está na main 

-- MARK: - Globais
local titleImage, backgroundImage, playButtonImage, creditsButtonImage
local time = 0
local waveAmplitude = 10
local waveFrequency = 2
local titleScale = 0.25
local buttonScale = 1.2
local playButtonX, playButtonY, creditsButtonX, creditsButtonY

-- MARK: - Load
local function loadImages()
    backgroundImage = love.graphics.newImage("assets/menuDefault/style.png")
    titleImage = love.graphics.newImage("assets/menuDefault/titleDefault.png")
    playButtonImage = love.graphics.newImage("assets/buttons/play_button_1.png")
    --creditsButtonImage = love.graphics.newImage("credits-button.png")
end

-- MARK: - Setup ao invés de colocar dentro do load
local function setupWindowAndButtons()
    love.window.setMode(1200, 800)
    love.window.setTitle("Hotline ISMD")

    local buttonWidth = playButtonImage:getWidth() * buttonScale
    local buttonHeight = playButtonImage:getHeight() * buttonScale

    playButtonX = (1200 - buttonWidth) / 2
    playButtonY = 600
    creditsButtonX = (1200 - buttonWidth) / 2
    creditsButtonY = 670
end

-- Função para calcular o efeito de onda
local function getWaveOffset()
    return waveAmplitude * math.sin(waveFrequency * time)
end

-- Função de carregamento inicial
function love.load()
    loadImages()
    setupWindowAndButtons()
end

-- MARK: - UP Wave Effect
function menu.update(dt)
    time = time + dt
end

-- MARK: - Draw
function menu.draw()
    -- Desenhar o fundo
    love.graphics.draw(backgroundImage, 0, 0, 0, 1200 / backgroundImage:getWidth(), 800 / backgroundImage:getHeight())

    -- Calcular a posição do título com efeito de onda
    local titleWidth = titleImage:getWidth() * titleScale
    local titleHeight = titleImage:getHeight() * titleScale
    local waveOffset = getWaveOffset()

    -- Desenhar o título com efeito de onda e escala
    love.graphics.draw(titleImage, (1200 - titleWidth) / 2, 50 + waveOffset, 0, titleScale, titleScale)

    -- Desenhar botões com escala e centralização
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(playButtonImage, playButtonX, playButtonY, 0, buttonScale, buttonScale, playButtonImage:getWidth() / 2, playButtonImage:getHeight() / 2)
    --love.graphics.draw(creditsButtonImage, creditsButtonX, creditsButtonY, 0, buttonScale, buttonScale, creditsButtonImage:getWidth() / 2, creditsButtonImage:getHeight() / 2)
end

return menu