snakeheadImg = love.graphics.newImage("snakehead.png")
snakebodyImg = love.graphics.newImage("snakebody-sheet.png")
snaketailImg = love.graphics.newImage("snaketail.png")
snakecornerImg = love.graphics.newImage("snakecorner.png")
appleImg = love.graphics.newImage("apple.png")
headQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snakeheadImg:getDimensions()),
    love.graphics.newQuad(16, 0, 16, 16, snakeheadImg:getDimensions())
}
bodyQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snakebodyImg:getDimensions()),
    --love.graphics.newQuad(16, 0, 16, 16, snakebodyImg:getDimensions()),
    love.graphics.newQuad(32, 0, 16, 16, snakebodyImg:getDimensions()),
    --love.graphics.newQuad(48, 0, 16, 16, snakebodyImg:getDimensions()),
}
tailQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snaketailImg:getDimensions()),
    love.graphics.newQuad(16, 0, 16, 16, snaketailImg:getDimensions()),
    love.graphics.newQuad(32, 0, 16, 16, snaketailImg:getDimensions()),
    love.graphics.newQuad(48, 0, 16, 16, snaketailImg:getDimensions())
}
cornerQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snakecornerImg:getDimensions()),
    love.graphics.newQuad(16, 0, 16, 16, snakecornerImg:getDimensions()),
    love.graphics.newQuad(32, 0, 16, 16, snakecornerImg:getDimensions()),
    love.graphics.newQuad(48, 0, 16, 16, snakecornerImg:getDimensions()),
}
appleQuad = love.graphics.newQuad(0, 0, 16, 16, appleImg:getDimensions());

tileWidth = 16
tileHeight = 16
tilesX = 320 / tileWidth
tilesY = 240 / tileHeight

lengthOfTick = 0.5
tickMultiplicationPerApple = 0.985
tickTime = 0
tickAccumulator = 0
gameStarted = false
gamePaused = false
playerDead = false
shouldQuit = false
twoPlayer = false
winner = 0

score = 0

startGameButton = {
    width = 100,
    height = 20,
    text = "Start game",
    action = function()
        twoPlayer = false
        setupGame()
        gameStarted = true
        gamePaused = false
    end
}
twoPlayerButton = {
    width = 100,
    height = 20,
    text = "2 players",
    action = function()
        twoPlayer = true
        setupGame()
        gameStarted = true
        gamePaused = false
    end
}
resumeGameButton = {
    width = 100,
    height = 20,
    text = "Resume game",
    action = function()
        gamePaused = false
    end
}
quitButton = {
    width = 100,
    height = 20,
    text = "Quit",
    action = function()
        shouldQuit = true
    end
}
menuButtons = {
    startGameButton,
    twoPlayerButton,
    quitButton
}
visibleMenuButtons = {}

menuCursor = 1

function love.load()
    font = love.graphics.newImageFont("Resource-Imagefont.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")

    setupGame()
end

function setupGame()
    winner = 0
    playerDead = false
    score = 0
    if twoPlayer then
        x = math.floor(tilesX / 4)*3
        y = math.floor(tilesY / 4)*3
        x1 = math.floor(tilesX / 4)
        y1 = math.floor(tilesY / 4)
    else
        x = math.floor(tilesX / 2)
        y = math.floor(tilesY / 2)
    end

    direction = 0
    lengthOfTick = 0.4
    tickTime = 0
    local snakeBits = {
        {
            x = x,
            y = y+1,
            directionLastTick = 0
        },
        {
            x = x,
            y = y+2,
            directionLastTick = 0
        }
    }
    snakes = {
        {
            color = { 255, 255, 255 },
            direction = 0,
            snakeBits = snakeBits,
            ate = false
        }
    }
    if twoPlayer then
        local snakeBits = {
            {
                x = x1,
                y = y1,
                directionLastTick = 2
            },
            {
                x = x1,
                y = y1-1,
                directionLastTick = 2
            }
        }
        table.insert(snakes, {
            color = { 255, 0, 255 },
            direction = 2,
            snakeBits = snakeBits,
            ate = false
        })
    end

    apples = {
        {
            x = math.floor(love.math.random()*tilesX),
            y = math.floor(love.math.random()*tilesY)
        },
        {
            x = math.floor(love.math.random()*tilesX),
            y = math.floor(love.math.random()*tilesY)
        }
    }
end

function love.update(dt)
    if shouldQuit == true then
        love.event.quit(0)
    end
    
    if gameStarted == true and gamePaused == false then
        tickTime = tickTime + dt
        if tickTime > lengthOfTick then
            tickAccumulator = tickAccumulator + 1
            for sIndex, snake in ipairs(snakes) do
                if snake.ate then
                    table.insert(snake.snakeBits, {
                        x = snake.snakeBits[#snake.snakeBits].x,
                        y = snake.snakeBits[#snake.snakeBits].y,
                        directionLastTick = snake.snakeBits[#snake.snakeBits].directionLastTick,
                        corner = snake.snakeBits[#snake.snakeBits].corner
                    })
                end
                
                for i = #snake.snakeBits, 2, -1 do
                    snake.snakeBits[i].x = snake.snakeBits[i-1].x
                    snake.snakeBits[i].y = snake.snakeBits[i-1].y
                    local newDirection = snake.snakeBits[i-1].directionLastTick
                    snake.snakeBits[i].directionLastTick = newDirection
                    snake.snakeBits[i].corner = snake.snakeBits[i-1].corner
                end
                
                if snake.snakeBits[1].directionLastTick ~= snake.direction then
                    local od = snake.snakeBits[1].directionLastTick
                    local nd = snake.direction
                    if (od == 0 and nd == 1) or (od == 3 and nd == 2) then snake.snakeBits[2].corner = 1 end
                    if (od == 0 and nd == 3) or (od == 1 and nd == 2) then snake.snakeBits[2].corner = 2 end
                    if (od == 2 and nd == 3) or (od == 1 and nd == 0) then snake.snakeBits[2].corner = 3 end
                    if (od == 2 and nd == 1) or (od == 3 and nd == 0) then snake.snakeBits[2].corner = 4 end
                else
                    snake.snakeBits[2].corner = 0
                end
                snake.snakeBits[1].directionLastTick = snake.direction
    
                if snake.direction == 0 then
                    snake.snakeBits[1].y = snake.snakeBits[1].y - 1
                elseif snake.direction == 2 then
                    snake.snakeBits[1].y = snake.snakeBits[1].y + 1
                elseif snake.direction == 3 then
                    snake.snakeBits[1].x = snake.snakeBits[1].x - 1
                elseif snake.direction == 1 then
                    snake.snakeBits[1].x = snake.snakeBits[1].x + 1
                end
                if snake.snakeBits[1].x > tilesX-1 then snake.snakeBits[1].x = 0 end
                if snake.snakeBits[1].x < 0 then snake.snakeBits[1].x = tilesX-1 end
                if snake.snakeBits[1].y > tilesY-1 then snake.snakeBits[1].y = 0 end
                if snake.snakeBits[1].y < 0 then snake.snakeBits[1].y = tilesY-1 end
                
                for otherSnakeIndex, otherSnake in ipairs(snakes) do
                    local startIndex = 1
                    if otherSnakeIndex == sIndex then startIndex = 2 end
                    for i = startIndex, #otherSnake.snakeBits do
                        if otherSnake.snakeBits[i].x == snake.snakeBits[1].x and otherSnake.snakeBits[i].y == snake.snakeBits[1].y then
                            gamePaused = true
                            if twoPlayer == false then
                                playerDead = true
                                menuButtons = {
                                    startGameButton,
                                    twoPlayerButton,
                                    quitButton
                                }
                            else
                                if i == 1 then
                                    if #snake.snakeBits > #otherSnake.snakeBits then
                                        winner = sIndex
                                    elseif #snake.snakeBits < #otherSnake.snakeBits then
                                        winner = otherSnakeIndex
                                    else
                                        winner = -1
                                    end
                                else
                                    if snakeIndex == 1 then
                                        winner = 2
                                    else
                                        winner = 1
                                    end
                                end
                                menuButtons = {
                                    startGameButton,
                                    twoPlayerButton,
                                    quitButton
                                }
                            end
                            return
                        end
                    end
                end
                
                snake.ate = false
                for i = 1, #apples do
                    if apples[i].x == snake.snakeBits[1].x and apples[i].y == snake.snakeBits[1].y then
                        snake.ate = true
                        apples[i].x = math.floor(love.math.random()*tilesX)
                        apples[i].y = math.floor(love.math.random()*tilesY)
                        lengthOfTick = lengthOfTick * tickMultiplicationPerApple
                        score = score + 100
                    end
                end
                tickTime = 0
            end
        end
    end
end

function love.draw()
    if gameStarted then
        for sIndex, snake in ipairs(snakes) do
            love.graphics.setColor(snake.color)
            for i = 2, #snake.snakeBits-1 do
                if snake.snakeBits[i].corner == 0 then
                    love.graphics.draw(snakebodyImg, bodyQuads[(tickAccumulator + i) % #bodyQuads + 1], (snake.snakeBits[i].x * tileWidth)+tileWidth/2, (snake.snakeBits[i].y * tileHeight)+tileHeight/2, (math.pi/2)*snake.snakeBits[i].directionLastTick, 1, 1, 8, 8)
                else
                    love.graphics.draw(snakecornerImg, cornerQuads[snake.snakeBits[i].corner], (snake.snakeBits[i].x * tileWidth)+tileWidth/2, (snake.snakeBits[i].y * tileHeight)+tileHeight/2, 0, 1, 1, 8, 8)
                end
            end
            love.graphics.draw(snaketailImg, tailQuads[tickAccumulator % #tailQuads + 1], (snake.snakeBits[#snake.snakeBits].x * tileWidth)+tileWidth/2, (snake.snakeBits[#snake.snakeBits].y * tileHeight)+tileHeight/2, (math.pi/2)*snake.snakeBits[#snake.snakeBits-1].directionLastTick, 1, 1, 8, 8)
            love.graphics.draw(snakeheadImg, headQuads[tickAccumulator % #headQuads + 1], (snake.snakeBits[1].x * tileWidth)+tileWidth/2, (snake.snakeBits[1].y * tileHeight)+tileHeight/2, (math.pi/2)*snake.snakeBits[1].directionLastTick, 1, 1, 8, 8)
        end
        love.graphics.setColor(255, 255, 255)
        
        for i = 1, #apples do
            love.graphics.draw(appleImg, appleQuad, (apples[i].x * tileWidth)+tileWidth/2, (apples[i].y * tileHeight)+tileHeight/2, 0, 1, 1, 8, 8)
        end
    end
    love.graphics.setFont(font)
    if not gameStarted or gamePaused then
        love.graphics.setColor(255, 255, 255, 0.2)
        love.graphics.rectangle("fill", 0, 0, 320, 240)
        for i, button in ipairs(menuButtons) do
            if menuCursor == i then
                love.graphics.setColor(0, 255, 0)
            else
                love.graphics.setColor(255, 255, 255)
            end
            love.graphics.print(button.text, 110, i*20 + 50)
        end
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("www.phlogios.com", 90, 200)
        love.graphics.print("Twitter: @phlogios", 85, 220)
    end
    if (gamePaused or playerDead) and twoPlayer == false then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.format("Score: %d", score), 110, 30)
    end
    if winner > 0 then
        love.graphics.setColor(snakes[winner].color)
        love.graphics.print(string.format("Player %d wins!", winner), 110, 30)
    end
    if winner == -1 then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("It's a tie!", 110, 30)
    end
end

function love.keypressed( key )
    if gameStarted and not gamePaused then
        if key == "up" then
            if snakes[1].snakeBits[1].directionLastTick ~= 2 then snakes[1].direction = 0 end
        end
        if key == "down" then
            if snakes[1].snakeBits[1].directionLastTick ~= 0 then snakes[1].direction = 2 end
        end
        if key == "left" then
            if snakes[1].snakeBits[1].directionLastTick ~= 1 then snakes[1].direction = 3 end
        end
        if key == "right" then
            if snakes[1].snakeBits[1].directionLastTick ~= 3 then snakes[1].direction = 1 end
        end

        if twoPlayer then
            if key == "lshift" then
                if snakes[2].snakeBits[1].directionLastTick ~= 2 then snakes[2].direction = 0 end
            end
            if key == "lalt" then
                if snakes[2].snakeBits[1].directionLastTick ~= 0 then snakes[2].direction = 2 end
            end
            if key == "space" then
                if snakes[2].snakeBits[1].directionLastTick ~= 1 then snakes[2].direction = 3 end
            end
            if key == "lctrl" then
                if snakes[2].snakeBits[1].directionLastTick ~= 3 then snakes[2].direction = 1 end
            end
        end
    else
        if key == "up" then
            menuCursor = math.max(menuCursor - 1, 1)
        elseif key == "down" then
            menuCursor = math.min(menuCursor + 1, #menuButtons)
        end
    end
    
    if (key == "space" or key == "return") and (gamePaused == true or gameStarted == false) then
        menuButtons[menuCursor]:action()
    end

    if key == "escape" then
        gamePaused = true
        if twoPlayer then
            startGameButton.text = "Start 1 player game"
            twoPlayerButton.text = "Restart game"
        else
            startGameButton.text = "Restart game"
        end
        menuButtons = {
            startGameButton,
            twoPlayerButton,
            resumeGameButton,
            quitButton
        }
    end
 end