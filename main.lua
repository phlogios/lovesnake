x = 0
y = 0

direction = 0
lengthOfTick = 0.5
tickTime = 0
tileSize = 10
gameStarted = false
gamePaused = false
shouldQuit = false

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
    x = 16
    y = 12
    direction = 0
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
    if shouldQuit == true then
        love.event.quit(0)
    end
    
    if gameStarted == true and gamePaused == false then
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
                    gameStarted = false
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
end

function love.draw()
    if gameStarted then
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
    love.graphics.setFont(font)
    if not gameStarted or gamePaused then
        for i, button in ipairs(menuButtons) do
            if menuCursor == i then
                love.graphics.setColor(0, 1, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(button.text, 100, i*20 + 50)
        end
    end
end

function love.keypressed( key )
    if gameStarted and not gamePaused then
        if key == "up" then
            direction = 0
        elseif key == "down" then
            direction = 1
        elseif key == "left" then
            direction = 2
        elseif key == "right" then
            direction = 3
        end
    else
        if key == "up" then
            menuCursor = math.max(menuCursor - 1, 1)
        elseif key == "down" then
            menuCursor = math.min(menuCursor + 1, #menuButtons)
        end
    end
    
    if key == "space" or key == "return" then
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
  
 function love.keyreleased( key )
    if key == "down" then
       
    end
 end