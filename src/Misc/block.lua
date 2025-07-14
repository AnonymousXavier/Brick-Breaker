local block
local rect = require("src.Misc.rect")
local settings = require("src.settings")


block = { x = 0, y = 0, w = 0, h = 0 }
block.__index = block
block.color = { r = 0.51, g = 0.51, b = 0.51 }
block.rect = rect.new()
block.has_powerup = false
block.hp = 1

function block.new(x, y, w, h, hp, color)
    local self = setmetatable({}, block)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.hp = hp or 1
    self.color = color or block.color
    self.rect = rect.new(self.x, self.y, self.w, self.h)

    if math.random(math.ceil(100 / settings.power_up_chance)) == 1 then self.has_powerup = true end
    
    return self
end

function block:update()
    self.rect = rect.new(self.x, self.y, self.w, self.h)
end

function block:draw()
    if self.hp > 1 then
        local font = settings.Fonts.block_health
        local text = tostring(self.hp)
        local tw,th = font:getWidth(text), font:getHeight(text)
        local cx, cy = self.rect:get_center().x, self.rect:get_center().y

        love.graphics.setFont(font)
        love.graphics.print(text, cx - tw / 2, cy - th / 2)
        love.graphics.setFont(settings.Fonts.default)

    end

    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

    
end

return block
