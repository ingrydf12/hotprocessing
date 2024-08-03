function collisionPoint(line1, line2)
    local t, u
    x1=line1[1]
    x2=line1[3]
    x3=line2[1]
    x4=line2[3]
    y1=line1[2]
    y2=line1[4]
    y3=line2[2]
    y4=line2[4]

    deno = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)
    if deno == 0 then
        return nil
    end
    t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4))/deno
    u = -((x1-x2)*(y1-y3) - (y1-y2)*(x1-x3))/deno
    if 0<=t and t<=1 and 0<=u and u<=1 then
        return {x1+(t*(x2-x1)), y1+(t*(y2-y1))}
    end
end

function createLine(x1,y1,x2,y2)
    return {x1,y1,x2,y2}
end

function lineToRect(line)
    local rect = {}
    local dx = line[3] - line[1]
    local dy = line[4] - line[2]

    rect.x = line[1] + dx/2
    if dx<0 then
        rect.x = line[3] - dx/2
    end
    rect.y = line[2] + dy/2
    if dy<0 then
        rect.y = line[4] - dy/2
    end
    rect.height = math.abs(dy)
    rect.width = math.abs(dx)
    return rect
end