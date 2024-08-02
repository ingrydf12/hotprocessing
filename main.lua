-- MARK: Demark variables
local posx, posy = 200, 200
local spd = 5
local orange = {1,0.5,0}
local red = {0.7, 0, 0} -- Tiro
local white = {1,1,1}
local pele = {1, 0.8, 0.6}

local player = {frame = 1, sprites = {}}
local tiros = {}
local walls = {}
-- Inimigo variáveis
local inimigo = {x = 400, y = 400, spd = 2, vida = 2, morto = false, flashTime = 0, frame = 1}

local tiro_atual = 1
LIMITE = 5

-- MARK: Function Load LOVE
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)

    require "raycast"

    -- Carrega animação teste do player
    player.sprites[1] = loadSprites("assets/sprites/player")
    player.sprites[1].fps = 2
    player.sprites[1].time = 0

    --Carrega sprite do inimigo (tá estruturado diferente do player pq eu tava com preguiça pra atualizar o codigo no love.draw)
    inimigo.sprites = loadSprites("assets/sprites/enemy")
    
    -- Inicializa o array de tiros
    tiros = {}
    for i = 1, LIMITE do
        tiros[i] = {x = -20, y = -20, velx = 0, vely = 0}
    end
end

-- MARK: Movimentação
function love.update(dt)
    local dir = {0, 0}
    if love.keyboard.isDown("a") then
        dir[1] = -1
    end
    if love.keyboard.isDown("d") then
        dir[1] = dir[1] + 1
    end
    if love.keyboard.isDown("w") then
        dir[2] = -1
    end
    if love.keyboard.isDown("s") then
        dir[2] = dir[2] + 1
    end

    PlayerUpdate(dir, dt)

    -- Atualiza tiros e verifica o estado do inimigo
    for i = 1, LIMITE do
        updateTiro(tiros[i])
        if not inimigo.morto then
            verificarAcerto(tiros[i])
        end
    end
    
    if not inimigo.morto then
        moverInimigo(dt)
    end

    -- Reduz o tempo de flash do inimigo
    if inimigo.flashTime > 0 then
        inimigo.flashTime = inimigo.flashTime - dt
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0, 1)
    
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    love.graphics.setColor(white)

    -- Crosshair
    love.graphics.line(mouseX - 20, mouseY, mouseX + 20, mouseY)
    love.graphics.line(mouseX, mouseY - 18, mouseX, mouseY + 18)
    
    -- Draw player
    love.graphics.draw(player.sprites[1][player.frame], posx, posy, angleToPoint(posx, posy, mouseX, mouseY)+math.pi/2, 1, 1, player.sprites[1][player.frame]:getWidth()/2, player.sprites[1][player.frame]:getHeight()/2)
    
    -- Draw tiros
    for i = 1, LIMITE do
        local tiro = tiros[i]
        love.graphics.setColor(red)
        love.graphics.rectangle("fill", tiro.x, tiro.y, 10, 20)
    end

    -- MARK: - "Knockback" effect on enemys
    if inimigo.flashTime > 0 then
        love.graphics.setColor(1, 0, 0) -- Vermelho
    else
        love.graphics.setColor(1, 1, 1) -- Branco (cor padrão)
    end
    
    -- MARK: Sprite enemy load
    if inimigo.sprites then
        -- Desenha o sprite do inimigo
        love.graphics.draw(inimigo.sprites[inimigo.frame], inimigo.x, inimigo.y, inimigo.angle+math.pi/2, 1, 1, inimigo.sprites[inimigo.frame]:getWidth() / 2, inimigo.sprites[inimigo.frame]:getHeight() / 2)
    else
        -- Exibe uma mensagem de erro se o sprite não for carregado corretamente
        love.graphics.print("Erro ao carregar sprite do inimigo", 10, 10)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        tiro_atual = tiro_atual + 1
        if tiro_atual > LIMITE then
            tiro_atual = 1
        end

        local angle = angleToPoint(posx, posy, x, y)
        tiros[tiro_atual].x = posx
        tiros[tiro_atual].y = posy
        tiros[tiro_atual].velx = spd * 2 * math.cos(angle)
        tiros[tiro_atual].vely = spd * 2 * math.sin(angle)
    end
end

-- MARK: UP Tiro
function updateTiro(tiro)
    if tiro then
        tiro.x = tiro.x + tiro.velx
        tiro.y = tiro.y + tiro.vely
        
        if tiro.x >= 800 or tiro.y >= 800 or tiro.x < 0 or tiro.y < 0 then
            resetTiro(tiro)
        end
    end
end

-- MARK: Reset Tiro
function resetTiro(tiro)
    tiro.x = -20
    tiro.y = -20
    tiro.velx = 0
    tiro.vely = 0
end

-- MARK: - IA Enemy
function moverInimigo(dt)
    local angle = angleToPoint(inimigo.x, inimigo.y, posx, posy)
    inimigo.x = inimigo.x + math.cos(angle) * inimigo.spd
    inimigo.y = inimigo.y + math.sin(angle) * inimigo.spd
    inimigo.angle = angle
end

-- MARK: Check hit on Enemy
function verificarAcerto(tiro)
    if tiro then
        local distancia = math.sqrt((tiro.x - inimigo.x)^2 + (tiro.y - inimigo.y)^2)
        if distancia < 20 then
            inimigo.vida = inimigo.vida - 1
            inimigo.flashTime = 0.4 -- 400 ms de piscar
            resetTiro(tiro)
            if inimigo.vida <= 0 then
                inimigo.morto = true
            end
        end
    end
end

-- Retorna o ângulo em que p2 está em relação a p1
function angleToPoint(x1, y1, x2, y2)
    return math.atan2(y2-y1, x2-x1)
end

-- Retorna todas as imagens de uma pasta em uma table
function loadSprites(directory)
    files = love.filesystem.getDirectoryItems(directory)
    sprites = {}
    for i = 1, #files do
        sprites[i] = love.graphics.newImage(directory .. "/" .. files[i])
    end
    return sprites
end
-- MARK: Player update
function PlayerUpdate(direction, dt)
    -- Atualiza posição
    posx, posy = posx + direction[1] * spd, posy + direction[2] * spd

    -- Atualiza qual o frame de animação (depois tenho que meter a statemachine pra ajudar a organizar isso, mas pelo menos ta funcionando se souber oq ta fazendo)
    player.sprites[1].time = player.sprites[1].time + dt
    if player.sprites[1].time > 1/player.sprites[1].fps then
        player.frame = player.frame + 1
        player.sprites[1].time = player.sprites[1].time - 1/player.sprites[1].fps
    end
    if player.frame > #player.sprites[1] then
        player.frame = 1
    end
end