local rect = require("src.Misc.rect")
local settings = require("src.settings")

local Powerup = {fall_speed = settings.power_up_fall_speed, rot_speed = 2, rot_angle = 0, activated = false}
Powerup_Ids = {NEW_BALL=1, BALL_SPEED_REDUCTION=2,  FLOOR_IS_A_WALL=3,values={1, 2, 3}}

Powerup.__index = Powerup
Powerup.rect = rect.new()
Powerup.color = settings.Colors.powerups
Powerup.id = 0

function Powerup.new(x, y)
    local self = setmetatable({}, Powerup)
    self.x = x or 0
    self.y = y or 0
    self.w = settings.power_up_width
    self.h = settings.power_up_height
    self.id = math.random(1, #Powerup_Ids.values)

    self.color = settings.Colors.powerups
    self.rot_speed = math.random(1, Powerup.rot_speed + 1)
    self.rect = rect.new(self.x, self.y, self.w, self.h)

    return self
end

function Powerup:get_name()
    if self.id == Powerup_Ids.NEW_BALL then return "+1 BALL" end
    if self.id == Powerup_Ids.BALL_SPEED_REDUCTION then return "--BALL SPEED" end
    if self.id == Powerup_Ids.FLOOR_IS_A_WALL then return "FLOOR IS A WALL" end
end

function Powerup:update(dt)
    self.y = self.y + self.fall_speed * dt
    self.rect.x, self.rect.y = self.x, self.y
end

function Powerup:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    self.rot_angle = self.rot_angle + love.timer.getDelta() * self.rot_speed

    love.graphics.push()
        love.graphics.translate(x , y)
        love.graphics.rotate(self.rot_angle)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    love.graphics.pop()
end

return Powerup