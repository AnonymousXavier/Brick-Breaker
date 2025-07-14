local hud = {}
local world = require("src.Core.world")
local settings = require("src.settings")
local flux = require("src.lib.flux")
local misc = require("src.misc_functions")

hud.power_ups_tweening = {}

function hud.init(_world)
    world = _world
end

function hud.update(dt)
    flux.update(dt)
end

function hud.draw()
    hud.draw_lives()
    hud.draw_level()
    hud.draw_balls()
    hud.draw_animated_texts()
end

function hud.draw_lives()
    local text = string.format("LIVES: %d", world.player.lives)
    local x, y = settings.screen_width - (#text + 1) * settings.font_size / 2, (settings.hud_height - settings.font_size) / 2

    love.graphics.print(text, x, y)
end

function hud.draw_balls()
    local fontSize = settings.ball_count_font_size
    local font = settings.Fonts.ball_count

    local text = string.format("X%d", #world.balls)
    local text_width = (#text + 1) * fontSize
    local ball_radius = settings.default_ball_radius * 1.5
    local spacing = 3
    local bx, by = (settings.screen_width - text_width) / 2 - spacing / 2, (settings.hud_height + fontSize / 5) / 2

    local bw = (spacing + ball_radius) + spacing
    local tx, y = (settings.screen_width - text_width) / 2 + bw, (settings.hud_height - fontSize) / 2

    love.graphics.setFont(font)
    love.graphics.circle("line", bx, by, ball_radius)
    love.graphics.print(text, tx, y)
end

function hud.enlarge_and_shrink_text(text)
    local power_up_text_table = {text=text, scale=0.1, remove = false}
    hud.power_ups_tweening[#hud.power_ups_tweening + 1] = power_up_text_table
    -- Enlarge and Shrink text
    flux.to(power_up_text_table, settings.hud_text_flash_duration, {scale=2}):ease("quadout")
    :after(power_up_text_table, settings.hud_text_flash_duration, {scale=0.1}):ease("quadin")
    :oncomplete(function() power_up_text_table.remove = true end)
end

function hud.draw_animated_texts()
    for _, powerup in ipairs(hud.power_ups_tweening) do
        if not powerup.remove then 
            local text = powerup
            local font = settings.Fonts.pickup_message
            local tw, th = font:getWidth(text.text) * text.scale, font:getHeight() * text.scale

            love.graphics.setFont(font)
            love.graphics.push()
                love.graphics.translate(settings.screen_width / 2 - tw / 2, settings.screen_height / 2-th/2)
                love.graphics.scale(text.scale, text.scale)
                love.graphics.print(text.text, 0, 0)
            love.graphics.pop()

        else
           misc.remove_from_list(hud.power_ups_tweening,powerup)
        end
    end
end

function hud.draw_level()
    local text = string.format("LEVEL: %d", world.level)
    local x, y = 8, (settings.hud_height - settings.font_size) / 2
    love.graphics.print(text, x, y)
end

return hud