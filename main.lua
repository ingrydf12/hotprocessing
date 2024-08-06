-- MARK: Demark variables
local posx, posy = 200, 200
local spd = 5
local spdEnemy = 2
local red = {0.7, 0, 0} -- Tiro
local white = {1,1,1}
local black = {0,0,0}

local player = {frame = 1, anims = {}, hitbox = {x = posx, y = posy, r = 20}, vida = 5, iTime = 0}
--local camera = {x = posx, y = posy}
local inimigos = {}
local walls = {}

local tiros = {}
local spdTiro = 6
local tiro_atual = 1
LIMITE = 10

local wallSizeIncreaseWave = 5 -- Wave a partir da qual o tamanho aumenta
local floorScale = 1 -- Escala padrão do piso

local spawnTime = 1.5 --intervalo entre spawn de inimigos (em segundos)
local groupSize = 3 --quantidade de inimigos por spawn
local waveTime = 0 --tempo na wave, atualizado automaticamente
-- MARK: LOVE LOAD
function love.load()
    -- UI/UX
    love.window.setTitle("Hotline ISMD") -- Seta o titulo da janela
    love.window.setMode(1200, 800)
    love.graphics.setLineWidth(4)
    love.graphics.setPointSize(5)
    font = love.graphics.newFont("assets/fonts/superstar_memesbruh03.ttf", 24)
    sound = love.audio.newSource("assets/sfx/tele_001.wav", "stream")
    masterVolume = 0.2

    -- set volume
    sound:setVolume(masterVolume)

    require "waveSystem"
    require "raycast"
    require "animation"

    iniciarWave(currentWave)

    -- Carrega animação teste do player
    player.anims[1] = newAnim("assets/sprites/player", 5)

    chao = love.graphics.newImage("assets/sprites/floor/chao.png")

    -- Inicializa o array de tiros
    tiros = {}
    for i = 1, LIMITE do
        tiros[i] = {x = -1500, y = -1500, velx = 0, vely = 0}
    end

end

-- MARK: LOVE UPDATE
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

    
    if love.keyboard.isDown("k") then
        inimigosVivos = 0
    end

    PlayerUpdate(dir, dt)
    --camera = {x = clamp(posx, wallSize/2-50, wallSize/2+50), y = clamp(posy, wallSize/2-50, wallSize/2+50)}

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

    -- MARK: Enemy update
    -- Atualiza os inimigos (flashTime, animação, visão do player)
    for i = 1, #inimigos do
        if inimigos[i].flashTime > 0 then
            inimigos[i].flashTime = inimigos[i].flashTime - dt
        end

        -- Animação dos inimigos mortos
        if inimigos[i].morto then
            updateFrame(inimigos[i].anims[2], dt)
        else
            updateFrame(inimigos[i].anims[1], dt) -- Atualiza animação normal
        end

        -- Animação dos inimigos
        if not inimigos[i].morto then
            updateFrame(inimigos[i].anims[1], dt)
        end

        if inimigos[i].morto then
            updateFrame(inimigos[i].anims[2], dt)
        end

        -- MARK: Visão dos inimigos
        for _ = 1, #walls do
            if inimigos[i].morto then
                
                break
            end
            local ponto = collisionPoint({inimigos[i].x, inimigos[i].y, posx, posy}, walls[_])
            --se existir um ponto de interseção E o ponto estiver mais próximo doq o player
            if ponto and dist(inimigos[i].x, inimigos[i].y, ponto[1], ponto[2]) < dist(inimigos[i].x, inimigos[i].y, posx, posy) then
                inimigos[i].cego = true
                break
            else
                inimigos[i].cego = false
            end
        end

        -- Colisão com o player 
        if player.iTime <= 0 and not inimigos[i].morto and dist(inimigos[i].x,inimigos[i].y, posx, posy) < 10 then
            player.vida = player.vida - 1
            player.iTime = 0.65 -- 650ms
        end


    end

    -- # MARK: Verificar se a wave foi completada
    spawnEnemies(dt)
    verificarWaveCompleta()

end

-- MARK: LOVE DRAW
function love.draw()
    love.graphics.clear(0, 0, 0, 1)
    
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()
    
    love.graphics.push()
    love.graphics.translate(-posx+600, -posy+400)

    love.graphics.setColor(white)
    
    -- Paredes (só pra saber onde estão enquanto não tem sprite)
    for i = 1, #walls do
        love.graphics.line(walls[i])
    end

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
        local frame
        if inimigos[i].morto then
            frame = getFrame(inimigos[i].anims[2]) -- Usa animação de morte
        else
            frame = getFrame(inimigos[i].anims[1]) -- Usa animação normal
        end
        
        if frame then
            love.graphics.draw(frame, inimigos[i].x, inimigos[i].y, inimigos[i].angle+math.pi/2, 1, 1, frame:getWidth() / 2, frame:getHeight() / 2)
        else
            love.graphics.print("Erro ao carregar sprite do inimigo", 10, 10)
            end
        end
    
    -- Draw player
    love.graphics.setColor(white)
    local frame = getFrame(player.anims[1])
    love.graphics.draw(frame, posx, posy, angleToPoint(600, 400, mouseX, mouseY)+math.pi/2, 1, 1, frame:getWidth()/2, frame:getHeight()/2)
    love.graphics.pop()

    -- MARK: Draw UI
    -- Desenha UI mostrando os controles usados pelo player
    -- nao recomendo usar função que carrega arquivo no draw(), de preferencia carrega logo no global e só usa o draw pra desenhar
    local teclaW = love.graphics.newImage("assets/sprites/teclas/teclaw.png")
    local teclaA = love.graphics.newImage("assets/sprites/teclas/teclaa.png")
    local teclaS = love.graphics.newImage("assets/sprites/teclas/teclas.png")
    local teclaD = love.graphics.newImage("assets/sprites/teclas/teclad.png")

    if love.keyboard.isDown("w") then
        love.graphics.draw(teclaW, 1100, 40,0,2,2)
    end
    if love.keyboard.isDown("a") then
        love.graphics.draw(teclaA, 1100, 70,0,2,2)
    end
    if love.keyboard.isDown("s") then
        love.graphics.draw(teclaS, 1100, 100,0,2,2)
    end
    if love.keyboard.isDown("d") then
        love.graphics.draw(teclaD, 1100, 130,0,2,2)
    end

    -- Crosshair
    love.graphics.line(mouseX - 20, mouseY, mouseX + 20, mouseY)
    love.graphics.line(mouseX, mouseY - 18, mouseX, mouseY + 18)
    
    -- Info
    counter()
    love.graphics.print(player.vida .. " HP", 580, 450)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        tiro_atual = tiro_atual + 1
        if tiro_atual > LIMITE then
            tiro_atual = 1
        end

        local angle = angleToPoint(600, 400, x, y)
        tiros[tiro_atual].x = posx
        tiros[tiro_atual].y = posy
        tiros[tiro_atual].velx = spdTiro * 2 * math.cos(angle)
        tiros[tiro_atual].vely = spdTiro * 2 * math.sin(angle)
    end
end

-- MARK: UP Tiro
function updateTiro(tiro)
    if tiro then
        tiro.x = tiro.x + tiro.velx
        tiro.y = tiro.y + tiro.vely
        
        if tiro.x >= posx+600 or tiro.y >= posy+400 or tiro.x < posx-600 or tiro.y < posy-400 then
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
        local distancia = dist(tiro.x, tiro.y, inimigos[i].x, inimigos[i].y)
        if distancia < 20 then
            inimigos[i].vida = inimigos[i].vida - 1
            inimigos[i].flashTime = 0.4 -- 400 ms de piscar
            resetTiro(tiro)
            love.audio.play(sound)
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

    -- Atualiza qual o frame de animação
    if direction[1] ~= 0 or direction[2] ~=0 then
        updateFrame(player.anims[1], dt)
    end

    -- Tempo de imunidade
    player.iTime = player.iTime - dt
end

function dist(x1, y1, x2, y2)
    return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

-- MARK: Create new enemy
function createEnemy(xis,yps)
    return {x = xis, y = yps, spd = 2, vida = 2, morto = false, cego = false, flashTime = 0, frame = 1, anims = {}}
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
        local var = math.random(2)
        inimigos[i] = createEnemy(3000,0)
        inimigos[i].anims[1] = newAnim("assets/sprites/enemy" .. var .. "/walk", 5) -- Animação de andar
        inimigos[i].anims[2] = newAnim("assets/sprites/enemy".. var .."/enemy-death", 1, false) -- Animação de morte
        -- inimigos[i].anims[2] = newAnim ("assets/sprites/enemy/death", 5)
    end
    -- Aumenta o tamanho das paredes a partir da wave 5
    if currentWave >= wallSizeIncreaseWave then
        wallSize = 1200
        floorScale = 1.5
    else
        wallSize = 800 * 1.2
    end

    layout = chooseLayout(math.random(3))
    walls = layout.walls
    spawnPoints = layout.points
    spawnedCount = 0
end

-- Função para verificar se a wave foi completada
function verificarWaveCompleta()
    if inimigosVivos <= 0 then
        currentWave = currentWave + 1
        spdEnemy = spdEnemy + 0.5 -- Aumenta a velocidade a cada wave
        iniciarWave(currentWave)
        waveTime = 0
    end
end

function createEnemy(x,y)
    return {x = x, y = y, spd = spdEnemy, frame = 1, angle = 0, vida = 3, morto = false, flashTime = 0, cego = false, anims = {}}
end

function clamp(a, min, max)
    if a < min then
        return min
    end
    if a > max then
        return max
    end
    return a
end
-- MARK: Room configs
function chooseLayout(i)
    local layout = {walls = {createLine(0, 0, wallSize, 0), 
    createLine(wallSize, 0, wallSize, wallSize),
    createLine(wallSize, wallSize, 0, wallSize),
    createLine(0, wallSize, 0, 0)},
    points = {}}

    if i == 1 then
        layout.walls[5] = createLine(1/6*wallSize,1/6*wallSize, 0.4*wallSize, 1/6*wallSize)
        layout.walls[6] = createLine(1/6*wallSize, 1/6*wallSize, 1/6*wallSize, 0.4*wallSize)
        layout.walls[7] = createLine(5/6*wallSize,1/6*wallSize, 0.6*wallSize, 1/6*wallSize)
        layout.walls[8] = createLine(5/6*wallSize, 1/6*wallSize, 5/6*wallSize, 0.4*wallSize)
        layout.walls[9] = createLine(5/6*wallSize, 5/6*wallSize, 5/6*wallSize, 0.6*wallSize)
        layout.walls[10] = createLine(5/6*wallSize, 5/6*wallSize, 0.6*wallSize, 5/6*wallSize)
        layout.walls[11] = createLine(1/6*wallSize, 5/6*wallSize, 1/6*wallSize, 0.6*wallSize)
        layout.walls[12] = createLine(1/6*wallSize, 5/6*wallSize, 0.4*wallSize, 5/6*wallSize)
        layout.points = {{wallSize*0.5, wallSize*0.1}, {wallSize*0.5, wallSize*0.9}, {wallSize*0.1,wallSize*0.5}, {wallSize*0.9,wallSize*0.5},
        {0.1*wallSize, 0.1*wallSize}, {0.9*wallSize,0.9*wallSize}, {0.1*wallSize, 0.9*wallSize},{0.9*wallSize, 0.1*wallSize}}

    elseif i == 2 then
        layout.walls[5] = createLine(0.5*wallSize, 1/4*wallSize,0.5*wallSize, 3/4*wallSize)
        layout.walls[6] = createLine(1/4*wallSize, 0.5*wallSize, 3/4*wallSize, 0.5*wallSize)
        layout.points = {{1/6*wallSize,1/6*wallSize},{5/6*wallSize,1/6*wallSize},{5/6*wallSize, 5/6*wallSize},{1/6*wallSize, 5/6*wallSize}}

    elseif i == 3 then
        layout.walls[5] = createLine(wallSize*0.5, wallSize*1/6,wallSize*0.5, wallSize*2/6)
        layout.walls[6] = createLine(wallSize*0.5, wallSize*5/6,wallSize*0.5, wallSize*4/6)
        layout.walls[7] = createLine(wallSize*1/6,wallSize*0.5,wallSize*2/6,wallSize*0.5)
        layout.walls[8] = createLine(wallSize*5/6,wallSize*0.5,wallSize*4/6,wallSize*0.5)
        layout.points = {{0.5*wallSize, 0.5*wallSize},{wallSize/4, wallSize/4},{wallSize/4, wallSize*3/4},{wallSize*3/4, wallSize*3/4},{wallSize*3/4, wallSize/4}}
    end
    
    return layout
end
-- Spawna inimigos de acordo com o tempo decorrido na wave
function spawnEnemies(dt)
    waveTime = waveTime + dt
    if waveTime > spawnTime then
        waveTime = waveTime - spawnTime

        for i = 1 + spawnedCount, groupSize + spawnedCount do
            if i > #inimigos then 
                break 
            end
            ponto = spawnPoints[math.random(#spawnPoints)]
            inimigos[i].x = ponto[1] + math.random(-20, 20)
            inimigos[i].y = ponto[2] + math.random(-20, 20)
        end
        spawnedCount = spawnedCount + groupSize
    end
end