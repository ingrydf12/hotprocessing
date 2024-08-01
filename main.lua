-- MARK: - Initialize
local posx, posy = 200, 200
local spd = 5
local red = {1, 0, 0}
local green = {0, 1, 0}
local pele = {1, 0.8, 0.6}

local player = {}
local tiros = {}

local tiro_atual = 1
LIMITE = 5


-- MARK: - Load LOVE function
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)
    
    player.head = {x = -10, y = -20, w = 20, h = 20}
    player.hand1 = {x = -40, y = -10, w = 10, h = 10}
    player.hand2 = {x = 30, y = -10, w = 10, h = 10}
    player.shirt = {x = -40, y = -5, w = 80, h = 15}

    for i = 1, LIMITE do
        tiros[i] = {x = -20, y = -20, velx = 0, vely = 0}
    end
end

-- MARK: - Mov
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

    posx, posy = posx + dir[1]*spd, posy + dir[2]*spd

    for i = 1, LIMITE do
        updateTiro(tiros[i])
    end
end

-- MARK: - Draw
function love.draw()
    -- Set background color
    love.graphics.clear(0, 0, 0, 1)
    
    -- Draw bezier curves
    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    love.graphics.setColor(green)
    love.graphics.line(mouseX - 20, mouseY, mouseX - 20, mouseY + 25, mouseX + 20, mouseY + 25, mouseX + 20, mouseY)
    love.graphics.line(mouseX - 20, mouseY, mouseX - 20, mouseY - 25, mouseX + 20, mouseY - 25, mouseX + 20, mouseY)
    love.graphics.line(mouseX - 20, mouseY, mouseX + 20, mouseY)
    love.graphics.line(mouseX, mouseY - 18, mouseX, mouseY + 18)
    
    -- Draw player
    love.graphics.push()
    love.graphics.translate(posx, posy)
    love.graphics.rotate(math.atan2(mouseY - posy, mouseX - posx) + math.pi / 2)
    
    love.graphics.setColor(pele)
    love.graphics.rectangle("fill", player.head.x, player.head.y, player.head.w, player.head.h)
    love.graphics.rectangle("fill", player.hand1.x, player.hand1.y, player.hand1.w, player.hand1.h)
    love.graphics.rectangle("fill", player.hand2.x, player.hand2.y, player.hand2.w, player.hand2.h)
    
    love.graphics.setColor(red)
    love.graphics.rectangle("fill", player.shirt.x, player.shirt.y, player.shirt.w, player.shirt.h)
    
    love.graphics.pop()
    
    -- Draw tiro
    love.graphics.setColor(red)
    for i = 1, LIMITE do
        love.graphics.circle("fill", tiros[i].x, tiros[i].y, 10)
    end
end

-- MARK: - Powpow setting
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        
        tiro_atual = tiro_atual + 1
        if tiro_atual == LIMITE+1 then
            tiro_atual = 1
        end

        local angle = math.atan2(y - posy, x - posx)
        tiros[tiro_atual].x = posx
        tiros[tiro_atual].y = posy
        tiros[tiro_atual].velx = spd * 2 * math.cos(angle)
        tiros[tiro_atual].vely = spd * 2 * math.sin(angle)
    end
end

function updateTiro(tiro)
    tiro.x = tiro.x + tiro.velx
    tiro.y = tiro.y + tiro.vely
    
    if tiro.x >= 800 or tiro.y >= 800 or tiro.x < 0 or tiro.y < 0 then
        resetTiro(tiro)
    end
end

function resetTiro(tiro)
    tiro.x = -20
    tiro.y = -20
    tiro.velx = 0
    tiro.vely = 0
end
