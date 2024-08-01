local posx, posy = 200, 200
local spd = 5
local orange = {1,0.5,0}
local red = {0.7, 0, 0} -- Tiro
local white = {1,1,1}
local pele = {1, 0.8, 0.6}

local player = {}
local tiros = {}

local enemy = {}
local inimigo = {x = 400, y = 400, spd = 2, vida = 2, morto = false, flashTime = 0}

local tiro_atual = 1
LIMITE = 5

-- MARK: Function Load LOVE
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)
    
    player.head = {x = -10, y = -20, w = 20, h = 20}
    player.hand1 = {x = -40, y = -10, w = 10, h = 10}
    player.hand2 = {x = 30, y = -10, w = 10, h = 10}
    player.shirt = {x = -40, y = -5, w = 80, h = 15}

    enemy = love.graphics.newImage("assets/enemy.png")
    
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

    posx, posy = posx + dir[1] * spd, posy + dir[2] * spd

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
    love.graphics.line(mouseX - 20, mouseY, mouseX + 20, mouseY)
    love.graphics.line(mouseX, mouseY - 18, mouseX, mouseY + 18)
    
    love.graphics.push()
    love.graphics.translate(posx, posy)
    love.graphics.rotate(math.atan2(mouseY - posy, mouseX - posx) + math.pi / 2)
    
    love.graphics.setColor(pele)
    love.graphics.rectangle("fill", player.head.x, player.head.y, player.head.w, player.head.h)
    love.graphics.rectangle("fill", player.hand1.x, player.hand1.y, player.hand1.w, player.hand1.h)
    love.graphics.rectangle("fill", player.hand2.x, player.hand2.y, player.hand2.h, player.hand2.h)
    
    love.graphics.setColor(orange)
    love.graphics.rectangle("fill", player.shirt.x, player.shirt.y, player.shirt.w, player.shirt.h)
    
    love.graphics.pop()
    
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
    if enemy then
        -- Desenha o sprite do inimigo
        love.graphics.draw(enemy, inimigo.x, inimigo.y, 0, 1, 1, enemy:getWidth() / 2, enemy:getHeight() / 2)
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

        local angle = math.atan2(y - posy, x - posx)
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

-- MARK: - IA Inimigo
function moverInimigo(dt)
    local angle = math.atan2(posy - inimigo.y, posx - inimigo.x)
    inimigo.x = inimigo.x + math.cos(angle) * inimigo.spd
    inimigo.y = inimigo.y + math.sin(angle) * inimigo.spd
end

-- MARK: Check
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
