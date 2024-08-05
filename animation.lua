function newAnim(directory, fps, loop)
    if type(loop) == "nil" then
        loop = true
    end
    local anim = {time = 0, frame_atual = 1, doesLoop = loop}
    anim.fps = fps
    local files = love.filesystem.getDirectoryItems(directory)
    anim.frames = {}
    for i = 1, #files do
        anim.frames[i] = love.graphics.newImage(directory .. "/" .. files[i])
    end
    return anim
end

function updateFrame(anim, dt)
    if anim.frame_atual == #anim.frames and not anim.doesLoop then
        return
    end
    anim.time = anim.time + dt
    if anim.time > 1/anim.fps then
        anim.time = anim.time - 1/anim.fps
        anim.frame_atual = anim.frame_atual % #anim.frames + 1
    end
end

function getFrame(anim)
    return anim.frames[anim.frame_atual]
end