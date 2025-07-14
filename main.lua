local game = require("src.Core.game")
local settings = require("src.settings")


function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(settings.screen_width, settings.screen_height)
    love.window.setTitle(settings.game_name)
    game.load()
end

function love.draw()
    game.draw()
end

function love.update(dt)
    game.update(dt)
end



