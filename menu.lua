-- Menu.lua
-- MARK: - Globais
local menu = {titleImage, backgroundImage, playButtonImage, creditsButtonImage, creditsHover,
time = 0, 
waveAmplitude = 10,
waveFrequency = 2,
titleScale = 3,
buttonScale = 1.2,
playButtonX, playButtonY, creditsButtonX, creditsButtonY, music}

-- MARK: - Load
local function loadImages()
    menu.backgroundImage = love.graphics.newImage("assets/menuDefault/smdCresp.png")
    menu.titleImage = love.graphics.newImage("assets/menuDefault/hotlineTitle.png")
    menu.playButtonImage = love.graphics.newImage("assets/sprites/buttons/play_button_1.png")
    menu.hover = love.graphics.newImage("assets/sprites/buttons/play_button_2.png")
    menu.creditsButtonImage = love.graphics.newImage("assets/sprites/buttons/button-credits.png")
    menu.creditsHover = love.graphics.newImage("assets/sprites/buttons/button-credits2.png")
end

-- MARK: - Setup ao invés de colocar dentro do load
local function setupWindowAndButtons()

    love.window.setMode(1200, 800)
    love.window.setTitle("Hotline ISMD")

    local buttonWidth = menu.playButtonImage:getWidth() * menu.buttonScale
    local buttonHeight = menu.playButtonImage:getHeight() * menu.buttonScale
    local buttonW = menu.creditsButtonImage:getWidth() * menu.buttonScale
    local buttonH = menu.creditsButtonImage:getHeight() * menu.buttonScale

    menu.playButtonX = 1200/2 - (buttonWidth / 2)
    menu.playButtonY = 800/2 - (buttonHeight / 2)
    menu.creditsButtonX = 1200/2 - (buttonW / 2)
    menu.creditsButtonY = 800 /2 - (buttonH /2)
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
    musicSt() -- Falta setar pra parar após sair do menu
    setupWindowAndButtons()
end


-- MARK: - UP Wave Effect and Music Verification
function menu.update(dt)
    menu.time = menu.time + dt
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
    love.graphics.draw(menu.playButtonImage, menu.playButtonX, menu.playButtonY, 0, menu.buttonScale, menu.buttonScale, menu.playButtonImage:getWidth() / 2 - 100, menu.playButtonImage:getHeight() / 2 - 150)
    love.graphics.draw(menu.creditsButtonImage, menu.creditsButtonX, menu.creditsButtonY, 0, menu.buttonScale, menu.buttonScale, menu.creditsButtonImage:getWidth() / 2 - 100, menu.creditsButtonImage:getHeight() / 2 - 250)

    end
return menu

