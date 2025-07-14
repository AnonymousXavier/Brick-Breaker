local settings = require("src.settings")
local misc = require("src.misc_functions")
local menu = {}

menu.data = nil -- The Loaded Data, this updates with states
menu_states = {START=1, GAMEOVER=2}

menu.active = true
menu.state = menu_states.START

function menu.load()
    menu.data = misc.load_high_score()
end

function menu.draw_start_screen()
    local cx, cy = settings.screen_width / 2, settings.screen_height / 2
    local offset = 100
    
    love.graphics.setColor(settings.Colors.menuColor.r, settings.Colors.menuColor.g, settings.Colors.menuColor.b)
    -- Draw Title
    local font = settings.Fonts.menu_title
    local tx, ty = cx - font:getWidth(settings.game_name) / 2, cy - offset * 2 - font:getHeight(settings.game_name) / 2 
    
    love.graphics.setFont(font)
    love.graphics.print(settings.game_name, tx, ty)

    -- Draw Highscore
    font = settings.Fonts.menu_subtitle
    local text = "Heighest Level: "..menu.data
    tx, ty = cx - font:getWidth(text) / 2, cy + offset / 2 - font:getHeight(text) / 2 
    
    love.graphics.setFont(font)
    love.graphics.print(text, tx, ty)

    -- Draw Info
    font = settings.Fonts.menu_subtitle
    text = "Press \"S\" to Start"
    tx, ty = cx - font:getWidth(text) / 2, cy + offset * 3 - font:getHeight(text) / 2 
    
    love.graphics.setFont(font)
    love.graphics.print(text, tx, ty)
end

function menu.draw_game_over_screen()
    local cx, cy = settings.screen_width / 2, settings.screen_height / 2
    local offset = 100
    local text = "GAME OVER"
    
    love.graphics.setColor(settings.Colors.menuColor.r, settings.Colors.menuColor.g, settings.Colors.menuColor.b)
    -- Draw Title
    local font = settings.Fonts.menu_title
    local tx, ty = cx - font:getWidth(text) / 2, cy - offset * 2 - font:getHeight(text) / 2 
    
    love.graphics.setFont(font)
    love.graphics.print(text, tx, ty)

    -- Draw Info
    font = settings.Fonts.menu_subtitle
    text = "Press \"M\" to return to the menu"
    tx, ty = cx - font:getWidth(text) / 2, cy + offset * 3 - font:getHeight(text) / 2 
    
    love.graphics.setFont(font)
    love.graphics.print(text, tx, ty)
end

function menu.draw()
    if menu.state == menu_states.START then menu.draw_start_screen() end
    if menu.state == menu_states.GAMEOVER then menu.draw_game_over_screen() end
end

function menu.process_input()
    local key = settings.Controls.start
    if menu.state == menu_states.START then key = settings.Controls.start end
    if menu.state == menu_states.GAMEOVER then key = settings.Controls.back_to_menu end
    if misc.is_pressed(key) then menu.active = false end
end

return menu