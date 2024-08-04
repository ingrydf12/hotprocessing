-- MARK: Variables
currentWave = 1
inimigosPorWave = 4
inimigosVivos = 0
inimigos = {}

--[[ function iniciarWave(wave)
    inimigos = {}
    inimigosVivos = inimigosPorWave + 3
    for i = 1, inimigosVivos do
        inimigos[i] = {x = math.random(100, 700), y = math.random(100, 700), morto = false}
    end
end

function atualizar(dt)
    for i = #inimigos, 1, -1 do
        if inimigos[i].morto then
            table.remove(inimigos, i)
        end
    end

    if inimigosVivos <= 0 then
        currentWave = currentWave + 1
        iniciarWave(currentWave)
    end
end ]]

function counter()
    love.graphics.setFont(font)
    love.graphics.print("Wave: " .. currentWave, 10, 10)
    love.graphics.print("Inimigos restantes: " .. inimigosVivos, 10, 30)

    for _, inimigo in ipairs(inimigos) do
        if not inimigo.morto then
            love.graphics.rectangle("fill", inimigo.x, inimigo.y, 40, 40)
        end
    end
end
--[[ 
function verificarAcerto(inimigo, tiro)
    if inimigo then
        inimigo.morto = true
        inimigosVivos = inimigosVivos - 1
    end
end
 ]]