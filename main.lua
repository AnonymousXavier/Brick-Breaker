local settings = require("src.settings")
local world = require("src.Core.world")
local hud = require("src.Misc.hud")

local myFont = love.graphics.newFont(settings.font_size)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(settings.screen_width, settings.screen_height)
    world.init()
    hud.init(world)
    world.hud = hud
end

function love.draw()
    world.draw()
    hud.draw()
    love.graphics.setFont(myFont)
    love.graphics.print(tostring(love.timer.getFPS()), settings.font_size, (settings.screen_height - settings.block_height) - settings.font_size)
end

function love.update(dt)
    world.process_input()
    hud.update(dt)
    world.update(dt)
end


