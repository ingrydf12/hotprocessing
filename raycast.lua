function collisionPoint(line1, line2)
    local x, y
    denominator = (line1[1]-line1[3])*(line2[2]-line2[4]) - (line1[2]-line1[4])*(line2[1]-line2[3])
    
    if denominator ~= 0 then
        x = ((line1[1]*line1[4] - line1[2]*line1[3]) * (line2[1]-line2[3]) - (line1[1]-line1[3])*(line2[1]*line2[4]-line2[2]*line2[3])) / denominator 
        y = ((line1[1]*line1[4] - line1[2]*line1[3]) * (line2[2]-line2[4]) - (line1[2]-line1[4])*(line2[1]*line2[4]-line2[2]*line2[3])) / denominator
        return {x,y}
    else
        return 0
    end
end

function createLine(x1,y1,x2,y2)
    return {x1,y1,x2,y2}
end