local settings = require("src.settings")
local world = require("src.Core.world")
local hud = require("src.Misc.hud")
local menu = require("src.Core.menu")
local misc_functions = require("src.misc_functions")

local game = {}
local states = {MENU=0, GAME=1}
game.game_started = false

game.state = states.MENU

function game.load()
    menu.load()
end

function game.start()
    world.init()
    hud.init(world)
    world.hud = hud
end

function game.draw()
    love.graphics.setFont(settings.Fonts.default)
    love.graphics.print(tostring(love.timer.getFPS()), settings.font_size, (settings.screen_height - settings.block_height) - settings.font_size)

    if game.state == states.GAME then 
        world.draw()
        hud.draw()
    elseif game.state == states.MENU then menu.draw() end
        
end

function game.update(dt)
    if not menu.active and not game.game_started then
       if menu.state == menu_states.START then
            game.state = states.GAME
            game.start()
            game.game_started = true
       elseif menu.state == menu_states.GAMEOVER then
            menu.state = menu_states.START
            menu.active = true
            game.game_started = false
       end
        
    else
        menu.process_input()
    end

    if game.state == states.GAME then 
        world.process_input()
        hud.update(dt)
        world.update(dt)

        if world.player.lives <= 0 then 
            game.state = states.MENU 
            menu.state = menu_states.GAMEOVER 
            menu.active = true
            game.game_started = false

            misc_functions.save_high_score(world.level)
            menu.load()
        end
    end  
end


return game

