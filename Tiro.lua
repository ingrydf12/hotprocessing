Tiro = {} -- class Tiro
Tiro.__index = Tiro

function Tiro:new(x, y, velx, vely)
    local self = setmetatable({}, Tiro)
    self.x = x
    self.y = y
    self.velx = velx
    self.vely = vely
    return self
end

function Tiro:update()
    self.x = self.x + self.velx
    self.y = self.y + self.vely
    
    if self.x >= posx+600 or self.y >= posy+400 or self.x < posx-600 or self.y < posy-400 then
        self:reset()
    end
end

function Tiro:reset()
    self.x = -1500
    self.y = -1500
    self.velx = 0
    self.vely = 0
end

function Tiro:draw()
    love.graphics.setColor(red)
    love.graphics.rectangle("fill", self.x, self.y, 10, 20)
end
