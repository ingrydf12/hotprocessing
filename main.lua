-- MARK: Demark variables
local posx, posy = 200, 200
local spd = 5
local spdEnemy = 2
local red = {0.7, 0, 0} -- Tiro
local white = {1,1,1}

local player = {frame = 1, sprites = {}, hitbox = {x = posx, y = posy, r = 20}}

local inimigos = {}
local walls = {}

local camera = {x = 400, y = 400}

local tiros = {}
local tiro_atual = 1
LIMITE = 10

-- MARK: Wave variables
local currentWave = 1
local inimigosPorWave = 4
local inimigosVivos = 0

-- MARK: Function Load LOVE
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)
    love.graphics.setPointSize(5)
    font = love.graphics.newFont("assets/fonts/superstar_memesbruh03.ttf", 24)
    iniciarWave(currentWave)

    -- require "waveSystem"
    require "raycast"

    -- Carrega animação teste do player
    player.sprites[1] = loadSprites("assets/sprites/player")
    player.sprites[1].fps = 2
    player.sprites[1].time = 0 --tempo decorrido, deixa como 0

    -- Cria alguns inimigos na fase
    --for i = 1, 4 do
        --inimigos[i] = createEnemy(150*(i+1%2),200+200*(i%2))
    --Carrega sprites do inimigo
        --inimigos[i].sprites[1] = loadSprites("assets/sprites/enemy")
        --inimigos[i].sprites[1].fps = 2
        --inimigos[i].sprites[1].time = 0
    --end
    
    -- Inicializa o array de tiros
    tiros = {}
    for i = 1, LIMITE do
        tiros[i] = {x = -20, y = -20, velx = 0, vely = 0}
    end

    -- Criei umas paredes
    walls[1] = createLine(0,0,800,0)
    walls[2] = createLine(800,800,800,0)
    walls[3] = createLine(0,800,0,0)
    walls[4] = createLine(800,800,0,800)
    walls[5] = createLine(400,600,400,200)
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

    camera.x, camera.y =  posx, posy

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

    -- Reduz o tempo de flash dos inimigos e atualiza o frame da animação
    for i = 1, #inimigos do
        if inimigos[i].flashTime > 0 then
            inimigos[i].flashTime = inimigos[i].flashTime - dt
        end
        if not inimigos[i].morto then
            inimigos[i].sprites[1].time = inimigos[i].sprites[1].time + dt
            if inimigos[i].sprites[1].time > 1/inimigos[i].sprites[1].fps then
                inimigos[i].frame = inimigos[i].frame + 1
                inimigos[i].sprites[1].time = inimigos[i].sprites[1].time - 1/inimigos[i].sprites[1].fps
            end
            if inimigos[i].frame > #inimigos[i].sprites[1] then
                inimigos[i].frame = 1
            end
        end
    end

    -- # MARK: Verificar se a wave foi completada
    verificarWaveCompleta()

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
        love.graphics.line(ConvertToCamera(walls[i]))
    end

    -- Desenha
    love.graphics.setFont(font)
    love.graphics.print("Wave: " .. currentWave, 10, 10)
    love.graphics.print("Inimigos: " .. inimigosVivos, 10, 30)
    --waveSystem.counter()

    -- MARK: Visão dos inimigos
    -- (talvez tenha que ir pro love.update mas não sei como passar isso pra la)
    for i = 1, #inimigos do
        --love.graphics.line(ConvertToCamera({inimigos[i].x, inimigos[i].y, posx, posy}))
        for _ = 1, #walls do
            if inimigos[i].morto then
                break
            end
            local ponto = collisionPoint({inimigos[i].x, inimigos[i].y, posx, posy}, walls[_])
            --se existir um ponto de interseção E o ponto estiver mais próximo doq o player
            if ponto and dist(inimigos[i].x, inimigos[i].y, ponto[1], ponto[2]) < dist(inimigos[i].x, inimigos[i].y, posx, posy) then
                love.graphics.setColor(red)
                love.graphics.points(ponto[1] - camera.x + 400,ponto[2]-camera.y +400)
                love.graphics.setColor(white)
                inimigos[i].cego = true
                break
            else
                inimigos[i].cego = false
            end
        end
    end

    -- Draw player
    love.graphics.draw(player.sprites[1][player.frame], posx-camera.x+400, posy-camera.y+400, angleToPoint(posx-camera.x+400, posy-camera.y+400, mouseX, mouseY)+math.pi/2, 1, 1, player.sprites[1][player.frame]:getWidth()/2, player.sprites[1][player.frame]:getHeight()/2)

    -- Draw tiros
    for i = 1, LIMITE do
        local tiro = tiros[i]
        love.graphics.setColor(red)
        love.graphics.rectangle("fill", tiro.x-camera.x+400, tiro.y-camera.y+400, 10, 20)
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
            love.graphics.draw(inimigos[i].sprites[1][inimigos[i].frame], inimigos[i].x-camera.x+400, inimigos[i].y-camera.y+400, inimigos[i].angle+math.pi/2, 1, 1, inimigos[i].sprites[1][inimigos[i].frame]:getWidth() / 2, inimigos[i].sprites[1][inimigos[i].frame]:getHeight() / 2)
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

        local angle = angleToPoint(posx-camera.x+400, posy-camera.y+400, x, y)
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
        
        if tiro.x >= camera.x+400 or tiro.y >= camera.y+400 or tiro.x < camera.x-400 or tiro.y < camera.y-400 then
            resetTiro(tiro)
        end
    end
end

-- MARK: Reset Tiro
function resetTiro(tiro)
    tiro.x = -1500
    tiro.y = -1500
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
                 -- # MARK: Reduzir contagem de inimigos vivos
                 inimigosVivos = inimigosVivos - 1
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
    local collide_count = {0,0}
    -- Atualiza posição
    for i = 1, #walls do
        player.hitbox.x = posx + direction[1] * spd
        if collides(player.hitbox, walls[i]) then
            collide_count[1] = collide_count[1] + 1
        end
        player.hitbox.x = posx
        player.hitbox.y = posy + direction[2] * spd
        if collides(player.hitbox, walls[i]) then
            collide_count[2] = collide_count[2] + 1
        end
        player.hitbox.y = posy
    end
    if collide_count[1] == 0 then
        posx = posx + direction[1] * spd
    end
    if collide_count[2] == 0 then
        posy = posy + direction[2] * spd
    end

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

function dist(x1, y1, x2, y2)
    return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

-- MARK: Create new enemy
function createEnemy(xis,yps)
    return {x = xis, y = yps, spd = 2, vida = 2, morto = false, cego = false, flashTime = 0, frame = 1, sprites = {}}
end

function ConvertToCamera(points)
    local newpoints = {}
    newpoints[1] = points[1] - camera.x + 400
    newpoints[2] = points[2] - camera.y + 400
    newpoints[3] = points[3] - camera.x + 400
    newpoints[4] = points[4] - camera.y + 400
    return newpoints
end

-- MARK: Collision
function collides(circle, line)
    local rect = lineToRect(line)
    local circleDistance = {}
    circleDistance.x = math.abs(circle.x - rect.x)
    circleDistance.y = math.abs(circle.y - rect.y)

    if (circleDistance.x > (rect.width/2 + circle.r)) then
        return false
    end
    if (circleDistance.y > (rect.height/2 + circle.r)) then
        return false
    end
    if (circleDistance.x <= (rect.width/2)) then
        return true
    end
    if (circleDistance.y <= (rect.height/2)) then
        return true
    end

    cornerDistance_sq = (circleDistance.x - rect.width/2)^2 + (circleDistance.y - rect.height/2)^2

    return (cornerDistance_sq <= (circle.r^2))  
end

-- MARK: Wave setting
-- # Função para iniciar uma nova wave
function iniciarWave(wave)
    inimigos = {}
    -- Aumenta 3 inimigos a cada wave 
    inimigosVivos = inimigosPorWave + 3 * wave
    for i = 1, inimigosVivos do
        inimigos[i] = createEnemy(50 + 70*math.floor(i/2),50+700*math.floor(((i-1)/2)%2))
        inimigos[i].sprites[1] = loadSprites("assets/sprites/enemy/walk")
        inimigos[i].sprites[1].fps = 5
        inimigos[i].sprites[1].time = 0
    end
end

-- Função para verificar se a wave foi completada
function verificarWaveCompleta()
    if inimigosVivos <= 0 then
        currentWave = currentWave + 1
        spdEnemy = spdEnemy + 0.5 -- Aumenta a velocidade a cada wave
        iniciarWave(currentWave)
    end
end

function createEnemy(x,y)
    return {x = x, y = y, spd = spdEnemy, frame = 1, angle = 0, vida = 3, morto = false, flashTime = 0, cego = false, sprites = {}}
end