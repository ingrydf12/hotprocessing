local waveSystem = {}

-- MARK: Variables
waveSystem.currentWave = 1
waveSystem.inimigosPorWave = 4
waveSystem.inimigosVivos = 0
waveSystem.inimigos = {}

function waveSystem.iniciarWave(wave)
    waveSystem.inimigos = {}
    waveSystem.inimigosVivos = waveSystem.inimigosPorWave + 3
    for i = 1, waveSystem.inimigosVivos do
        waveSystem.inimigos[i] = {x = math.random(100, 700), y = math.random(100, 700), morto = false}
    end
end

function waveSystem.atualizar(dt)
    for i = #waveSystem.inimigos, 1, -1 do
        if waveSystem.inimigos[i].morto then
            table.remove(waveSystem.inimigos, i)
        end
    end

    if waveSystem.inimigosVivos <= 0 then
        waveSystem.currentWave = waveSystem.currentWave + 1
        waveSystem.iniciarWave(waveSystem.currentWave)
    end
end

function waveSystem.counter()
    love.graphics.setFont(font)
    love.graphics.print("Wave: " .. currentWave, 10, 10)
    love.graphics.print("Wave: " .. waveSystem.currentWave, 10, 10)

    for _, inimigo in ipairs(waveSystem.inimigos) do
        if not inimigo.morto then
            love.graphics.rectangle("fill", inimigo.x, inimigo.y, 40, 40)
        end
    end
end

function waveSystem.verificarAcerto(inimigo, tiro)
    if inimigo then
        inimigo.morto = true
        waveSystem.inimigosVivos = waveSystem.inimigosVivos - 1
    end
end


return waveSystem
