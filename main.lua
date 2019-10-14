x = 0
y = 0

direction = 0
lengthOfTick = 0.5
tickTime = 0
tileSize = 10

snakeBits = {}

function love.load()
    setupGame()
end

function setupGame()
    x = 16
    y = 12
    snakeBits = {
        {
            x = 16,
            y = 13
        }
    }

    apples = {
        {
            x = math.floor(love.math.random()*32),
            y = math.floor(love.math.random()*24)
        },
        {
            x = math.floor(love.math.random()*32),
            y = math.floor(love.math.random()*24)
        }
    }
end

function love.update(dt)
    if love.keyboard.isDown("up") then
        direction = 0
    elseif love.keyboard.isDown("down") then
        direction = 1
    elseif love.keyboard.isDown("left") then
        direction = 2
    elseif love.keyboard.isDown("right") then
        direction = 3
    end

    if love.keyboard.isDown("escape") then
        love.event.quit(0)
    end
    
    tickTime = tickTime + dt
    if tickTime > lengthOfTick then
        for i = #snakeBits, 2, -1 do
            snakeBits[i].x = snakeBits[i-1].x
            snakeBits[i].y = snakeBits[i-1].y
        end
        snakeBits[1].x = x
        snakeBits[1].y = y
        if direction == 0 then
            y = y - 1
        elseif direction == 1 then
            y = y + 1
        elseif direction == 2 then
            x = x - 1
        elseif direction == 3 then
            x = x + 1
        end
        if x > 31 then x = 0 end
        if x < 0 then x = 31 end
        if y > 24 then y = 0 end
        if y < 0 then y = 23 end

        for i = 2, #snakeBits do
            if snakeBits[i].x == x and snakeBits[i].y == y then
                setupGame()
                return
            end
        end
        
        for i = 1, #apples do
            if apples[i].x == x and apples[i].y == y then
                table.insert(snakeBits, {
                    x = snakeBits[1].x,
                    y = snakeBits[1].y
                })
                apples[i].x = math.floor(love.math.random()*32)
                apples[i].y = math.floor(love.math.random()*24)
            end
        end
        tickTime = 0
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x * tileSize, y * tileSize, tileSize, tileSize)
    for i, bit in ipairs(snakeBits) do
        love.graphics.rectangle("fill", bit.x*tileSize, bit.y*tileSize, tileSize, tileSize)
    end

    love.graphics.setColor(1, 0, 0)
    for i = 1, #apples do
        love.graphics.rectangle("fill", apples[i].x*tileSize, apples[i].y*tileSize, tileSize, tileSize)
    end
end