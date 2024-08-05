Wall = {} -- class Wall
Wall.__index = Wall

function Wall:new(x1, y1, x2, y2)
    local self = setmetatable({}, Wall)
    self.line = createLine(x1, y1, x2, y2)
    return self
end

function Wall:draw()
    love.graphics.line(self.line)
end
