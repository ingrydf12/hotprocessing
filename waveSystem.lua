-- MARK: Variables
currentWave = 1
inimigosPorWave = 4
inimigosVivos = 0
inimigos = {}
playerHeart = love.graphics.newImage("assets/sprites/hp/hpHeart.png")
playerLastHeart = love.graphics.newImage("assets/sprites/hp/hpLastHeart.png")

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