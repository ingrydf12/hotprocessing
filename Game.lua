Game = {}

function Game:new()
    local game = {
        posx = 200,
        posy = 200,
        spd = 5,
        spdEnemy = 2,
        red = {0.7, 0, 0},  -- Tiro
        white = {1, 1, 1},
        black = {0, 0, 0},
        player = {frame = 1, anims = {}, hitbox = {x = 200, y = 200, r = 20}},
        inimigos = {},
        walls = {},
        chao = nil,
        tiros = {},
        spdTiro = 6,
        tiro_atual = 1,
        LIMITE = 10,
        wallSizeIncreaseWave = 5,  -- Wave a partir da qual o tamanho aumenta
        floorScale = 1,  -- Escala padrão do piso
    }
    setmetatable(game, self)
    self.__index = self
    return game
end

function Game:load()
    love.window.setTitle("Hotline ISMD")  -- Seta o titulo da janela
    love.window.setMode(1200, 800)
    love.graphics.setLineWidth(4)
    love.graphics.setPointSize(5)
    self.font = love.graphics.newFont("assets/fonts/superstar_memesbruh03.ttf", 24)
    self.sound = love.audio.newSource("assets/sfx/tele_001.wav", "stream")
    self.masterVolume = 0.2

    -- set volume
    self.sound:setVolume(self.masterVolume)

    require "waveSystem"
    require "raycast"
    require "animation"

    currentWave = 1  -- Defina o valor inicial de currentWave
    waveSystem.iniciarWave(currentWave)

    -- Carrega animação teste do player
    self.player.anims[1] = newAnim("assets/sprites/player", 2)

    self.chao = love.graphics.newImage("assets/sprites/floor/chao.png")

    -- Inicializa o array de tiros
    for i = 1, self.LIMITE do
        table.insert(self.tiros, {x = -1500, y = -1500, velx = 0, vely = 0})
    end
end

function Game:create_walls()
    self.walls = {}
    table.insert(self.walls, createLine(0, 0, wallSize, 0))
    table.insert(self.walls, createLine(wallSize, 0, wallSize, wallSize))
    table.insert(self.walls, createLine(wallSize, wallSize, 0, wallSize))
    table.insert(self.walls, createLine(0, wallSize, 0, 0))
    table.insert(self.walls, createLine(wallSize / 2, wallSize * 3 / 4, wallSize / 2, wallSize / 4))
end

function Game:update(dt)
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

    self:player_update(dir, dt)

    for i = 1, self.LIMITE do
        self:update_tiro(self.tiros[i])
        for _, inimigo in ipairs(self.inimigos) do
            if not inimigo.morto then
                self:verificar_acerto(self.tiros[i], inimigo)
            end
        end
    end

    for _, inimigo in ipairs(self.inimigos) do
        if not inimigo.morto and not inimigo.cego then
            self:mover_inimigo(dt, inimigo)
        end
    end

    for _, inimigo in ipairs(self.inimigos) do
        if inimigo.flashTime > 0 then
            inimigo.flashTime = inimigo.flashTime - dt
        end

        if inimigo.morto then
            updateFrame(inimigo.anims[2], dt)
        else
            updateFrame(inimigo.anims[1], dt)
        end

        for _, wall in ipairs(self.walls) do
            if inimigo.morto then
                break
            end
            local ponto = collisionPoint({inimigo.x, inimigo.y, self.posx, self.posy}, wall)
            if ponto and dist(inimigo.x, inimigo.y, ponto[1], ponto[2]) < dist(inimigo.x, inimigo.y, self.posx, self.posy) then
                inimigo.cego = true
                break
            else
                inimigo.cego = false
            end
        end
    end

    self:verificar_wave_completa()
end

function Game:draw()
    love.graphics.clear(0, 0, 0, 1)

    local mouseX = love.mouse.getX()
    local mouseY = love.mouse.getY()

    love.graphics.push()
    love.graphics.translate(-self.posx + 600, -self.posy + 400)

    love.graphics.setColor(self.white)

    for _, wall in ipairs(self.walls) do
        love.graphics.line(wall)
    end

    local frame = getFrame(self.player.anims[1])
    love.graphics.draw(frame, self.posx, self.posy, angleToPoint(600, 400, mouseX, mouseY) + math.pi / 2, 1, 1, frame:getWidth() / 2, frame:getHeight() / 2)

    for _, tiro in ipairs(self.tiros) do
        love.graphics.setColor(self.red)
        love.graphics.rectangle("fill", tiro.x, tiro.y, 10, 20)
    end

    for _, inimigo in ipairs(self.inimigos) do
        if inimigo.flashTime > 0 then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        local frame = getFrame(inimigo.morto and inimigo.anims[2] or inimigo.anims[1])
        love.graphics.draw(frame, inimigo.x, inimigo.y, inimigo.angle + math.pi / 2, 1, 1, frame:getWidth() / 2, frame:getHeight() / 2)
    end

    love.graphics.pop()

    -- UI drawing omitted for brevity

    self:counter()
end

function Game:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        self.tiro_atual = (self.tiro_atual % self.LIMITE) + 1
        local angle = angleToPoint(600, 400, x, y)
        local tiro = self.tiros[self.tiro_atual]
        tiro.x = self.posx
        tiro.y = self.posy
        tiro.velx = self.spdTiro * 2 * math.cos(angle)
        tiro.vely = self.spdTiro * 2 * math.sin(angle)
    end
end

function Game:update_tiro(tiro)
    if tiro then
        tiro.x = tiro.x + tiro.velx
        tiro.y = tiro.y + tiro.vely

        if tiro.x >= self.posx + 600 or tiro.y >= self.posy + 400 or tiro.x < self.posx - 600 or tiro.y < self.posy - 400 then
            self:reset_tiro(tiro)
        end
    end
end

function Game:reset_tiro(tiro)
    tiro.x = -1500
    tiro.y = -1500
    tiro.velx = 0
    tiro.vely = 0
end

function Game:mover_inimigo(dt, inimigo)
    local angle = angleToPoint(inimigo.x, inimigo.y, self.posx, self.posy)
    inimigo.x = inimigo.x + math.cos(angle) * inimigo.spd
    inimigo.y = inimigo.y + math.sin(angle) * inimigo.spd
    inimigo.angle = angle
end

function Game:verificar_acerto(tiro, inimigo)
    local distancia = math.sqrt((tiro.x - inimigo.x) ^ 2 + (tiro.y - inimigo.y) ^ 2)
    if distancia < 20 then
        inimigo.vida = inimigo.vida - 1
        inimigo.flashTime = 0.4
        self:reset_tiro(tiro)
        love.audio.play(self.sound)
        if inimigo.vida <= 0 then
            inimigo.morto = true
            self.inimigos_vivos = self.inimigos_vivos - 1
        end
    end
end

function Game:player_update(direction, dt)
    local collide_count = {0, 0}

    for _, wall in ipairs(self.walls) do
        self.player.hitbox.x = self.posx + direction[1] * self.spd
        if collides(self.player.hitbox, wall) then
            collide_count[1] = collide_count[1] + 1
        end
        self.player.hitbox.x = self.posx
        self.player.hitbox.y = self.posy + direction[2] * self.spd
        if collides(self.player.hitbox, wall) then
            collide_count[2] = collide_count[2] + 1
        end
        self.player.hitbox.y = self.posy
    end

    if collide_count[1] == 0 then
        self.posx = self.posx + direction[1] * self.spd
    end
    if collide_count[2] == 0 then
        self.posy = self.posy + direction[2] * self.spd
    end

    updateFrame(self.player.anims[1], dt)
end

function Game:verificar_wave_completa()
    -- Implementar lógica de verificação da wave
end

return Game
