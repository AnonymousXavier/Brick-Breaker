local paddle = require("src.Core.paddle")
local settings = require("src.settings")
local misc = require("src.misc_functions")

local player = {dx = 0, speed = settings.default_player_speed, balls={}, rot_angle = math.rad(-95)}
local states = { IDLE = 1, PLAYING = 2 }

player.default_rot_angle = math.rad(-95)
player.state = states.IDLE
player.lives = 2


function player.init()
    player.reset()
    player.lives = settings.player_initial_lives
end

function player.new_paddle()
    return paddle.new(settings.paddle_default_X, settings.paddle_default_Y, settings.paddle_width,
    settings.paddle_height, settings.Colors.paddle)
end

function player.reset()
    player.paddle = player.new_paddle()
    player.state = states.IDLE
    player.rot_angle = player.default_rot_angle
end

function player.update_state()
    player.state = states.PLAYING
    for _, ball in ipairs(player.balls) do
        if ball.just_spawned  then 
            player.state = states.IDLE 
            break    
        end
    end
end

function player.process_movement(dt)
    local x = player.paddle.x

    x = x + player.dx * player.speed * dt
    x = misc.clamp(x, -1 * player.paddle.w / 2, settings.screen_width - player.paddle.w / 2)

    player.paddle.x = x
end

function player.process_ball_aiming(dt) 
    -- Position ball slightly above paddle
    local ball = player.balls[#player.balls]

    ball.x = player.paddle.x + player.paddle.w / 2
    ball.y = player.paddle.y - settings.default_ball_Y_offset_from_paddle

    -- Calculate ball direction from rot_angle
    player.rot_angle = player.rot_angle + player.dx * dt
    player.rot_angle = misc.clamp(player.rot_angle, math.rad(settings.paddle_aim_limits.min), math.rad(settings.paddle_aim_limits.max))
end

function player.draw_aim_line()
    -- Calculate direction ball will bounce
    local dx, dy, ex, ey, sx, sy,ox, oy, color
    local ball = player.get_last_ball_added() -- last ball added
    local offset_factor = 1.75

    sx, sy = ball.x, ball.y

    dx = settings.paddle_aim_line_length * math.cos(player.rot_angle)
    dy = settings.paddle_aim_line_length * math.sin(player.rot_angle)

    ox = ball.r * math.cos(player.rot_angle) * offset_factor
    oy = ball.r * math.sin(player.rot_angle) * offset_factor

    ex = sx + dx
    ey = sy + dy
    color = settings.Colors.ball

    love.graphics.setColor(color.r, color.g, color.b)
    love.graphics.line(sx + ox, sy + oy, ex, ey)
end

function player.update(dt)
    if player.state == states.PLAYING then player.process_movement(dt) end
    if player.state == states.IDLE then player.process_ball_aiming(dt) end
    player.paddle:update(dt)
    player.update_state()
end

function player.draw()
    if player.state == states.IDLE then player.draw_aim_line() end
    player.paddle:draw()
end

function player.get_last_ball_added()
    return player.balls[#player.balls]
end

function player.release_ball()
    local ball = player.get_last_ball_added()
    if ball.just_spawned then
        ball.just_spawned = false
        ball.direction.x = math.cos(player.rot_angle)
        ball.direction.y = math.sin(player.rot_angle)
    end
end

function player.process_input()
    local is_pressing_left = misc.is_pressed(settings.Controls.left)
    local is_pressing_right = misc.is_pressed(settings.Controls.right)
    local is_pressing_start = misc.is_pressed(settings.Controls.play)

    if is_pressing_left then player.dx = -1 end
    if is_pressing_right then player.dx = 1 end
    if is_pressing_start then player.release_ball() end

    if not is_pressing_left and not is_pressing_right then player.dx = 0 end

end

return player
