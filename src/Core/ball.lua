local settings = require("src.settings")
local rect = require("src.Misc.rect")
local misc_functions = require("src.misc_functions")


local Ball = {x=0, y=0, r=0, color={r=0.5, g=0.5, b=0.5}, direction={x = 0, y = 0}, rect = rect.new()}
Ball.__index = Ball

Ball.speed = settings.default_ball_speed
Ball.just_spawned = true
Ball.out_of_bounds = false
Ball.is_floor_a_wall = false -- Lets the Ball bounce all all walls including the one beneath the player
Ball.bounces_left = 0

function Ball.new(x, y, r, color, speed)
    local self = setmetatable({}, Ball)
    
    self.x = x or 0
    self.y = y or 0
    self.r = r or 0
    self.color = color or {r=0.5, g=0.5, b=0.5}
    self.speed = speed or Ball.DEFAULT_SPEED

    self.just_spawned = true
    self.rect = rect.new(self.x, self.y, self.r * 2, self.r * 2)
    self.direction = {x=0, y=0}
    
    return self
end

function Ball:reset()
    self.out_of_bounds = false
    self.just_spawned = true
end

function Ball:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.circle("line", self.x, self.y, self.r)
end

function Ball:move(dt)
    local x, y = self.x, self.y
    local dx, dy = self.direction.x, self.direction.y

    x = x + dx * self.speed * dt
    y = y + dy * self.speed * dt

    self.x, self.y = x, y
    self.rect.x, self.rect.y = x - self.r, y - self.r
end

function Ball:bounce_within_screen()
    local x , y, r = self.x, self.y, self.r
    local max_x, max_y = settings.screen_width - r / 2, settings.screen_height - r / 2 
    local min_x = r / 2
    local min_y = settings.hud_height

    local dx, dy = self.direction.x, self.direction.y

    if x < min_x then dx = math.abs(dx)
    elseif x > max_x then dx = -math.abs(dx) end

    if y < min_y then dy = math.abs(dy)
    elseif y > max_y then 
        if self.is_floor_a_wall then 
            dy = -math.abs(dy) 
        else self.out_of_bounds = true end
    end

    -- If a bounce occured, a change in direction is certain
    if self.direction.x ~= dx or self.direction.y ~= dy then self.bounces_left = self.bounces_left - 1 end

    self.direction.x, self.direction.y = dx, dy
end

function Ball:collided_with(obj_rect, is_player) 
    -- Change x and y direction if collides with top or bottom of object
    -- Change x direction if collides with sides

    local dx, dy = self.direction.x, self.direction.y
    local direction = self.rect:collision_side(obj_rect)

    if direction == "left" then
        dx = -math.abs(dx)
    elseif direction == "right" then
        dx = math.abs(dx)
    elseif direction == "top" then
        dy = -math.abs(dy)
    elseif direction == "bottom" then
        dy = math.abs(dy)
    end

    if is_player then
       if obj_rect:get_center().x > self.rect:get_center().x then dx = -math.abs(dx) end
       if obj_rect:get_center().x < self.rect:get_center().x then dx = math.abs(dx) end
    end

    self.direction.x, self.direction.y = dx, dy
    self.speed = self.speed + settings.speed_gain_per_bounce
end

function Ball:update(dt)
    self:move(dt)
    self:bounce_within_screen()
    if self.bounces_left <= 0 and self.is_floor_a_wall then self.is_floor_a_wall = false end

    self.bounces_left = misc_functions.clamp(self.bounces_left, 0, settings.default_bounces_till_effect_wears_off)
    print(self.bounces_left)
end 


return Ball