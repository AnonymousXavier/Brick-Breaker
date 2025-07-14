local settings = require("src.settings")
local block = require("src.Misc.block")
local player = require("src.Core.player")
local Ball = require("src.Core.ball")
local misc = require("src.misc_functions")
local Power_Ups = require("src.Misc.powerup")

local world = { hud = nil, level= 0}

world.blocks = {}
world.balls = {}
world.powerups = {}

-- Initialization Functions

function world.init()
    world.player = player
    world.start_game()
end

function world.reset()
    world.blocks = {}
    world.balls = {}
    world.powerups = {}
end

function world.start_game()
    world.level = world.level + 1

    world.reset()
    world.create_new_blocks()
    world.spawn_ball()
    player.init()

    player.balls = world.balls
end

function world.spawn_ball()
    local new_ball = Ball.new(
        settings.screen_width / 2,
        settings.screen_height / 2,
        settings.default_ball_radius,
        settings.Colors.ball
    )

    world.balls[#world.balls + 1] = new_ball
end

-- Block Update functions

function world.create_new_blocks()
    for i = 1, settings.block_rows * settings.block_cols, 1 do
        local r,c = misc.get_row_and_col_from_index(i, settings.block_cols).r, misc.get_row_and_col_from_index(i, settings.block_cols).c

        world.blocks[i] = world.new_block(r, c)
    end
end

function world.add_new_row() -- Adds a new row, this'll shift the first then shifts all others down a row
    -- Shift all current blocks down a row
    for i = 1, #world.blocks, 1 do
        world.blocks[i].y = world.blocks[i].y + (settings.block_height + settings.block_spacing)
        world.blocks[i]:update() -- update block rect too
    end

    -- Replace first row with new row
    for i = 1, settings.block_cols, 1 do
        local r,c = misc.get_row_and_col_from_index(i, settings.block_cols).r, misc.get_row_and_col_from_index(i, settings.block_cols).c

        world.blocks[#world.blocks + 1] = world.new_block(r, c)
    end
end


function world.draw_blocks()
    for i = 1, #world.blocks, 1 do
        world.blocks[i]:draw()
    end
end

function world.new_block(r, c)
    local w, h = settings.block_width, settings.block_height
    local x = (c - 1) * (settings.block_width + settings.block_spacing) + settings.block_spacing / 2
    local y = settings.hud_height
        + (r - 1) * (settings.block_height + settings.block_spacing)
        + settings.block_spacing / 2

    return block.new(x, y, w, h, math.random(world.level), settings.Colors.blocks)
end

-- Ball Update Functions

function world.draw_balls()
    for _, ball in ipairs(world.balls) do
        ball:draw()
    end
end

function world.update_balls(dt)
    local balls_out_of_bounds = {}
    for _, ball in ipairs(world.balls) do
        ball:update(dt)
        if ball.out_of_bounds then
            balls_out_of_bounds[#balls_out_of_bounds + 1] = ball
        end
    end

    for _, ball in ipairs(balls_out_of_bounds) do
        misc.remove_from_list(world.balls, ball)
    end

    if #world.balls == 0 then
        world.reset_player_and_ball()
        world.powerups = {}
    end
end

function world.reset_player_and_ball()
    player.reset()
    world.spawn_ball()
    world.add_new_row()
    player.lives = player.lives - 1
end

function world.handle_collisions()
    local collided_block = nil

    for _, ball in ipairs(world.balls) do
        -- Handle Paddle and balls collision
        if player.paddle.rect:collides_with(ball.rect) then
            ball:collided_with(player.paddle.rect, true)
        end

        -- Handle Ball and Blocks collision
        for i = 1, #world.blocks, 1 do
            local map_block = world.blocks[i]
            if map_block and map_block.rect:collides_with(ball.rect) then
                ball:collided_with(map_block.rect)
                map_block.hp = map_block.hp - 1
                collided_block = map_block
                break
            end
        end
    end

    -- Handle Paddle and powerups
    for _, powerup in ipairs(world.powerups) do
        if player.paddle.rect:collides_with(powerup.rect) then
            powerup.activated = true
        end
    end

    if collided_block then
        if collided_block.hp <= 0 then
            misc.remove_from_list(world.blocks, collided_block) 
            if collided_block.has_powerup then
                world.powerups[#world.powerups + 1] = Power_Ups.new(collided_block.rect:get_center().x, collided_block.rect:get_center().y)
            end
        end
    end
end

function world.draw_debug_collisions()
    player.paddle.rect:draw()
    for _, ball in ipairs(world.balls) do
        ball.rect:draw()
    end
    
    for i = 1, #world.blocks, 1 do
        world.blocks[i].rect:draw()
    end
end

function world.reset_ball_speed()
    for _, ball in ipairs(world.balls) do
        ball.speed = settings.default_ball_speed
    end
end

function world.make_balls_bounce_on_floor()
    for _, ball in ipairs(world.balls) do
        ball.is_floor_a_wall = true
        ball.bounces_left = settings.default_bounces_till_effect_wears_off
    end
end

-- Power Up Functions

function world.draw_power_ups()
    for _, powerup in ipairs(world.powerups) do
        powerup:draw()
    end
end

function world.update_power_ups(dt)
    for _, powerup in ipairs(world.powerups) do
        powerup:update(dt)
    end
end

function world.activate_powerups()
    local activated_powerups = {}
    for _, powerup in ipairs(world.powerups) do
        if powerup.activated then
            if powerup.id == Powerup_Ids.NEW_BALL then world.spawn_ball() end
            if powerup.id == Powerup_Ids.BALL_SPEED_REDUCTION then world.reset_ball_speed() end
            if powerup.id == Powerup_Ids.FLOOR_IS_A_WALL then world.make_balls_bounce_on_floor() end
            activated_powerups[#activated_powerups + 1] = powerup
        end
    end

    for _, powerup in ipairs(activated_powerups) do
        world.hud.enlarge_and_shrink_text(powerup:get_name())
        misc.remove_from_list(world.powerups, powerup)
    end
end

-- Core Functions

function world.draw()
    if settings.debug then
        world.draw_debug_collisions()
    else
        world.draw_blocks()
        world.draw_balls()
    end

    player.draw()
    world.draw_power_ups()
end

function world.update(dt)
    player.update(dt)

    -- Pause the update when a new ball is spawned
    local last_ball = player.get_last_ball_added()
    if last_ball and last_ball.just_spawned then return end

    world.update_balls(dt)
    world.update_power_ups(dt)
    world.activate_powerups()

    world.handle_collisions()

    if #world.blocks == 0 then world.start_game() end
end

function world.process_input()
    player.process_input()
end

return world
