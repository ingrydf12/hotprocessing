local menu = {}

-- MARK: Menu Variables
menu.show = true

function menu.draw()
    if menu.show then
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1) -- White color
        love.graphics.printf("Press ENTER to Start", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
    end
end

function menu.keypressed(key)
    if key == "return" then -- "return" corresponds to the ENTER key
        menu.show = false
        waveSystem.iniciarWave(waveSystem.currentWave) -- Start the wave system
    end
end

return menu
