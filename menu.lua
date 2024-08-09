-- Menu.lua
-- MARK: - Globais
local menu = {titleImage, backgroundImage, playButtonImage, creditsButtonImage, 
time = 0, 
waveAmplitude = 10,
waveFrequency = 2,
titleScale = 3,
buttonScale = 1.2,
playButtonX, playButtonY, creditsButtonX, creditsButtonY, music}
-- Aqui não tem referência ao game.lua (não existente nesse arquivo) e não está na main 

--[[local titleImage, backgroundImage, playButtonImage, creditsButtonImage
local time = 0
local waveAmplitude = 10
local waveFrequency = 2
local titleScale = 0.25
local buttonScale = 1.2
local playButtonX, playButtonY, creditsButtonX, creditsButtonY]]

-- MARK: - Load
local function loadImages()
    menu.backgroundImage = love.graphics.newImage("assets/menuDefault/style.png")
    menu.titleImage = love.graphics.newImage("assets/menuDefault/titleDefault.png")
    menu.playButtonImage = love.graphics.newImage("assets/sprites/buttons/play_button_1.png")
    menu.hover = love.graphics.newImage("assets/sprites/buttons/play_button_2.png")
    --creditsButtonImage = love.graphics.newImage("credits-button.png")
end

-- MARK: - Setup ao invés de colocar dentro do load
local function setupWindowAndButtons()
    love.window.setMode(1200, 800)
    love.window.setTitle("Hotline ISMD")

    local buttonWidth = menu.playButtonImage:getWidth() * menu.buttonScale
    local buttonHeight = menu.playButtonImage:getHeight() * menu.buttonScale

    menu.playButtonX = (1200 - buttonWidth) / 2
    menu.playButtonY = 600
    menu.creditsButtonX = (1200 - buttonWidth) / 2
    menu.creditsButtonY = 670
end

-- Função para calcular o efeito de onda
local function getWaveOffset()
    return menu.waveAmplitude * math.sin(menu.waveFrequency * menu.time)
end

local function musicSt()
    menu.music = love.audio.newSource("assets/sfx/autoral-menuloop.wav", "stream")

    menu.music:setVolume(0.5)
    menu.music:setLooping(true)
    menu.music:play()
end

-- Função de carregamento inicial
function menu.load()
    loadImages()
    musicSt()
    setupWindowAndButtons()
end


-- MARK: - UP Wave Effect and Music Verification
function menu.update(dt)
    menu.time = menu.time + dt

    if not inMenu and menu.music then
        menu.music:stop()
        menu.music = nil  -- Opcional: Limpar a referência após parar a música
    end
end

-- MARK: - Draw
function menu.draw()
    -- Desenhar o fundo
    love.graphics.draw(menu.backgroundImage, 0, 0, 0, 1200 / menu.backgroundImage:getWidth(), 800 / menu.backgroundImage:getHeight())

    -- Calcular a posição do título com efeito de onda
    local titleWidth = menu.titleImage:getWidth() * menu.titleScale
    local titleHeight = menu.titleImage:getHeight() * menu.titleScale
    local waveOffset = getWaveOffset()

    -- Desenhar o título com efeito de onda e escala
    love.graphics.draw(menu.titleImage, (1200 - titleWidth) / 2, 150 + waveOffset, 0, menu.titleScale, menu.titleScale)

    -- Desenhar botões com escala e centralização
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(menu.playButtonImage, menu.playButtonX, menu.playButtonY, 0, menu.buttonScale, menu.buttonScale, menu.playButtonImage:getWidth() / 2, menu.playButtonImage:getHeight() / 2 + 100)
    --love.graphics.draw(creditsButtonImage, creditsButtonX, creditsButtonY, 0, buttonScale, buttonScale, creditsButtonImage:getWidth() / 2, creditsButtonImage:getHeight() / 2)
end

return menu

