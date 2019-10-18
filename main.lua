snakeheadImg = love.graphics.newImage("snakehead.png")
snakebodyImg = love.graphics.newImage("snakebody-sheet.png")
snaketailImg = love.graphics.newImage("snaketail.png")
snakecornerImg = love.graphics.newImage("snakecorner.png")
headQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snakeheadImg:getDimensions()),
    love.graphics.newQuad(16, 0, 16, 16, snakeheadImg:getDimensions())
}
bodyQuads = {
    love.graphics.newQuad(0, 0, 16, 16, snakebodyImg:getDimensions()),
    love.graphics.newQuad(16, 0, 16, 16, snakebodyImg:getDimensions()),
    love.graphics.newQuad(32, 0, 16, 16, snakebodyImg:getDimensions()),
    love.graphics.newQuad(48, 0, 16, 16, snakebodyImg:getDimensions()),
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

tileWidth = 16
tileHeight = 16
tilesX = 320 / tileWidth
tilesY = 240 / tileHeight

direction = 0
lengthOfTick = 0.5
tickMultiplicationPerApple = 0.985
tickTime = 0
tickAccumulator = 0
gameStarted = false
gamePaused = false
playerDead = false
shouldQuit = false
ate = false

score = 0

snakeBits = {}

startGameButton = {
    width = 100,
    height = 20,
    text = "Start game",
    action = function()
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
    playerDead = false
    score = 0
    x = math.floor(tilesX / 2)
    y = math.floor(tilesY / 2)
    direction = 0
    lengthOfTick = 0.4
    tickTime = 0
    snakeBits = {
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
            if ate then
                table.insert(snakeBits, {
                    x = snakeBits[#snakeBits].x,
                    y = snakeBits[#snakeBits].y,
                    directionLastTick = snakeBits[#snakeBits].directionLastTick,
                    corner = snakeBits[#snakeBits].corner
                })
            end
            
            for i = #snakeBits, 2, -1 do
                snakeBits[i].x = snakeBits[i-1].x
                snakeBits[i].y = snakeBits[i-1].y
                local newDirection = snakeBits[i-1].directionLastTick
                snakeBits[i].directionLastTick = newDirection
                snakeBits[i].corner = snakeBits[i-1].corner
            end
            
            if snakeBits[1].directionLastTick ~= direction then
                local od = snakeBits[1].directionLastTick
                local nd = direction
                if (od == 0 and nd == 1) or (od == 3 and nd == 2) then snakeBits[2].corner = 1 end
                if (od == 0 and nd == 3) or (od == 1 and nd == 2) then snakeBits[2].corner = 2 end
                if (od == 2 and nd == 3) or (od == 1 and nd == 0) then snakeBits[2].corner = 3 end
                if (od == 2 and nd == 1) or (od == 3 and nd == 0) then snakeBits[2].corner = 4 end
            else
                snakeBits[2].corner = 0
            end
            snakeBits[1].directionLastTick = direction

            if direction == 0 then
                snakeBits[1].y = snakeBits[1].y - 1
            elseif direction == 2 then
                snakeBits[1].y = snakeBits[1].y + 1
            elseif direction == 3 then
                snakeBits[1].x = snakeBits[1].x - 1
            elseif direction == 1 then
                snakeBits[1].x = snakeBits[1].x + 1
            end
            if snakeBits[1].x > tilesX-1 then snakeBits[1].x = 0 end
            if snakeBits[1].x < 0 then snakeBits[1].x = tilesX-1 end
            if snakeBits[1].y > tilesY-1 then snakeBits[1].y = 0 end
            if snakeBits[1].y < 0 then snakeBits[1].y = tilesY-1 end
            
            for i = 2, #snakeBits do
                if snakeBits[i].x == snakeBits[1].x and snakeBits[i].y == snakeBits[1].y then
                    gameStarted = false
                    playerDead = true
                    return
                end
            end
            
            ate = false
            for i = 1, #apples do
                if apples[i].x == snakeBits[1].x and apples[i].y == snakeBits[1].y then
                    ate = true
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

function love.draw()
    if gameStarted then
        love.graphics.setColor(255, 255, 255)
        for i = 2, #snakeBits-1 do
            if snakeBits[i].corner == 0 then
                love.graphics.draw(snakebodyImg, bodyQuads[(tickAccumulator + i) % #bodyQuads + 1], (snakeBits[i].x * tileWidth)+tileWidth/2, (snakeBits[i].y * tileHeight)+tileHeight/2, (math.pi/2)*snakeBits[i].directionLastTick, 1, 1, 8, 8)
            else
                love.graphics.draw(snakecornerImg, cornerQuads[snakeBits[i].corner], (snakeBits[i].x * tileWidth)+tileWidth/2, (snakeBits[i].y * tileHeight)+tileHeight/2, 0, 1, 1, 8, 8)
            end
        end
        love.graphics.draw(snaketailImg, tailQuads[tickAccumulator % #tailQuads + 1], (snakeBits[#snakeBits].x * tileWidth)+tileWidth/2, (snakeBits[#snakeBits].y * tileHeight)+tileHeight/2, (math.pi/2)*snakeBits[#snakeBits-1].directionLastTick, 1, 1, 8, 8)
        love.graphics.draw(snakeheadImg, headQuads[tickAccumulator % #headQuads + 1], (snakeBits[1].x * tileWidth)+tileWidth/2, (snakeBits[1].y * tileHeight)+tileHeight/2, (math.pi/2)*snakeBits[1].directionLastTick, 1, 1, 8, 8)
        
        love.graphics.setColor(255, 0, 0)
        for i = 1, #apples do
            love.graphics.rectangle("fill", apples[i].x*tileWidth, apples[i].y*tileHeight, tileWidth, tileHeight)
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
    if gamePaused or playerDead then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(string.format("Score: %d", score), 110, 30)
    end
end

function love.keypressed( key )
    if gameStarted and not gamePaused then
        if key == "up" then
            if snakeBits[1].directionLastTick ~= 2 then direction = 0 end
        end
        if key == "down" then
            if snakeBits[1].directionLastTick ~= 0 then direction = 2 end
        end
        if key == "left" then
            if snakeBits[1].directionLastTick ~= 1 then direction = 3 end
        end
        if key == "right" then
            if snakeBits[1].directionLastTick ~= 3 then direction = 1 end
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
        startGameButton.text = "Restart game"
        menuButtons = {
            startGameButton,
            resumeGameButton,
            quitButton
        }
    end
 end