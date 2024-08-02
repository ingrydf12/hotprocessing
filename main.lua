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
local inimigos = {}

local tiro_atual = 1
LIMITE = 10

-- MARK: Function Load LOVE
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)
    love.graphics.setPointSize(5)

    require "raycast"

    -- Carrega animação teste do player
    player.sprites[1] = loadSprites("assets/sprites/player")
    player.sprites[1].fps = 2
    player.sprites[1].time = 0

    -- Cria alguns inimigos na fase
    for i = 1, 3 do
        inimigos[i] = createEnemy(100*i,400)
    --Carrega sprite do inimigo (tá estruturado diferente do player pq eu tava com preguiça pra atualizar o codigo no love.draw)
        inimigos[i].sprites = loadSprites("assets/sprites/enemy")
    end
    
    -- Inicializa o array de tiros
    tiros = {}
    for i = 1, LIMITE do
        tiros[i] = {x = -20, y = -20, velx = 0, vely = 0}
    end

    -- Criei umas paredes
    walls[1] = createLine(500,100,500,600)
    walls[2] = createLine(100,100,300,400)
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

    -- Atualiza tiros e verifica o estado dos inimigos
    for i = 1, LIMITE do
        updateTiro(tiros[i])
        for _ = 1, #inimigos do
            if not inimigos[_].morto then
                verificarAcerto(tiros[i], _)
            end
        end
    end
    
    for i = 1, #inimigos do
        if not inimigos[i].morto and not inimigos[i].cego then
            moverInimigo(dt, i)
        end
    end

    -- Reduz o tempo de flash dos inimigos
    for i = 1, #inimigos do
        if inimigos[i].flashTime > 0 then
            inimigos[i].flashTime = inimigos[i].flashTime - dt
        end
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
    
    -- Paredes (só pra saber onde estão enquanto não tem sprite)
    for i = 1, #walls do
        love.graphics.line(walls[i])
    end

    -- MARK: Visão dos inimigos
    for i = 1, #inimigos do
        love.graphics.line(inimigos[i].x, inimigos[i].y, posx, posy)
        for _ = 1, #walls do
            local ponto = collisionPoint({inimigos[i].x, inimigos[i].y, posx, posy}, walls[_])
            --se existir um ponto de interseção E o ponto estiver mais próximo doq o player
            if ponto and Dist(inimigos[i].x, inimigos[i].y, ponto[1], ponto[2]) < Dist(inimigos[i].x, inimigos[i].y, posx, posy) then
                love.graphics.setColor(red)
                love.graphics.points(ponto)
                love.graphics.setColor(white)
                inimigos[i].cego = true
                break
            else
                inimigos[i].cego = false
            end
        end
    end
    

    -- Draw player
    love.graphics.draw(player.sprites[1][player.frame], posx, posy, angleToPoint(posx, posy, mouseX, mouseY)+math.pi/2, 1, 1, player.sprites[1][player.frame]:getWidth()/2, player.sprites[1][player.frame]:getHeight()/2)
    
    -- Draw tiros
    for i = 1, LIMITE do
        local tiro = tiros[i]
        love.graphics.setColor(red)
        love.graphics.rectangle("fill", tiro.x, tiro.y, 10, 20)
    end

    -- MARK: - "Knockback" effect on enemys
    for i = 1, #inimigos do
        if inimigos[i].flashTime > 0 then
            love.graphics.setColor(1, 0, 0) -- Vermelho
        else
            love.graphics.setColor(1, 1, 1) -- Branco (cor padrão)
        end
    
        -- MARK: Sprite enemy load
        if inimigos[i].sprites then
            -- Desenha o sprite do inimigo
            love.graphics.draw(inimigos[i].sprites[inimigos[i].frame], inimigos[i].x, inimigos[i].y, inimigos[i].angle+math.pi/2, 1, 1, inimigos[i].sprites[inimigos[i].frame]:getWidth() / 2, inimigos[i].sprites[inimigos[i].frame]:getHeight() / 2)
        else
            -- Exibe uma mensagem de erro se o sprite não for carregado corretamente
            love.graphics.print("Erro ao carregar sprite do inimigo", 10, 10)
        end
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
function moverInimigo(dt, i)
    local angle = angleToPoint(inimigos[i].x, inimigos[i].y, posx, posy)
    inimigos[i].x = inimigos[i].x + math.cos(angle) * inimigos[i].spd
    inimigos[i].y = inimigos[i].y + math.sin(angle) * inimigos[i].spd
    inimigos[i].angle = angle
end

-- MARK: Check hit on Enemy
function verificarAcerto(tiro, i)
    if tiro then
        local distancia = math.sqrt((tiro.x - inimigos[i].x)^2 + (tiro.y - inimigos[i].y)^2)
        if distancia < 20 then
            inimigos[i].vida = inimigos[i].vida - 1
            inimigos[i].flashTime = 0.4 -- 400 ms de piscar
            resetTiro(tiro)
            if inimigos[i].vida <= 0 then
                inimigos[i].morto = true
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

function Dist(x1, y1, x2, y2)
    return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

function createEnemy(xis,yps)
    return {x = xis, y = yps, spd = 2, vida = 2, morto = false, cego = false, flashTime = 0, frame = 1}
end