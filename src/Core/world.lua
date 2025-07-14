local settings = require("src.settings")
local block = require("src.Misc.block")
local player = require("src.Core.player")
local Ball = require("src.Core.ball")
local misc = require("src.misc_functions")
local Power_Ups = require("src.Misc.powerup")

local world = {hud=nil}

world.map = {}
world.balls = {}
world.powerups = {}

-- Initialization Functions

function world.init()
	world.create_new_blocks()
	world.spawn_ball()
	world.player = player
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
	for r = 1, settings.block_rows, 1 do
		world.map[r] = world.create_block_rows(r)
	end
end

function world.add_new_row() -- Adds a new row, this'll be the first then shifts all others down a row
	-- Shift all current blocks down a row
	for r = #world.map, 1, -1 do
		world.map[r + 1] = world.map[r]
	end
	-- Replace first row with new row
	world.map[1] = world.create_block_rows(1)
	world.update_blocks()
end

function world.create_block_rows(r)
	local new_row = {}

	for c = 1, settings.block_cols, 1 do
		new_row[c] = world.new_block(r, c)
	end

	return new_row
end

function world.draw_blocks()
	for _, row in ipairs(world.map) do
		for _, map_block in ipairs(row) do
			map_block:draw()
		end
	end
end

function world.new_block(r, c)
	local w, h = settings.block_width, settings.block_height
	local x = (c - 1) * (settings.block_width + settings.block_spacing) + settings.block_spacing / 2
	local y = settings.hud_height
		+ (r - 1) * (settings.block_height + settings.block_spacing)
		+ settings.block_spacing / 2

	return block.new(x, y, w, h, settings.Colors.blocks)
end

function world.update_blocks()
	for r, row in ipairs(world.map) do
		for c, map_block in ipairs(row) do
			local x = map_block.x
			local new_block = world.new_block(r, c)
			new_block.x = x
			new_block:update()

			if world.map[r] then
				world.map[r][c] = new_block
			end
		end
	end
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
	-- Due to lags, Check for collisions when, its close to player paddle or a block
	local y_offset = settings.default_ball_radius -- extra space to prevent delayed checks
	local farthest_block_from_orgin_y_position = (#world.map + 1) * (settings.block_height + settings.block_spacing) + y_offset
	local player_paddle_y_position = settings.paddle_default_Y - y_offset

	local collided_block = nil
	local collided_blocks_row = {}

	for _, ball in ipairs(world.balls) do
		-- Handle Paddle and balls collision
		local theres_need_to_search = ball.y < farthest_block_from_orgin_y_position or ball.y > player_paddle_y_position
		if theres_need_to_search then
			if player.paddle.rect:collides_with(ball.rect) then
				ball:collided_with(player.paddle.rect, true)
			end

			-- Handle Ball and Blocks collision
			local cancel_search = false
			for r = 1, #world.map, 1 do
				if cancel_search then
					break
				end
				for c = 1, #world.map[r], 1 do
					local map_block = world.map[r][c]
					if map_block and map_block.rect:collides_with(ball.rect) then
						ball:collided_with(map_block.rect)
						cancel_search = true
						collided_block = map_block
						collided_blocks_row = world.map[r]
						break
					end
				end
			end
		end
	end

	-- Handle Paddle and powerups
	for _, powerup in ipairs(world.powerups) do
		local theres_need_to_search = powerup.y < farthest_block_from_orgin_y_position
			or powerup.y > player_paddle_y_position
		if theres_need_to_search then
			if player.paddle.rect:collides_with(powerup.rect) then
				powerup.activated = true
			end
		end
	end

	if collided_block then
		misc.remove_from_list(collided_blocks_row, collided_block)
		player.score = player.score + settings.score_on_block_destroyed

		if collided_block.has_powerup then
			world.powerups[#world.powerups + 1] =
				Power_Ups.new(collided_block.rect:get_center().x, collided_block.rect:get_center().y)
		end
	end
end

function world.draw_debug_collisions()
	player.paddle.rect:draw()
	for _, ball in ipairs(world.balls) do
		ball.rect:draw()
	end
	for _, row in ipairs(world.map) do
		for _, map_block in ipairs(row) do
			map_block.rect:draw()
		end
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
		player.draw()
		world.draw_balls()
	end
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
end

function world.process_input()
	player.process_input()
end

return world
