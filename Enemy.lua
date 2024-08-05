Enemy = {} -- class Enemy
Enemy.__index = Enemy

function Enemy:new(x, y, speed)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.speed = speed
    self.frame = 1
    self.angle = 0
    self.vida = 3
    self.morto = false
    self.flashTime = 0
    self.cego = false
    self.anims = {}
    return self
end

function Enemy:move(dt, player)
    local angle = angleToPoint(self.x, self.y, player.x, player.y)
    self.x = self.x + math.cos(angle) * self.speed
    self.y = self.y + math.sin(angle) * self.speed
    self.angle = angle
end

function Enemy:draw()
    local frame
    if self.morto then
        frame = getFrame(self.anims[2])
    else
        frame = getFrame(self.anims[1])
    end
    love.graphics.draw(frame, self.x, self.y, self.angle + math.pi/2, 1, 1, frame:getWidth()/2, frame:getHeight()/2)
end
