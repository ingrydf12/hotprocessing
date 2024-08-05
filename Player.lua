-- Testing implementation POO in Lua
Player = {} -- class Player
Player.__index = Player

-- MARK: - Create
function Player:new(x, y, speed)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.speed = speed
    self.frame = 1
    self.anims = {}
    self.hitbox = {x = x, y = y, r = 20}
    return self
end

-- MARK: - Move
function Player:move(dir, dt, walls)
    local collide_count = {0, 0}
    for i = 1, #walls do
        self.hitbox.x = self.x + dir[1] * self.speed
        if collides(self.hitbox, walls[i]) then
            collide_count[1] = collide_count[1] + 1
        end
        self.hitbox.x = self.x
        self.hitbox.y = self.y + dir[2] * self.speed
        if collides(self.hitbox, walls[i]) then
            collide_count[2] = collide_count[2] + 1
        end
        self.hitbox.y = self.y
    end
    if collide_count[1] == 0 then
        self.x = self.x + dir[1] * self.speed
    end
    if collide_count[2] == 0 then
        self.y = self.y + dir[2] * self.speed
    end
    updateFrame(self.anims[1], dt)
end

-- MARK: Draw
function Player:draw(mouseX, mouseY)
    local frame = getFrame(self.anims[1])
    love.graphics.draw(frame, self.x, self.y, angleToPoint(600, 400, mouseX, mouseY) + math.pi/2, 1, 1, frame:getWidth()/2, frame:getHeight()/2)
end
