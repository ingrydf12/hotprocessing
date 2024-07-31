-- MARK: - Initialize
local posx, posy = 200, 200
local spd = 5
local red = {1, 0, 0}
local green = {0, 1, 0}
local pele = {1, 0.8, 0.6}

local player = {}
local tiro = {x = -20, y = -20, velx = 0, vely = 0}

-- MARK: - Load LOVE function
function love.load()
    love.window.setMode(800, 800)
    love.graphics.setLineWidth(4)
    
    player.head = {x = -10, y = -20, w = 20, h = 20}
    player.hand1 = {x = -40, y = -10, w = 10, h = 10}
    player.hand2 = {x = 30, y = -10, w = 10, h = 10}
    player.shirt = {x = -40, y = -5, w = 80, h = 15}
end

-- MARK: - Mov
function love.update(dt)
    if love.keyboard.isDown("a") then
        posx = posx - spd
    elseif love.keyboard.isDown("d") then
        posx = posx + spd
    elseif love.keyboard.isDown("w") then
        posy = posy - spd
    elseif love.keyboard.isDown("s") then
        posy = posy + spd
    end

    updateTiro()
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
    love.graphics.circle("fill", tiro.x, tiro.y, 10)
end

-- MARK: - Powpow setting
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        local angle = math.atan2(y - posy, x - posx)
        tiro.x = posx
        tiro.y = posy
        tiro.velx = spd * 2 * math.cos(angle)
        tiro.vely = spd * 2 * math.sin(angle)
    end
end

function updateTiro()
    tiro.x = tiro.x + tiro.velx
    tiro.y = tiro.y + tiro.vely
    
    if tiro.x >= 800 or tiro.y >= 800 or tiro.x < 0 or tiro.y < 0 then
        resetTiro()
    end
end

function resetTiro()
    tiro.x = -20
    tiro.y = -20
    tiro.velx = 0
    tiro.vely = 0
end
