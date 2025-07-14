local paddle = { x = 0, y = 0, w = 0, h = 0 }
local rect = require("src.Misc.rect")

paddle.__index = paddle
paddle.rect = rect.new()
paddle.color = { r = 255, g = 255, b = 255 }


function paddle.new(x, y, w, h, color)
    local self = setmetatable({}, paddle)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.color = color or { r = math.random(0, 255)  / 255, g = math.random(0, 255)  / 255, b = math.random(0, 255) / 255}
    self.rect = rect.new(self.x, self.y, self.w, self.h)
    return self
end

function paddle:update(dt)
    self.rect.x, self.rect.y = self.x, self.y
end

function paddle:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

return paddle
